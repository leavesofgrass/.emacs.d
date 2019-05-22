;;; captain-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "captain" "captain.el" (0 0 0 0))
;;; Generated autoloads from captain.el

(autoload 'captain-mode "captain" "\
Call the captain to automatically capitalize the start of every sentence.

If called interactively, enable Captain mode if ARG is positive, and
disable it if ARG is zero or negative.  If called from Lisp,
also enable the mode if ARG is omitted or nil, and toggle it
if ARG is `toggle'; disable the mode otherwise.

The captain will also automatically capitalize words you've told
him you want capitalized with `captain-capitalize-word'.

\\{captain-mode-map}

\(fn &optional ARG)" t nil)

(defvar global-captain-mode nil "\
Non-nil if Global Captain mode is enabled.
See the `global-captain-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-captain-mode'.")

(custom-autoload 'global-captain-mode "captain" nil)

(autoload 'global-captain-mode "captain" "\
Toggle Captain mode in all buffers.
With prefix ARG, enable Global Captain mode if ARG is positive;
otherwise, disable it.  If called from Lisp, enable the mode if
ARG is omitted or nil.

Captain mode is enabled in all buffers where
`captain-mode' would do it.
See `captain-mode' for more information on Captain mode.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "captain" '("captain-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; captain-autoloads.el ends here
