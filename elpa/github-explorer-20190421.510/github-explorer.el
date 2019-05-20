;;; github-explorer.el --- Explore a GitHub repository on the fly -*- lexical-binding: t -*-

;; Copyright (C) 2019 Giap Tran <txgvnn@gmail.com>

;; Author: Giap Tran <txgvnn@gmail.com>
;; URL: https://github.com/TxGVNN/github-explorer
;; Package-Version: 20190421.510
;; Version: 0.1
;; Package-Requires: ((emacs "24.4") (request "0.1.0"))
;; Keywords: comm

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; M-x github-explorer "txgvnn/github-explorer"

;;; Code:

(require 'cl-lib)
(require 'request)
(require 'json)

(defgroup github nil
  "Major mode of GitHub configuration file."
  :group 'languages
  :prefix "github-explorer-")

(defcustom github-explorer-hook nil
  "*Hook run by `github-explorer'."
  :type 'hook
  :group 'github)

(defcustom github-explorer-name "GitHub"
  "*Modeline of `github-explorer'."
  :type 'string
  :group 'github)

(defvar github-explorer-mode-map
  (let ((keymap (make-sparse-keymap)))
    (define-key keymap (kbd "o") 'github-explorer-at-point)
    (define-key keymap (kbd "RET") 'github-explorer-at-point)
    (define-key keymap (kbd "n") 'next-line)
    (define-key keymap (kbd "p") 'previous-line)
    keymap)
  "Keymap for GitHub major mode.")

(defface github-explorer-directory-face
  '((t (:inherit font-lock-function-name-face)))
  "Face for a directory.")

(defvar github-explorer-buffer-temp)

(defvar github-explorer-repository)

;;;###autoload
(defun github-explorer (&optional repo)
  "Go REPO github."
  (interactive (list (thing-at-point 'symbol)))
  (setq github-explorer-repository (read-string "Repository: " repo))
  (github-explorer--tree (format "https://api.github.com/repos/%s/git/trees/%s" github-explorer-repository "master") "/"))

(defun github-explorer-at-point()
  "Go to path in buffer GitHub tree."
  (interactive)
  (let (url path (pos 0) matches repo base-path item)
    (setq item (get-text-property (line-beginning-position) 'invisible))
    (setq url (cdr (assoc 'url item)))
    (setq path (cdr (assoc 'path item)))

    (setq repo (buffer-name))
    (while (string-match ":\\(.+\\)\\*" repo pos)
      (setq matches (concat (match-string 0 repo)))
      (setq pos (match-end 0)))
    (setq base-path (substring matches 1 (- (length matches) 1)))
    (setq repo (car (split-string base-path ":")))
    (setq path (format "%s%s"  (car (cdr (split-string base-path ":"))) path))
    (if (string= (cdr (assoc 'type item)) "tree")
        (setq path (concat path "/")))
    (message "%s" path)
    (if (string= (cdr (assoc 'type item)) "tree")
        (github-explorer--tree url path)
      (github-explorer--raw repo path))))

(defun github-explorer--tree (url path)
  "Get trees by URL of PATH github.
This function will create *GitHub:REPO:* buffer"
  (setq github-explorer-buffer-temp (format "*%s:%s:%s*" github-explorer-name github-explorer-repository path))
  (request
   url
   :parser 'buffer-string
   :success
   (cl-function (lambda (&key data &allow-other-keys)
                  (when data
                    (with-current-buffer (get-buffer-create github-explorer-buffer-temp)
                      (let (github-explorer-object)
                        (read-only-mode -1)
                        (erase-buffer)
                        (insert data)
                        (switch-to-buffer (current-buffer))
                        (goto-char (point-min))
                        (setq github-explorer-object (json-read))
                        (erase-buffer)
                        (insert (format "[*] %s:%s\n" github-explorer-repository path))
                        (github-explorer--render-object github-explorer-object)
                        (goto-char (point-min))
                        (github-explorer-mode))))))
   :error
   (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
                  (message "Got error: %S" error-thrown)))))

(defun github-explorer--raw (repo path)
  "Get raw of PATH in REPO github."
  (let (url)
    (setq url (format "https://raw.githubusercontent.com/%s/master%s" repo path))
    (setq github-explorer-buffer-temp (format "*%s:%s:%s*" github-explorer-name repo path))
    (request
     url
     :parser 'buffer-string
     :success
     (cl-function (lambda (&key data &allow-other-keys)
                    (when data
                      (with-current-buffer (get-buffer-create github-explorer-buffer-temp)
                        (erase-buffer)
                        (insert data)
                        (pop-to-buffer (current-buffer))
                        (goto-char (point-min))))))
     :error
     (cl-function (lambda (&rest args &key error-thrown &allow-other-keys)
                    (message "Got error: %S" error-thrown))))))

(defun github-explorer-apply-auto-mode (&rest _)
  "Apply auto-mode for buffer GitHub.
pop-to-buffer(BUFFER-OR-NAME &OPTIONAL ACTION NORECORD)"
  (unless buffer-file-name
    (if (string-match-p (regexp-quote (format "*%s:" github-explorer-name)) (buffer-name))
        (let ((buffer-file-name (substring (buffer-name) 0 -1))) ;; remove * ending
          (set-auto-mode t)))))
(advice-add 'pop-to-buffer :after #'github-explorer-apply-auto-mode)

(defun github-explorer--item-path (item)
  "Get the path for an ITEM from GitHub."
  (cdr (assoc 'path item)))

(defun github-explorer--item-type (item)
  "Get the type for an ITEM from GitHub."
  (cdr (assoc 'type item)))

(defun github-explorer--render-object (github-explorer-object)
  "Render the GITHUB-EXPLORER-OBJECT."
  (let ((trees (cdr (assoc 'tree github-explorer-object))))
	(cl-loop
	 for item across trees
	 for path = (github-explorer--item-path item)

	 if (string= (github-explorer--item-type item) "blob")
	 do (insert (format "  |----- %s" path))
	 else do
	 (insert (format "  |--[+] %s" path))
	 (left-char (length path))
	 (put-text-property (point) (+ (length path) (point)) 'face 'github-explorer-directory-face)

	 do
	 (put-text-property (line-beginning-position) (1+ (line-beginning-position)) 'invisible item)
	 (end-of-line)
	 (insert "\n"))))

(define-derived-mode github-explorer-mode special-mode github-explorer-name
  "Major mode for exploring GitHub repository on the fly"
  (setq buffer-auto-save-file-name nil
        buffer-read-only t))

(provide 'github-explorer)
;;; github-explorer.el ends here
