(require 'else-mode)
(require 'cl-lib)
(require 'eieio)
(require 'json)

(defun psimacs/else/python/placeholder/unittest-1 (after-marker obj)
  "Python Mako template evaluation: UnitTest.mako"
  (let ((after-point (marker-position after-marker))
        (placeholder (oref obj :name))
       )
    (goto-char after-point)
    (delete-backward-char 1)

    (let* ((cache-dir    psimacs/config/python-mako-cache-dir)
           (template-dir psimacs/config/else-mako-template-dir)
           (copyright-year     (read-string "Enter the copyright year: " (format-time-string "%Y")))
           (copyright-licenser (psimacs/ui/internal/select-from-item-list "Enter the copyright holder: "
                                                                    '(
                                                                      "Johannes Brunen <hatlafax@gmx.de>"
                                                                      "DataSolid GmbH, Mönchengladbach <csons@datasolid.de>"
                                                                     )))
           (copyright-license  (psimacs/ui/internal/select-from-item-list "Enter the license type: "
                                                                    '(
                                                                      "APACHE-2.0"
                                                                      "BOOST-1.0"
                                                                      "MIT"
                                                                      "BSD-2"
                                                                      "BSD-3"
                                                                      "LGPL-2.1"
                                                                      "LGPL-3.0"
                                                                      "GPL-2.0"
                                                                      "GPL-3.0"
                                                                      "AGPL-3.0"
                                                                      "PSFL-3.10.8"
                                                                     ) 2 t))
           (python-module  (read-string "Enter the python module to be tested: " ))
           (python-class   (read-string (format "Enter the class name of module %s: " python-module) ))
           (python-function(read-string "Optionally, enter the comma or space separated list of test function names: " ))
           (comment-str    "##")

           ;;
           ;; IMPORTANT: the JSON keys must be compatible with Python, i.e. '_' instead of '-'.
           ;;
           (json-expr (json-encode `(:instances
                                     [
                                      (
                                       :console t
                                       :output_file "N/A"
                                       :offset_spaces 0
                                       :encoding "utf-8"
                                       :template_file "UnitTest.mako"
                                       :template_data (
                                                       :copyright_year     ,copyright-year
                                                       :copyright_licenser ,copyright-licenser
                                                       :copyright_license  ,copyright-license
                                                       :python_module      ,python-module
                                                       :python_class       ,python-class
                                                       :python_function    ,(split-string python-function "\\s-*,\\s-*\\|\\s-+" t)
                                                       :comment_str        ,comment-str
                                                      )
                                      )
                                     ]
                                    )
                      ))
          )

      (psimacs/python/run-script
            "MakoTemplateEval.py"
            ;;"-v"
            (format "--cache-dir=%s" cache-dir)
            (format "--template-dirs=%s" template-dir)
            json-expr)
    )))

(defun psimacs/else/python/placeholder/attr-accessor-query (after-marker obj)
  "Python Mako template evaluation: AttrAccessorQuery.mako"
  (let ((after-point (marker-position after-marker))
        (placeholder (oref obj :name))
        (tab-size (oref else-Current-Language :tab-size))
       )
    (goto-char after-point)
    (delete-backward-char 1)

    (let* ((offset-space-init (max (current-column) 0))
           (offset-space-prop (max (current-column) 0))
           (cache-dir    psimacs/config/python-mako-cache-dir)
           (template-dir psimacs/config/else-mako-template-dir)
           (attributes         (read-string "Enter the comma or space separated list of accessor attributes: " ))
           (types              (read-string "Enter the comma or space separated list of accessor types with '?'='{type}' and '-'=predecessor]: " ))
           (values             (read-string "Enter the comma or space separated list of accessor values with '?'='{expression}', '-'=predecessor and '.'=attribute: " ))
           (reader             (if (y-or-n-p "Reader properties? ") t nil))
           (writer             (if (y-or-n-p "Writer properties? ") t nil))
           (document           (if (y-or-n-p "Documentation placeholders? ") t nil))
           ;;
           ;; IMPORTANT: the JSON keys must be compatible with Python, i.e. '_' instead of '-'.
           ;;
           (json-expr-init (json-encode `(:instances
                                     [
                                      (
                                       :console t
                                       :output_file "N/A"
                                       :offset_spaces ,offset-space-init
                                       :encoding "utf-8"
                                       :template_file "AttrAccessorQuery.mako"
                                       :template_data (
                                                       :attributes     ,(split-string attributes "\\s-*,\\s-*\\|\\s-+" t)
                                                       :types          ,(split-string types      "\\s-*,\\s-*\\|\\s-+" t)
                                                       :values         ,(split-string values     "\\s-*,\\s-*\\|\\s-+" t)
                                                       :reader         ,reader
                                                       :writer         ,writer
                                                       :document       ,document
                                                       :is_init        t
                                                      )
                                      )
                                     ]
                                    )
                      ))
           (json-expr-property (json-encode `(:instances
                                     [
                                      (
                                       :console t
                                       :output_file "N/A"
                                       :offset_spaces ,offset-space-prop
                                       :encoding "utf-8"
                                       :template_file "AttrAccessorQuery.mako"
                                       :template_data (
                                                       :attributes     ,(split-string attributes "\\s-*,\\s-*\\|\\s-+" t)
                                                       :types          ,(split-string types      "\\s-*,\\s-*\\|\\s-+" t)
                                                       :values         ,(split-string values     "\\s-*,\\s-*\\|\\s-+" t)
                                                       :reader         ,reader
                                                       :writer         ,writer
                                                       :document       ,document
                                                       :is_init        nil
                                                      )
                                      )
                                     ]
                                    )
                      ))
          )

      (beginning-of-line)

      (psimacs/python/run-script
            "MakoTemplateEval.py"
            ;;"-v"
            (format "--cache-dir=%s" cache-dir)
            (format "--template-dirs=%s" template-dir)
            json-expr-init)

      (psimacs/python/run-script
            "MakoTemplateEval.py"
            ;;"-v"
            (format "--cache-dir=%s" cache-dir)
            (format "--template-dirs=%s" template-dir)
            json-expr-property)
    )))

(provide 'else-placeholder-extensions)
