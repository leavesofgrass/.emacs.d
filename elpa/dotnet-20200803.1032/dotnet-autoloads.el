;;; dotnet-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:

(add-to-list 'load-path (or (and load-file-name (file-name-directory load-file-name)) (car load-path)))



;;; Generated autoloads from dotnet.el

(autoload 'dotnet-add-package "dotnet" "\
Add package reference from PACKAGE-NAME.

(fn PACKAGE-NAME)" t)
(autoload 'dotnet-add-reference "dotnet" "\
Add a REFERENCE to a PROJECT.

(fn REFERENCE PROJECT)" t)
(autoload 'dotnet-build "dotnet" "\
Build a .NET project." t)
(autoload 'dotnet-clean "dotnet" "\
Clean build output." t)
(autoload 'dotnet-new "dotnet" "\
Initialize a new console .NET project.
PROJECT-PATH is the path to the new project, TEMPLATE is a
template (see `dotnet-templates'), and LANG is a supported
language (see `dotnet-langs').

(fn PROJECT-PATH TEMPLATE LANG)" t)
(autoload 'dotnet-publish "dotnet" "\
Publish a .NET project for deployment." t)
(autoload 'dotnet-restore "dotnet" "\
Restore dependencies specified in the .NET project." t)
(autoload 'dotnet-run "dotnet" "\
Compile and execute a .NET project.  With ARG, query for project path again.

(fn ARG)" t)
(autoload 'dotnet-run-with-args "dotnet" "\
Compile and execute a .NET project with ARGS.

(fn ARGS)" t)
(autoload 'dotnet-sln-add "dotnet" "\
Add a project to a Solution." t)
(autoload 'dotnet-sln-remove "dotnet" "\
Remove a project from a Solution." t)
(autoload 'dotnet-sln-list "dotnet" "\
List all projects in a Solution." t)
(autoload 'dotnet-sln-new "dotnet" "\
Create a new Solution." t)
(autoload 'dotnet-test "dotnet" "\
Launch project unit-tests, querying for a project on first call.  With ARG, query for project path again.

(fn ARG)" t)
(autoload 'dotnet-mode "dotnet" "\
dotnet CLI minor mode.

This is a minor mode.  If called interactively, toggle the
`dotnet mode' mode.  If the prefix argument is positive, enable
the mode, and if it is zero or negative, disable the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `dotnet-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

(fn &optional ARG)" t)
(register-definition-prefixes "dotnet" '("dotnet-"))

;;; End of scraped data

(provide 'dotnet-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; dotnet-autoloads.el ends here