;;; org2jekyll-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from org2jekyll.el

(autoload 'org2jekyll-input-directory "org2jekyll" "\
Compute the input folder from the FOLDER-NAME.

(fn &optional FOLDER-NAME)")
(autoload 'org2jekyll-output-directory "org2jekyll" "\
Compute the output folder from the optional FOLDER-NAME.

(fn &optional FOLDER-NAME)")
(autoload 'org2jekyll-init-current-buffer "org2jekyll" "\
Given an existing buffer, add the needed metadata to make it a post or page." t)
(autoload 'org2jekyll-create-draft "org2jekyll" "\
Prompt the user for org metadata and then create a new Jekyll blog post.
The specified title will be used as the name of the file." t)
(autoload 'org2jekyll-list-posts "org2jekyll" "\
Lists the posts folder." t)
(autoload 'org2jekyll-list-drafts "org2jekyll" "\
List the drafts folder." t)
(autoload 'org2jekyll-publish "org2jekyll" "\
Publish the current org file as post or page depending on the chosen layout.
Layout `'post`' is a jekyll post.
Layout `'default`' is a page (depending on the user customs)." t)
(autoload 'org2jekyll-publish-posts "org2jekyll" "\
Publish all posts." t)
(autoload 'org2jekyll-publish-pages "org2jekyll" "\
Publish all pages." t)
(autoload 'org2jekyll-mode "org2jekyll" "\
Functionality for publishing the current org-mode post to jekyll.

With no argument, the mode is toggled on/off.
Non-nil argument turns mode on.
Nil argument turns mode off.

Commands:
\\{org2jekyll-mode-map}

This is a minor mode.  If called interactively, toggle the
`Org2jekyll mode' mode.  If the prefix argument is positive,
enable the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `org2jekyll-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(register-definition-prefixes "org2jekyll" '("org2jekyll-"))


;;; Generated autoloads from org2jekyll-utilities.el

(register-definition-prefixes "org2jekyll-utilities" '("org2jekyll-tests-with-temp-buffer"))

;;; End of scraped data

(provide 'org2jekyll-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; org2jekyll-autoloads.el ends here