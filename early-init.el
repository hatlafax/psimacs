;;; early-init.el --- Early initialization. -*- lexical-binding: t -*-

;; Copyright (C) 2020-2021 Johannes Brunen (hatlafax)

;; Author: Johannes Brunen <hatlafax@gmx.de>
;; URL: https://github.com/hatlafax/psimacs

;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;

;;; Commentary:
;;
;; Emacs 27 introduces early-init.el, which is run before init.el,
;; before package and UI initialization happens.
;;

;;; Code:

(eval-when-compile (load "compile"))

(defvar psimacs/config/main-org-file "init.org"
  "The psimacs initialization file.")

(defvar psimacs/config/icon-file "psi.ico"
  "The psimacs icon file.")

(defvar psimacs/config/license-file "LICENSE"
  "The psimacs license file.")

(defvar psimacs/config/custom-file "custom.el"
  "The psimacs custom elips file.")

(defvar psimacs/config/agenda-dir "agenda"
  "The psimacs agenda directory.")

(defvar psimacs/config/assets-dir "assets"
  "The psimacs assets directory.")

;;
;; Some early settings
;;
(setq debug-on-error  t                 ; That will open the debugger when the error is raised.
      message-log-max t                 ; Specifies how many lines to keep in the *Messages* buffer.
                                        ; The value t means there is no limit on how many lines to keep.
      ad-redefinition-action 'accept    ; Suppressing ad-handle-definition warnings
      gc-cons-threshold       most-positive-fixnum)

;;
;; Delegate to configuration to org-file
;;      http://orgmode.org/worg/org-contrib/babel/intro.html
;;
(defun psimacs/config/tangle-section-canceled ()
  "Return t if the current section header was 'CANCELED', else nil.

Section headers starts with '*', '**', etc, e.g.:

'** CANCELED Some section header text'"
  (save-excursion (if (re-search-backward "^\\*+\\s-+\\(.*?\\)?\\s-*$" nil t)
                      (or (string-prefix-p "CANCELED" (match-string 1) t)
                          (string-prefix-p "DISABLED" (match-string 1) t)) nil)))

(defun psimacs/config/tangle-config-org (orgfile elfile)
  "This function will write all source blocks from 'file.org' into 'file.el' that are ...
        - not marked as :tangle no
        - have a source-code of =emacs-lisp=
        - doesn't have the todo-markers CANCELED or DISABLED

Elisp source code blocks that are marked as ':tangle foo.el' are written to file 'foo.el' instead.
For these files extra header and footer are written. In this case, also an additional header argument
':var file-description \"text\" is evaluated and used in the file header.

Shortly, all tangled source code blocks for file foo.el are written to one file 'foo.el' that look like

;; foo.el --- text -*- lexical-binding: t -*-
;;
;; Don't edit this file, edit %s instead ...
;;

...

(provide 'foo)"
  (let* ((body-list ())
         (src-block-regexp   (concat
                              ;; (1) indentation                 (2) lang
                              "^\\([ \t]*\\)#\\+begin_src[ \t]+\\([^ \f\t\n\r\v]+\\)[ \t]*"
                              ;; (3) switches
                              "\\([^\":\n]*\"[^\"\n*]*\"[^\":\n]*\\|[^\":\n]*\\)"
                              ;; (4) header arguments
                              "\\([^\n]*\\)\n"
                              ;; (5) body
                              "\\([^\000]*?\n\\)??[ \t]*#\\+end_src"))
         (found-files-alist ())
         (found-load-dir-alist ()))
    (with-temp-buffer (insert-file-contents orgfile)
                      (goto-char (point-min))
                      (while (re-search-forward src-block-regexp nil t)
                        (let ((lang (match-string 2))
                              (args (match-string 4))
                              (body (match-string 5))
                              (canc (psimacs/config/tangle-section-canceled)))
                          (when (and (string= lang "emacs-lisp")
                                     (not (string-match-p "^.*:tangle\\s-+no.*$" args))
                                     (not canc))
                            (when (string-match "^.*:tangle\\s-+\\([^:]+\\).*$" args)
                              (let ((dst (string-trim (match-string 1 args)))
                                    (dst-file)
                                    (dst-dir)
                                    (line))
                                (if (string= dst "yes")
                                    (progn
                                      (setq body (concat body "\n"))
                                      (add-to-list 'body-list body))
                                  (progn
                                    (setq dst-file (expand-file-name (concat user-emacs-directory
                                                                             dst)))
                                    (setq dst-dir  (file-name-directory dst-file))
                                    (unless (cdr (assoc dst-file found-files-alist))
                                      (when (file-exists-p dst-file)
                                        (delete-file dst-file))
                                      (unless (file-exists-p dst-dir)
                                        (make-directory dst-dir t))
                                      (unless (cdr (assoc dst-dir found-load-dir-alist))
                                        (setq line (format
                                                    "(add-to-list 'load-path (concat user-emacs-directory \"%s\"))\n\n"
                                                    (file-relative-name (file-name-directory
                                                                         dst-dir)
                                                                        user-emacs-directory)))
                                        (add-to-list 'body-list line)
                                        (map-put found-load-dir-alist dst-dir t))
                                      (setq line (format "(require '%s)\n\n"
                                                         (file-name-sans-extension
                                                          (file-name-nondirectory dst-file))))
                                      (add-to-list 'body-list line)
                                      (let ((description " "))
                                        (when (string-match
                                               "^.*:var\\s-+file-description\\s-+\"\\([^\"]+\\).*$"
                                               args)
                                          (setq description (concat " " (string-trim (match-string 1
                                                                                                   args))
                                                                    " ")))
                                        (with-temp-buffer (insert (format
                                                                   ";;; %s ---%s-*- lexical-binding: t -*-\n"
                                                                   (file-name-nondirectory dst-file)
                                                                   description))
                                                          (insert         ";;\n")
                                                          (insert (format
                                                                   ";; Don't edit this file, edit %s instead ...\n"
                                                                   orgfile))
                                                          (insert         ";;\n")
                                                          (insert         "\n")
                                                          (write-region (point-min)
                                                                        (point-max) dst-file t)))
                                      (map-put found-files-alist dst-file t))
                                    (with-temp-buffer (insert body)
                                                      (insert "\n")
                                                      (write-region (point-min)
                                                                    (point-max) dst-file t))))))))))

    ;;
    ;; Add the config pathes to Emacs load path list and add the final provide-clause to the
    ;; written emacs package files.
    ;;
    (dolist (element found-files-alist)
      (let ((file (car element)))
        (with-temp-buffer (insert (format "(provide '%s)\n" (file-name-sans-extension
                                                             (file-name-nondirectory file))))
                          (write-region (point-min)
                                        (point-max) file t))))
    (with-temp-file elfile (insert (format
                                    ";;; %s --- Initialization file -*- lexical-binding: t -*-\n"
                                    (file-name-nondirectory elfile)))
                    (insert         ";;\n")
                    (insert (format ";; Don't edit this file, edit %s instead ...\n" orgfile))
                    (insert         ";;\n")
                    (apply 'insert (reverse body-list))
                    (insert         "\n"))

    ;; Byte compiling the init file is not recommendet
    ;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Init-File.html
    ;;(byte-compile-file elfile)
    ))

(defun psimacs/config/load-configuration-file (orgfile)
  "Load the given configuration file unless it equals to 'init.el' itself.

File 'init.el' is loaded automatically at startup. No extra loading is necessary.
This function is basically an efficient replacement of org-babel-load-file.
However, it performs some extra task on extraction of the elisp source code blocks.
This happens in the tangle-config-org function.
No byte compiling is performed for any elips file generated by the tangling procedure.
"
  (let* ((base-name (file-name-sans-extension orgfile))
         (elfile    (concat base-name ".el"))
         ;;(elcfile (concat base-name ".elc")) ;; Byte compiling the init file is not recommendet
         )
    (when (or (not (file-exists-p elfile))
              (file-newer-than-file-p orgfile elfile)

              ;; Byte compiling the init file is not recommendet
              ;;(file-newer-than-file-p orgfile elcfile)
              ;;(file-newer-than-file-p elfile  elcfile)
              )
      (psimacs/config/tangle-config-org orgfile elfile))
    (unless (equal (file-name-nondirectory elfile) "init.el")
      (load (file-name-sans-extension elfile)))))

;;
;; Sync with dropbox
;;   The main config file is taken from the dropbox folder but it is loaded from
;;   the local directory (see below). Therefore we copy the main config file from
;;   the dropbox emacs folder into the emacs home directory. If the main config
;;   file in the emacs home directory is newer than the file in the dropbox folder
;;   we update that one with the newer local one.
;;   The agenda files are worked on the dropbox directly, but a local copy is made
;;   for backup purpose.
;;
(defun psimacs/config/find-dropbox-folder ()
  "Get the current dropbox folder on the running machine. Otherwise nil"
  (interactive)
  (let* ((db-appdat-info-file      (concat (expand-file-name (file-name-as-directory (getenv
                                                                                      "APPDATA")))
                                           "Dropbox/info.json"))
         (db-localappdat-info-file (concat (expand-file-name (file-name-as-directory (getenv
                                                                                      "LOCALAPPDATA")))
                                           "Dropbox/info.json"))
         (db-user-home-info-file   "~/Dropbox/info.json")
         (json-path (cond ((eq system-type 'windows-nt)
                           (if (file-exists-p db-appdat-info-file) db-appdat-info-file (if
                                                                                           (file-exists-p
                                                                                            db-localappdat-info-file)
                                                                                           db-localappdat-info-file
                                                                                         (if
                                                                                             (file-exists-p
                                                                                              db-user-home-info-file)
                                                                                             db-user-home-info-file
                                                                                           nil))))
                          ((or
                            (eq system-type 'darwin)
                            (eq system-type 'gnu-linux))
                           (if (file-exists-p db-user-home-info-file) db-user-home-info-file
                             nil)))))
    (if (and json-path
             (file-exists-p json-path))
        (progn
          (require 'json)
          (cdr (assoc 'path (car (json-read-file json-path))))) nil)))

(defconst psimacs/config/dropbox-dir
  (let ( (f (psimacs/config/find-dropbox-folder)) )
    (if f (file-name-as-directory f) nil))
  "The psimacs dropbox directory or nil.")

(defconst psimacs/config/dropbox-emacs-dir
  (if psimacs/config/dropbox-dir (file-name-as-directory (concat psimacs/config/dropbox-dir
                                                                 "emacs/psimacs/emacs")) nil)
  "The psimacs dropbox emacs configuration directory or nil.")

(defun psimacs/file-system/copy-directory-files (src dst &optional only-newer-files)
  "Copy all files from SRC directory into DST directory recursively.
If optional argument ONLY-NEWER-FILES is non nil source files are copied only if their time stamp is
newer then the time stamp of the destination file."
  (when (file-exists-p src)
    (unless (file-exists-p dst)
      (make-directory dst t))
    (dolist (f (directory-files-recursively src ".*" t))
      (if (file-directory-p f)
          (let ((f-relative (file-relative-name f src)))
            (when f-relative (let ((dst-dir (concat (file-name-as-directory dst) f-relative)))
                               (unless (file-exists-p dst-dir)
                                 (make-directory dst-dir t)))))
        ;; ...else is file
        (let* ((src-dir (file-name-directory f))
               (f-relative (file-relative-name src-dir src))
               (dst-dir dst)
               (dst-file))
          (when f-relative
            (setq dst-dir (concat (file-name-as-directory dst) f-relative)))
          (unless (file-exists-p dst-dir)
            (make-directory dst-dir t))
          (setq dst-file (concat (file-name-as-directory dst-dir)
                                 (file-name-nondirectory f)))

                                        ;(if (file-exists-p dst-file)
          (if only-newer-files (when (file-newer-than-file-p f dst-file)
                                 (copy-file f dst-file t t))
            ;; ...else always copy
            (copy-file f dst-file t t))
                                        ;)
          )))))


(defun psimacs/file-system/synchronize-directories(src dst)
  "This function synchronizes two directories.
All files that are found in SRC and that are either not in DST or newer in SRC are copied to DST.
All files that are found in DST and that are either not in SRC or newer in DST are copied to SRC.

After this function is finished the two directories are identical.
 "
  (psimacs/file-system/copy-directory-files src dst t)
  (psimacs/file-system/copy-directory-files dst src t))

(defun psimacs/config/sync-with-dropbox ()
  "Synchronize with dropbox directory if it exists.

The expected place in the dropbox directory is 'emacs/psimacs/emacs'.
"
  (if (and psimacs/config/dropbox-dir
           (file-directory-p psimacs/config/dropbox-dir))
      (let* ((db-dir psimacs/config/dropbox-emacs-dir)
             (sync-files-alist ())
             (sync-dirs-alist  ()))
        (add-to-list 'sync-files-alist (cons (concat user-emacs-directory
                                                     psimacs/config/main-org-file)
                                             (concat db-dir psimacs/config/main-org-file)))
        (add-to-list 'sync-files-alist (cons (concat user-emacs-directory psimacs/config/icon-file)
                                             (concat db-dir psimacs/config/icon-file)))
        (add-to-list 'sync-files-alist (cons (concat user-emacs-directory
                                                     psimacs/config/license-file)
                                             (concat db-dir psimacs/config/license-file)))
        (add-to-list 'sync-files-alist (cons (concat user-emacs-directory
                                                     psimacs/config/custom-file)
                                             (concat db-dir psimacs/config/custom-file)))
        (add-to-list 'sync-dirs-alist  (cons (file-name-as-directory (concat user-emacs-directory
                                                                             psimacs/config/agenda-dir))
                                             (file-name-as-directory (concat db-dir
                                                                             psimacs/config/agenda-dir))))
        (add-to-list 'sync-dirs-alist  (cons (file-name-as-directory (concat user-emacs-directory
                                                                             psimacs/config/assets-dir))
                                             (file-name-as-directory (concat db-dir
                                                                             psimacs/config/assets-dir))))

        ;;
        ;; Create missing dropbox emacs directory
        ;;
        (unless (file-directory-p db-dir)
          (make-directory db-dir t))
        (dolist (files sync-files-alist)
          (let ((file    (car files))
                (db-file (cdr files)))
            ;;
            ;; Try to copy the file from dropbox to emacs directory...
            ;;
            (if (file-exists-p db-file)
                (progn
                  ;;
                  ;; If the local file is newer, we update dropbox first
                  ;;
                  (when (file-newer-than-file-p file db-file)
                    (copy-file file db-file t t))
                  (when (or (not (file-exists-p file))
                            (file-newer-than-file-p db-file file))
                    (copy-file db-file file t t)))

              ;; ...else try to upload to dropbox
              (if (file-exists-p file)
                  (copy-file file db-file t t)))))
        (dolist (files sync-dirs-alist)
          (let ((directory    (car files))
                (db-directory (cdr files)))
            (psimacs/file-system/synchronize-directories db-directory directory))))))

;;
;; Synchronize with dropbox
;;
(psimacs/config/sync-with-dropbox)

;;
;; Extract elisp code from org files if necessary and load that code into
;; emacs.
;;
(psimacs/config/load-configuration-file (expand-file-name (concat user-emacs-directory
                                                                  psimacs/config/main-org-file)))
