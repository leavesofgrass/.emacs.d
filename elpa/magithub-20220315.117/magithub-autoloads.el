;;; magithub-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from magithub.el

 (autoload 'magithub-dispatch-popup "magithub" nil t)
(eval-after-load 'magit '(progn (require 'transient) (when (functionp 'magit-am) (transient-append-suffix 'magit-dispatch "C-h m" '("H" "Magithub" magithub-dispatch-popup))) (define-key magit-status-mode-map "H" #'magithub-dispatch-popup)))
(register-definition-prefixes "magithub" '("magithub-"))


;;; Generated autoloads from magithub-ci.el

(autoload 'magithub-maybe-insert-ci-status-header "magithub-ci" "\
If this is a GitHub repository, insert the CI status header.")
(register-definition-prefixes "magithub-ci" '("magit"))


;;; Generated autoloads from magithub-comment.el

(autoload 'magithub-comment-new "magithub-comment" "\
Comment on ISSUE in a new buffer.
If prefix argument DISCARD-DRAFT is specified, the draft will not
be considered.

If INITIAL-CONTENT is specified, it will be inserted as the
initial contents of the reply if there is no draft.

(fn ISSUE &optional DISCARD-DRAFT INITIAL-CONTENT)" t)
(register-definition-prefixes "magithub-comment" '("magit"))


;;; Generated autoloads from magithub-completion.el

(autoload 'magithub-completion-complete-issues "magithub-completion" "\
A `completion-at-point' function which completes \"#123\" issue references.
Add this to `completion-at-point-functions' in buffers where you
want this to be available.")
(autoload 'magithub-completion-complete-users "magithub-completion" "\
A `completion-at-point' function which completes \"@user\" user references.
Add this to `completion-at-point-functions' in buffers where you
want this to be available.  The user list is currently simply the
list of all users who created issues or pull requests.")
(autoload 'magithub-completion-enable "magithub-completion" "\
Enable completion of info from magithub in the current buffer.")


;;; Generated autoloads from magithub-core.el

(autoload 'magithub-feature-autoinject "magithub-core" "\
Configure FEATURE to recommended settings.
If FEATURE is `all' or t, all known features will be loaded.  If
FEATURE is a list, then it is a list of FEATURE symbols to load.

See `magithub-feature-list' for a list of available features and
`magithub-features' for a list of currently-installed features.

(fn FEATURE)")
(autoload 'magithub--section-value-at-point "magithub-core" "\
Determine the thing of TYPE at point.
This is intended for use as a resolving function for
`thing-at-point'.

The following symbols are defined, but other values may work with
this function: `github-user', `github-issue', `github-label',
`github-comment', `github-repository', `github-pull-request',
`github-notification',

(fn TYPE)")
(put 'github-user 'thing-at-point (lambda nil (magithub--section-value-at-point 'user)))
(put 'github-issue 'thing-at-point (lambda nil (or magithub-issue (magithub--section-value-at-point 'issue))))
(put 'github-label 'thing-at-point (lambda nil (magithub--section-value-at-point 'label)))
(put 'github-comment 'thing-at-point (lambda nil (or magithub-comment (magithub--section-value-at-point 'comment))))
(put 'github-notification 'thing-at-point (lambda nil (magithub--section-value-at-point 'notification)))
(put 'github-repository 'thing-at-point (lambda nil (or (magithub--section-value-at-point 'repository) magithub-repo (magithub-repo))))
(put 'github-pull-request 'thing-at-point (lambda nil (or (magithub--section-value-at-point 'pull-request) (when-let ((issue (thing-at-point 'github-issue))) (and (magithub-issue--issue-is-pull-p issue) (magithub-cache :issues `(magithub-request (ghubp-get-repos-owner-repo-pulls-number ',(magithub-issue-repo issue) ',issue))))))))
(register-definition-prefixes "magithub-core" '("magit"))


;;; Generated autoloads from magithub-dash.el

(autoload 'magithub-dashboard "magithub-dash" "\
View your GitHub dashboard." t)
(register-definition-prefixes "magithub-dash" '("magithub-dash"))


;;; Generated autoloads from magithub-edit-mode.el

(autoload 'magithub-edit-mode "magithub-edit-mode" "\
Major mode for editing GitHub issues and pull requests.

(fn)" t)
(register-definition-prefixes "magithub-edit-mode" '("magithub-edit-"))


;;; Generated autoloads from magithub-issue.el

(autoload 'magithub-issue--insert-issue-section "magithub-issue" "\
Insert GitHub issues if appropriate.")
(autoload 'magithub-issue--insert-pr-section "magithub-issue" "\
Insert GitHub pull requests if appropriate.")
(register-definition-prefixes "magithub-issue" '("magit"))


;;; Generated autoloads from magithub-issue-post.el

(register-definition-prefixes "magithub-issue-post" '("magithub-"))


;;; Generated autoloads from magithub-issue-tricks.el

(autoload 'magithub-pull-request-merge "magithub-issue-tricks" "\
Merge PULL-REQUEST with ARGS.
See `magithub-pull-request--completing-read'.  If point is on a
pull-request object, that object is selected by default.

(fn PULL-REQUEST &optional ARGS)" t)
(register-definition-prefixes "magithub-issue-tricks" '("magithub-"))


;;; Generated autoloads from magithub-issue-view.el

(autoload 'magithub-issue-view "magithub-issue-view" "\
View ISSUE in a new buffer.
Return the new buffer.

(fn ISSUE)" t)
(register-definition-prefixes "magithub-issue-view" '("magithub-issue-view-"))


;;; Generated autoloads from magithub-label.el

(register-definition-prefixes "magithub-label" '("magit"))


;;; Generated autoloads from magithub-notification.el

(register-definition-prefixes "magithub-notification" '("magit"))


;;; Generated autoloads from magithub-orgs.el

(register-definition-prefixes "magithub-orgs" '("magithub-orgs-list"))


;;; Generated autoloads from magithub-repo.el

(register-definition-prefixes "magithub-repo" '("magit"))


;;; Generated autoloads from magithub-settings.el

 (autoload 'magithub-settings-popup "magithub-settings" nil t)
(register-definition-prefixes "magithub-settings" '("magithub-"))


;;; Generated autoloads from magithub-user.el

(register-definition-prefixes "magithub-user" '("magit"))

;;; End of scraped data

(provide 'magithub-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; magithub-autoloads.el ends here