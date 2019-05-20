;;; adafruit-wisdom-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "adafruit-wisdom" "adafruit-wisdom.el" (0 0
;;;;;;  0 0))
;;; Generated autoloads from adafruit-wisdom.el

(autoload 'adafruit-wisdom-select "adafruit-wisdom" "\
Select a quote at random and return as a string.

Parse assuming the following RSS format:
     ((rss (channel (item ...) (item ...) (item ...) ...)))
where each item contains:
     (item (title nil \"the quote\") ...)
and we  need just \"the quote\"." nil nil)

(autoload 'adafruit-wisdom "adafruit-wisdom" "\
Display one of Adafruit's quotes in the minibuffer.
If ARG is non-nil the joke will be inserted into the current
buffer rather than shown in the minibuffer.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "adafruit-wisdom" '("adafruit-wisdom-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; adafruit-wisdom-autoloads.el ends here
