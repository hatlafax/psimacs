(require 'else-mode)
(require 'cl-lib)
(require 'eieio)
(require 'json)

(defun psimacs/else/python/placeholder/unittest-1 (after-marker obj)

  (message "entry of psimacs/else/python/placeholder/unittest-1")

  (let ((after-point (marker-position after-marker))
        (placeholder (oref obj :name))
       )
    (goto-char after-point)
    (delete-backward-char 1)

    (message "was here today")

    (let* ((cache-dir    psimacs/config/python-mako-cache-dir)
           (template-dir psimacs/config/else-mako-template-dir)
           (copyright-year  (read-string "Enter the copyright year: " (format-time-string "%Y")))
           (copyright-licenser (psimacs/ui/internal/select-from-item-list "Enter the copyright holder: "
                                                                    '(
                                                                      "Johannes Brunen <hatlafax@gmx.de>"
                                                                      "DataSolid GmbH, Mönchengladbach <csons@datasolid.de>"
                                                                     )))
           (copyright-license (psimacs/ui/internal/select-from-item-list "Enter the license type: "
                                                                    '(
                                                                      "Apache-2.0"
                                                                      "Boost"
                                                                      "MIT"
                                                                      "BSD-2"
                                                                      "BSD-3"
                                                                      "LGPL-2.1"
                                                                      "LGPL-3.0"
                                                                      "GPL-2.0"
                                                                      "GPL-3.0"
                                                                      "AGPL-3.0"
                                                                      "PSF-3.10.2"
                                                                     ) 2 t))
           (python-module  (read-string "Enter the python module to be tested: " ))
           (python-class   (read-string (format "Enter the class name of module %s: " python-module) ))

           (json-expr (json-encode `(:instances
                                     [
                                      (
                                       :console t
                                       :output_file "N/A"
                                       :offset_spaces 8
                                       :encoding "utf-8"
                                       :template_file "UnitTest.mako"
                                       :template_data (
                                                       :copyright-year     ,copyright-year
                                                       :copyright-licenser ,copyright-licenser
                                                       :copyright-license  ,copyright-license
                                                       :python-module      ,python-module
                                                       :python-class       ,python-class
                                                      )
                                      )
                                     ]
                                    )
                      ))
          )

      (psimacs/python/run-script
            "MakoTemplateEval.py"
            ;"-v"
            (format "--cache-dir=%s" cache-dir)
            (format "--template-dirs=%s" template-dir)
            json-expr)
    )))


(defun test/from/other/place/test6-fun (after-marker obj)
  (message "has executed test/from/other/place/test6-fun")
)


(provide 'else-placeholder-extensions)
