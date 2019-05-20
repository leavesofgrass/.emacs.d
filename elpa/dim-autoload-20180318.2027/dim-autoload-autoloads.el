;;; dim-autoload-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "dim-autoload" "dim-autoload.el" (0 0 0 0))
;;; Generated autoloads from dim-autoload.el

(autoload 'dim-autoload-cookies-mode "dim-autoload" "\
Toggle dimming autoload cookie lines.
You likely want to enable this globally
using `global-dim-autoload-cookies-mode'.

\(fn &optional ARG)" t nil)

(defvar global-dim-autoload-cookies-mode nil "\
Non-nil if Global Dim-Autoload-Cookies mode is enabled.
See the `global-dim-autoload-cookies-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-dim-autoload-cookies-mode'.")

(custom-autoload 'global-dim-autoload-cookies-mode "dim-autoload" nil)

(autoload 'global-dim-autoload-cookies-mode "dim-autoload" "\
Toggle Dim-Autoload-Cookies mode in all buffers.
With prefix ARG, enable Global Dim-Autoload-Cookies mode if ARG is positive;
otherwise, disable it.  If called from Lisp, enable the mode if
ARG is omitted or nil.

Dim-Autoload-Cookies mode is enabled in all buffers where
`turn-on-dim-autoload-cookies-mode-if-desired' would do it.
See `dim-autoload-cookies-mode' for more information on Dim-Autoload-Cookies mode.

\(fn &optional ARG)" t nil)

(autoload 'turn-on-dim-autoload-cookies-mode-if-desired "dim-autoload" "\


\(fn)" nil nil)

(autoload 'hide-autoload-cookies-mode "dim-autoload" "\
Toggle hidding autoload cookie lines.
You likely want to enable this globally
using `global-hide-autoload-cookies-mode'.

\(fn &optional ARG)" t nil)

(defvar global-hide-autoload-cookies-mode nil "\
Non-nil if Global Hide-Autoload-Cookies mode is enabled.
See the `global-hide-autoload-cookies-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `global-hide-autoload-cookies-mode'.")

(custom-autoload 'global-hide-autoload-cookies-mode "dim-autoload" nil)

(autoload 'global-hide-autoload-cookies-mode "dim-autoload" "\
Toggle Hide-Autoload-Cookies mode in all buffers.
With prefix ARG, enable Global Hide-Autoload-Cookies mode if ARG is positive;
otherwise, disable it.  If called from Lisp, enable the mode if
ARG is omitted or nil.

Hide-Autoload-Cookies mode is enabled in all buffers where
`turn-on-hide-autoload-cookies-mode-if-desired' would do it.
See `hide-autoload-cookies-mode' for more information on Hide-Autoload-Cookies mode.

\(fn &optional ARG)" t nil)

(autoload 'turn-on-hide-autoload-cookies-mode-if-desired "dim-autoload" "\


\(fn)" nil nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "dim-autoload" '("cycle-autoload-cookies-visibility" "hide-autoload-" "dim-autoload-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; dim-autoload-autoloads.el ends here
