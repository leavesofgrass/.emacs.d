;;; erc-tweet-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "erc-tweet" "erc-tweet.el" (0 0 0 0))
;;; Generated autoloads from erc-tweet.el

(eval-after-load 'erc '(define-erc-module tweet nil "Display inlined twits in ERC buffer" ((add-hook 'erc-insert-modify-hook 'erc-tweet-show-tweet t) (add-hook 'erc-send-modify-hook 'erc-tweet-show-tweet t)) ((remove-hook 'erc-insert-modify-hook 'erc-tweet-show-tweet) (remove-hook 'erc-send-modify-hook 'erc-tweet-show-tweet)) t))

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "erc-tweet" '("erc-tweet")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; erc-tweet-autoloads.el ends here
