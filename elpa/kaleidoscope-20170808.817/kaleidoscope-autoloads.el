;;; kaleidoscope-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "kaleidoscope" "kaleidoscope.el" (0 0 0 0))
;;; Generated autoloads from kaleidoscope.el

(autoload 'kaleidoscope-start "kaleidoscope" "\
Connect to the device on 'kaleidoscope-device-port'.

\(fn)" t nil)

(autoload 'kaleidoscope-quit "kaleidoscope" "\
Disconnect from the device.

\(fn)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "kaleidoscope" '("kaleidoscope-")))

;;;***

;;;### (autoloads nil nil ("kaleidoscope-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; kaleidoscope-autoloads.el ends here
