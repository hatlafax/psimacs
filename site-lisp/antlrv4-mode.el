;;; antlrv4-mode.el --- major mode for antlrv4  -*- lexical-binding: t; -*-

(eval-when-compile
  (require 'rx))

(defconst antlrv4-mode-syntax-table
  (let ((table (make-syntax-table)))

    ;; space is whitespace
    (modify-syntax-entry ?\s " ")

    ;; ' is a string delimiter
    (modify-syntax-entry ?' "\"" table)
    ;; " is not a string delimiter too
    ;;(modify-syntax-entry ?\" "-" table)

    ;; / is punctuation, but // is a comment starter
    (modify-syntax-entry ?/ ". 12" table)
    ;; \n is a comment ender
    (modify-syntax-entry ?\n ">" table)

    ;; - and _ are word constituents
    (modify-syntax-entry ?_ "w" table)
    (modify-syntax-entry ?- "w" table)

    ;; symbols
    (modify-syntax-entry ?*  "_" table)
    (modify-syntax-entry ?+  "_" table)
    (modify-syntax-entry ??  "_" table)
    (modify-syntax-entry ?!  "_" table)
    (modify-syntax-entry ?=  "_" table)

    ;; punctations
    (modify-syntax-entry ?:  "." table)
    (modify-syntax-entry ?\; "." table)
    (modify-syntax-entry ?|  "." table)
    (modify-syntax-entry ?\( "." table)
    (modify-syntax-entry ?\) "." table)

    ;; valid brackets
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)

    table))

(defvar antlrv4-mode-abbrev-table nil
  "Abbreviation table used in `antlrv4-mode' buffers.")

(define-abbrev-table 'antlrv4-mode-abbrev-table
  '())

;font-lock-warning-face
;font-lock-function-name-face
;font-lock-function-call-face
;font-lock-variable-name-face
;font-lock-variable-use-face
;font-lock-keyword-face
;font-lock-comment-face
;font-lock-comment-delimiter-face
;font-lock-type-face
;font-lock-constant-face
;font-lock-builtin-face
;font-lock-preprocessor-face
;font-lock-string-face
;font-lock-doc-face
;font-lock-doc-markup-face
;font-lock-negation-char-face
;font-lock-escape-face
;font-lock-number-face
;font-lock-operator-face
;font-lock-property-name-face
;font-lock-property-use-face
;font-lock-punctuation-face
;font-lock-bracket-face
;font-lock-delimiter-face
;font-lock-misc-punctuation-face

(setq antlrv4-mode--font-lock-defaults
      '(
        ("grammar\\|annotations" . 'font-lock-keyword-face)
        ("separator\\|description\\|dublication\\|substitute_count\\|auto_substitute" . 'font-lock-constant-face)
        ("^\\([[:word:]_-]+\\)\s*$" . (1 'font-lock-variable-name-face))
        ("\s+\\([[:word:]_-]+\\)" . (1 'font-lock-type-face))
      )
)

;;;###autoload
(define-derived-mode antlrv4-mode prog-mode "AntlrV4"
  :syntax-table antlrv4-mode-syntax-table
  :abbrev-table antlrv4-mode-abbrev-table
  (setq font-lock-defaults '(antlrv4-mode--font-lock-defaults))
)

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.g4\\'" . antlrv4-mode))

(provide 'antlrv4-mode)

;;; antlr-mode.el ends here
