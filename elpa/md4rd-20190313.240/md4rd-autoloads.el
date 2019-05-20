;;; md4rd-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "md4rd" "md4rd.el" (0 0 0 0))
;;; Generated autoloads from md4rd.el

(autoload 'md4rd-login "md4rd" "\
Sign into the reddit system via OAuth, to allow use of authenticated endpoints." t nil)

(autoload 'md4rd-refresh-login "md4rd" "\
Refresh the OAuth authentication token (lifetime 3600 seconds)." t nil)

(autoload 'md4rd "md4rd" "\
Invoke the main mode." t nil)

(autoload 'mode-for-reddit "md4rd" "\
Invoke the main mode." t nil)

(autoload 'md4rd-mode "md4rd" "\
Invoke the main mode." t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "md4rd" '("md4rd-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; md4rd-autoloads.el ends here
