;;; ample-regexps-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from ample-regexps.el

(autoload 'define-arx "ample-regexps" "\
Generate a custom rx-like macro under name MACRO.

See `rx' for how the generated macro can be invoked.

FORM-DEFS is a list of custom s-exp definitions to create whose
elements have the form (SYM DEF), where DEF is one of
the following:

- \"LITERAL\" -- create a matcher to match a string literally

- (regexp \"LITERAL\") -- create a match given a regexp

- SYMBOL -- create an alias for a symbol either defined earlier
  on the list or provided by `rx'

- (SUBFORM ...) -- create an alias for an application of s-exp
  subform either defined earlier on the list or provided by `rx'

- (:func #'FORM-FUNC ...) -- create an s-exp definition

The most interesting here is the last variant.  When a
corresponding rx form will be encountered, FORM-FUNC will be
called with all elements of that form as arguments (with the
first one being the form symbol itself).  FORM-FUNC must then
return a valid s-exp or a properly grouped plain regexp.

Another keywords that are recognized in the plist are:
- :min-args -- minimum number of arguments for that form (default nil)
- :max-args -- maximum number of arguments for that form (default nil)
- :predicate -- if given, all rx form arguments must satisfy it

(fn MACRO FORM-DEFS)" nil t)
(autoload 'arx-and "ample-regexps" "\
Generate an expression to match a sequence of FORMS.

(fn FORMS)")
(autoload 'arx-or "ample-regexps" "\
Generate an expression to match one of FORMS.

(fn FORMS)")
(autoload 'arx-builder "ample-regexps" "\
Run `re-builder' using arx form named ARX-NAME.

(fn &optional ARX-NAME)" t)
(register-definition-prefixes "ample-regexps" '("arx-" "define-arx--fn-post-27"))


;;; Generated autoloads from init-tryout.el

(register-definition-prefixes "init-tryout" '("foobar-rx"))

;;; End of scraped data

(provide 'ample-regexps-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; ample-regexps-autoloads.el ends here