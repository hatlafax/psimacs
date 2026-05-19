;;; eat-windows.el --- Eat configuration -*- lexical-binding: t; -*-

(require 'cl-lib)

(defgroup eat-windows nil
  "Personal Eat configuration."
  :group 'custom-init)

(defcustom eat-windows-pywinpty-python
  (or (executable-find "python") "python")
  "Python executable used to run the Eat pywinpty bridge."
  :type 'string
  :group 'eat-windows)

(defcustom eat-windows-pywinpty-bridge
  (expand-file-name "eat_pywinpty_bridge.py"
                    (file-name-directory (or load-file-name buffer-file-name)))
  "Python bridge script used to connect Eat to pywinpty."
  :type 'file
  :group 'eat-windows)

(defcustom eat-windows-conpty-term 'unset
  "TERM value exposed to programs running under Windows ConPTY.

When `unset', remove TERM from the child process environment.
When nil, use Eat's own terminal name and TERMINFO.
When a string, use that literal TERM value."
  :type '(choice (const :tag "Unset TERM" unset)
                 (const :tag "Use Eat terminal name" nil)
                 string)
  :group 'eat-windows)

(defcustom eat-windows-conpty-coding-system 'utf-8-unix
  "Coding system used for the Windows ConPTY byte stream."
  :type 'coding-system
  :group 'eat-windows)

(defcustom eat-windows-pywinpty-extra-environment nil
  "Additional environment entries for Windows pywinpty children.

Each entry should be a string accepted by `process-environment', such as
\"NAME=value\" to set a variable or \"NAME\" to remove it."
  :type '(repeat string)
  :group 'eat-windows)

(defcustom eat-windows-pywinpty-environment-functions nil
  "Functions returning additional pywinpty environment entries.

Each function is called with no arguments when a new Eat process is
created.  It may return nil, one environment string, or a list of
environment strings."
  :type '(repeat function)
  :group 'eat-windows)

(defcustom eat-windows-pywinpty-debug-log nil
  "Optional file path for pywinpty bridge debug logging.

When nil, no bridge debug log is written."
  :type '(choice (const :tag "Disabled" nil) file)
  :group 'eat-windows)

(defvar eat-terminal)
(defvar eat-term-terminfo-directory)
(defvar eat-windows-conpty-mode nil)
(defvar eat-windows-pywinpty-mode nil)
(declare-function eat--adjust-process-window-size "eat")
(declare-function eat-exec "eat")
(declare-function eat-term-name "eat")
(declare-function eat-term-size "eat")

(defconst eat-windows-pywinpty--resize-prefix
  "\e]777;eat-resize="
  "Private control sequence prefix consumed by `eat_pywinpty_bridge.py'.")

(defun eat-windows-pywinpty--resize-sequence (width height)
  "Return the bridge control sequence for WIDTH and HEIGHT."
  (format "%s%dx%d\a"
          eat-windows-pywinpty--resize-prefix
          width height))

(defun eat-windows-conpty--env-name (entry)
  "Return the environment variable name from ENTRY."
  (if (string-match "\\`\\([^=]+\\)=" entry)
      (match-string 1 entry)
    entry))

(defun eat-windows-conpty--remove-env (names environment)
  "Return ENVIRONMENT without entries named by NAMES."
  (cl-remove-if
   (lambda (entry)
     (cl-some
      (lambda (name)
        (string-equal-ignore-case
         name (eat-windows-conpty--env-name entry)))
      names))
   environment))

(defun eat-windows-conpty--term-env ()
  "Return the process environment entry for TERM."
  (cond
   ((eq eat-windows-conpty-term 'unset)
    "TERM")
   ((stringp eat-windows-conpty-term)
    (concat "TERM=" eat-windows-conpty-term))
   (t
    (concat "TERM=" (eat-term-name)))))

(defun eat-windows-conpty--terminfo-env ()
  "Return a TERMINFO environment entry, or nil when not appropriate."
  (unless eat-windows-conpty-term
    (concat "TERMINFO=" eat-term-terminfo-directory)))

(defun eat-windows-conpty--environment-from-functions ()
  "Return configured dynamic environment entries."
  (let (entries)
    (dolist (function eat-windows-pywinpty-environment-functions
                      (nreverse entries))
      (let ((result (funcall function)))
        (cond
         ((stringp result)
          (push result entries))
         ((listp result)
          (dolist (entry result)
            (when (stringp entry)
              (push entry entries)))))))))

(defun eat-windows-conpty--environment ()
  "Return `process-environment' adjusted for a ConPTY child."
  (append
   (delq nil
         (append
          (list
           (eat-windows-conpty--term-env)
           (eat-windows-conpty--terminfo-env))
          eat-windows-pywinpty-extra-environment
          (eat-windows-conpty--environment-from-functions)))
   (eat-windows-conpty--remove-env
    '("TERM" "TERMINFO")
    process-environment)))

(defun eat-windows-conpty--terminal-size ()
  "Return the current Eat terminal size as (WIDTH . HEIGHT)."
  (let ((size (and (boundp 'eat-terminal)
                   eat-terminal
                   (eat-term-size eat-terminal))))
    (cons (max (or (car-safe size) 80) 1)
          (max (or (cdr-safe size) 24) 1))))

(defun eat-windows-conpty--eat-wrapper-tail (command)
  "Return Eat's real child argv from upstream Eat wrapper COMMAND."
  (when (and (consp command)
             (equal (car command) "/usr/bin/env")
             (equal (cadr command) "sh")
             (equal (nth 2 command) "-c"))
    (cdr (member ".." command))))

(defun eat-windows-conpty--argv (command)
  "Return the direct child argv represented by Eat wrapper COMMAND."
  (let ((argv (eat-windows-conpty--eat-wrapper-tail command)))
    (cond
     ((and (equal (car argv) "/usr/bin/env")
           (equal (cadr argv) "sh")
           (equal (nth 2 argv) "-c")
           (stringp (nth 3 argv))
           (null (nthcdr 4 argv)))
      (let ((program (nth 3 argv)))
        (if (file-executable-p program)
            (list program)
          (split-string-shell-command program))))
     (argv argv))))

(defun eat-windows-conpty--command (command)
  "Return a pywinpty bridge command for Eat wrapper COMMAND."
  (if (not (file-readable-p eat-windows-pywinpty-bridge))
      (progn
        (message "eat-windows: bridge script is not readable: %s"
                 eat-windows-pywinpty-bridge)
        nil)
    (when-let* ((argv (eat-windows-conpty--argv command)))
      (let* ((size (eat-windows-conpty--terminal-size))
             (width (number-to-string (car size)))
             (height (number-to-string (cdr size)))
             (bridge-command
              (list eat-windows-pywinpty-python
                    eat-windows-pywinpty-bridge
                    "--cols" width
                    "--rows" height)))
        (when eat-windows-pywinpty-debug-log
          (setq bridge-command
                (append bridge-command
                        (list "--debug-log"
                              (expand-file-name
                               eat-windows-pywinpty-debug-log)))))
        (append bridge-command (list "--") argv)))))

(defun eat-windows-conpty--around-eat-exec (fn &rest args)
  "Run Eat's process through Windows ConPTY when appropriate."
  (if (or (not eat-windows-pywinpty-mode)
          (not (eq system-type 'windows-nt))
          (file-remote-p default-directory))
      (apply fn args)
    (let ((make-process-function (symbol-function #'make-process)))
      (cl-letf*
          (((symbol-function #'make-process)
            (lambda (&rest plist)
              (let ((command (eat-windows-conpty--command
                              (plist-get plist :command))))
                (if (not command)
                    (apply make-process-function plist)
                  (let* ((plist (copy-sequence plist))
                         (process-environment
                          (eat-windows-conpty--environment))
                         (coding-system-for-read
                          eat-windows-conpty-coding-system)
                         (coding-system-for-write
                          eat-windows-conpty-coding-system)
                         process)
                    (setf (plist-get plist :command) command)
                    (setq process (apply make-process-function plist))
                    (process-put process 'eat-windows-pywinpty t)
                    (set-process-coding-system
                     process
                     eat-windows-conpty-coding-system
                     eat-windows-conpty-coding-system)
                    process))))))
        (apply fn args)))))

(defun eat-windows-pywinpty--around-adjust-process-window-size
    (fn process windows)
  "Resize the pywinpty bridge after Eat updates its terminal model."
  (let ((size (funcall fn process windows)))
    (when (and eat-windows-pywinpty-mode
               size
               (process-live-p process)
               (process-get process 'eat-windows-pywinpty))
      (process-send-string
       process
       (eat-windows-pywinpty--resize-sequence
        (max (car size) 1)
        (max (cdr size) 1))))
    size))

(define-minor-mode eat-windows-pywinpty-mode
  "Use pywinpty for Eat processes on native Windows."
  :global t
  :group 'eat-windows
  (if eat-windows-pywinpty-mode
      (progn
        (unless (featurep 'eat)
          (require 'eat))
        (unless (advice-member-p #'eat-windows-conpty--around-eat-exec
                                 #'eat-exec)
          (advice-add #'eat-exec :around
                      #'eat-windows-conpty--around-eat-exec))
        (unless (advice-member-p
                 #'eat-windows-pywinpty--around-adjust-process-window-size
                 #'eat--adjust-process-window-size)
          (advice-add
           #'eat--adjust-process-window-size :around
           #'eat-windows-pywinpty--around-adjust-process-window-size)))
    (advice-remove #'eat-exec
                   #'eat-windows-conpty--around-eat-exec)
    (advice-remove
     #'eat--adjust-process-window-size
     #'eat-windows-pywinpty--around-adjust-process-window-size)))

(when (and (eq system-type 'windows-nt)
           (require 'eat nil t))
  (eat-windows-pywinpty-mode 1))

(provide 'eat-windows)

;;; eat-windows.el ends here