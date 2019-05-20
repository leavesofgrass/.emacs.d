;;; erc-youtube-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "erc-youtube" "erc-youtube.el" (0 0 0 0))
;;; Generated autoloads from erc-youtube.el

(eval-after-load 'erc '(define-erc-module youtube nil "Display inlined info about youtube links in ERC buffer" ((add-hook 'erc-insert-modify-hook 'erc-youtube-show-info t) (add-hook 'erc-send-modify-hook 'erc-youtube-show-info t)) ((remove-hook 'erc-insert-modify-hook 'erc-youtube-show-info) (remove-hook 'erc-send-modify-hook 'erc-youtube-show-info)) t))

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "erc-youtube" '("erc-youtube")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; erc-youtube-autoloads.el ends here
