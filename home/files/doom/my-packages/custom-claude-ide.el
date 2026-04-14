;;; custom-claude-ide.el -*- lexical-binding: t; -*-
;;; Customizations for claude-code-ide.el - selected window + multi-instance

;;; Code:

;; Override display function to always use current window
(advice-add 'claude-code-ide--display-buffer-in-side-window
            :override
            (lambda (buffer)
              "Display BUFFER in the current window (no side window, no split)."
              (switch-to-buffer buffer)
              (selected-window)))

;; Disable side window behavior
(setq claude-code-ide-use-side-window nil)

;; Helper: Get next available buffer number
(defun custom-claude-ide--next-number (project-name)
  "Find the next available buffer number for PROJECT-NAME."
  (let ((numbers '()))
    (dolist (buf (buffer-list))
      (when-let* ((name (buffer-name buf))
                  (pos (string-match (format "^\\*claude-code\\[%s\\]<\\([0-9]+\\)>\\*$"
                                              (regexp-quote project-name))
                                      name)))
        (push (string-to-number (match-string 1 name)) numbers)))
    (if numbers (1+ (apply #'max numbers)) 1)))

;; Helper: Create new instance
(defun custom-claude-ide--create (name)
  "Create new Claude instance with buffer NAME."
  (let ((claude-code-ide-buffer-name-function (lambda (_) name)))
    (claude-code-ide--start-session nil nil)))

;;;###autoload
(defun custom-claude-ide-toggle ()
  "Switch to existing Claude buffer, or create new if none exists."
  (interactive)
  (let ((existing (cl-find-if (lambda (buf)
                                (string-match "^\\*claude-code\\[" (buffer-name buf)))
                              (buffer-list))))
    (if existing
        (switch-to-buffer existing)
      (custom-claude-ide--create "*claude-code[default]*"))))

;;;###autoload
(defun custom-claude-ide-new ()
  "Always create a new numbered Claude instance."
  (interactive)
  (let* ((project (file-name-nondirectory
                   (directory-file-name
                    (if (fboundp 'claude-code-ide--get-working-directory)
                        (funcall 'claude-code-ide--get-working-directory)
                      default-directory))))
         (number (custom-claude-ide--next-number project))
         (name (format "*claude-code[%s<%d>]*" project number)))
    (custom-claude-ide--create name)))

(provide 'custom-claude-ide)
