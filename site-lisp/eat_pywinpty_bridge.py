"""Bridge Emacs Eat pipes to a Windows ConPTY using pywinpty."""

from __future__ import annotations

import argparse
import os
import re
import sys
import threading
import time
import traceback
from pathlib import Path
from typing import Iterable, TextIO

try:
    from winpty import PtyProcess
except ImportError as exc:
    sys.stderr.write(
        "eat_pywinpty_bridge.py: failed to import pywinpty.\n"
        "Install it with: python -m pip install pywinpty\n"
        f"Original error: {exc}\n"
    )
    raise SystemExit(127) from exc


CONTROL_PREFIX = b"\x1b]777;eat-resize="
CONTROL_RE = re.compile(rb"\A([1-9][0-9]{0,4})x([1-9][0-9]{0,4})\Z")
CONTROL_SUFFIX = b"\x07"
MAX_CONTROL_PAYLOAD = 32
ENCODING = "utf-8"
ERRORS = "replace"


class DebugLog:
    def __init__(self, path: str | None) -> None:
        self._lock = threading.Lock()
        self._file: TextIO | None = None
        if path:
            try:
                self._file = Path(path).open("a", encoding="utf-8", errors="replace")
            except OSError as exc:
                sys.stderr.write(
                    "eat_pywinpty_bridge.py: "
                    f"could not open debug log {path!r}: {exc}\n"
                )

    def write(self, message: str) -> None:
        if self._file is None:
            return
        stamp = time.strftime("%Y-%m-%d %H:%M:%S")
        with self._lock:
            self._file.write(f"{stamp} {message}\n")
            self._file.flush()

    def close(self) -> None:
        if self._file is not None:
            self._file.close()
            self._file = None


def _longest_control_prefix_suffix(data: bytes) -> int:
    """Return length of DATA suffix that is a CONTROL_PREFIX prefix."""
    max_len = min(len(data), len(CONTROL_PREFIX) - 1)
    for length in range(max_len, 0, -1):
        if CONTROL_PREFIX.startswith(data[-length:]):
            return length
    return 0


def _write_pty(proc: PtyProcess, data: bytes, log: DebugLog) -> bool:
    if not data:
        return True
    try:
        proc.write(data.decode(ENCODING, errors=ERRORS))
    except Exception as exc:  # pywinpty can raise backend-specific errors.
        log.write(f"stdin write failed: {exc!r}")
        return False
    return True


def _set_winsize(proc: PtyProcess, cols: int, rows: int, log: DebugLog) -> None:
    try:
        proc.setwinsize(rows, cols)
    except Exception as exc:
        log.write(f"resize failed: cols={cols} rows={rows} error={exc!r}")
    else:
        log.write(f"resize: cols={cols} rows={rows}")


def _handle_control(proc: PtyProcess, payload: bytes, log: DebugLog) -> None:
    match = CONTROL_RE.match(payload)
    if not match:
        log.write(f"ignored malformed control payload: {payload!r}")
        return
    cols = int(match.group(1))
    rows = int(match.group(2))
    _set_winsize(proc, cols, rows, log)


def _handle_stdin(proc: PtyProcess, log: DebugLog) -> None:
    pending = b""
    stdin_fd = sys.stdin.fileno()
    log.write("stdin thread started")

    while proc.isalive():
        try:
            chunk = os.read(stdin_fd, 4096)
        except OSError as exc:
            log.write(f"stdin read failed: {exc!r}")
            break

        if not chunk:
            log.write("stdin closed")
            break

        pending += chunk
        while pending:
            start = pending.find(CONTROL_PREFIX)
            if start < 0:
                keep = _longest_control_prefix_suffix(pending)
                if not _write_pty(proc, pending[: len(pending) - keep], log):
                    return
                pending = pending[len(pending) - keep :]
                break

            if not _write_pty(proc, pending[:start], log):
                return
            pending = pending[start + len(CONTROL_PREFIX) :]

            end = pending.find(CONTROL_SUFFIX)
            if end < 0:
                if len(pending) > MAX_CONTROL_PAYLOAD:
                    log.write("discarded unterminated resize control")
                    pending = b""
                else:
                    pending = CONTROL_PREFIX + pending
                break

            payload = pending[:end]
            pending = pending[end + len(CONTROL_SUFFIX) :]
            _handle_control(proc, payload, log)

    log.write("stdin thread stopped")


def _forward_output(proc: PtyProcess, log: DebugLog) -> int:
    log.write("output loop started")
    while True:
        try:
            data = proc.read(4096)
        except EOFError:
            log.write("pty output reached EOF")
            break
        except Exception as exc:
            log.write(f"pty read failed: {exc!r}")
            break

        if not data:
            if not proc.isalive():
                log.write("pty process is no longer alive")
                break
            continue

        sys.stdout.buffer.write(data.encode(ENCODING, errors=ERRORS))
        sys.stdout.buffer.flush()

    try:
        status = proc.wait()
    except Exception as exc:
        log.write(f"wait failed: {exc!r}")
        return 1
    log.write(f"child exit status: {status}")
    return int(status or 0)


def _terminate_child(proc: PtyProcess, log: DebugLog) -> None:
    if not proc.isalive():
        return
    for method_name in ("terminate", "kill"):
        method = getattr(proc, method_name, None)
        if method is None:
            continue
        try:
            method()
        except TypeError:
            try:
                method(True)
            except Exception as exc:
                log.write(f"{method_name} failed: {exc!r}")
                continue
        except Exception as exc:
            log.write(f"{method_name} failed: {exc!r}")
            continue
        log.write(f"sent child {method_name}")
        return


def _parse_args(argv: Iterable[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run a command under pywinpty for Emacs Eat."
    )
    parser.add_argument("--cols", type=int, required=True)
    parser.add_argument("--rows", type=int, required=True)
    parser.add_argument("--debug-log")
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args(argv)
    if args.command[:1] == ["--"]:
        args.command = args.command[1:]
    if not args.command:
        parser.error("missing command")
    args.cols = max(args.cols, 1)
    args.rows = max(args.rows, 1)
    return args


def main(argv: list[str]) -> int:
    args = _parse_args(argv)
    log = DebugLog(args.debug_log)
    proc: PtyProcess | None = None
    stdin_thread: threading.Thread | None = None

    try:
        log.write(
            "spawn: "
            f"cols={args.cols} rows={args.rows} cwd={os.getcwd()!r} "
            f"command={args.command!r}"
        )
        proc = PtyProcess.spawn(
            args.command,
            cwd=os.getcwd(),
            env=os.environ.copy(),
            dimensions=(args.rows, args.cols),
        )
        stdin_thread = threading.Thread(
            target=_handle_stdin,
            args=(proc, log),
            daemon=True,
            name="eat-pywinpty-stdin",
        )
        stdin_thread.start()
        return _forward_output(proc, log)
    except KeyboardInterrupt:
        log.write("keyboard interrupt")
        if proc is not None:
            _terminate_child(proc, log)
        return 130
    except Exception as exc:
        sys.stderr.write(f"eat_pywinpty_bridge.py: {exc}\n")
        log.write("fatal exception:\n" + traceback.format_exc())
        if proc is not None:
            _terminate_child(proc, log)
        return 1
    finally:
        if proc is not None and stdin_thread is not None:
            stdin_thread.join(timeout=0.2)
        log.write("bridge stopped")
        log.close()


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))