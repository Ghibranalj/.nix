;;; claude-code.el -*- lexical-binding: t; -*-
;;; Claude Code multi-buffer support for Emacs

;;; Code:
;;;###autoload
(defun claude-code-open-or-toggle (&optional arg)
  "Open or toggle Claude Code IDE interface.
With prefix argument (C-u), create a NEW numbered buffer instead of switching to existing."
  (interactive "P")
  (monet-mode 1)
  (let* ((project-root (projectile-project-root))
         (default-directory project-root)
         (base-name (format "claude (%s)" project-root))
         ;; Generate unique numbered name if arg provided
         (buf-name (if arg
                       (claude-code--unique-buffer-name base-name)
                     base-name))
         (buf (get-buffer buf-name)))
    (if (and buf (not arg))
        (switch-to-buffer buf)
      (progn
        (monet-start-server)
        (vterm buf-name)
        (persp-add-buffer buf-name)
        (vterm-send-string "clear; exec glm")
        (vterm-send-return)))))

;;;###autoload
(defun claude-code-open ()
  "Force create a NEW Claude Code vterm buffer.
Always creates a new numbered buffer, never switches to existing."
  (interactive)
  (claude-code-open-or-toggle t))

(defun claude-code--unique-buffer-name (base-name)
  "Generate a unique numbered buffer name based on BASE-NAME.
Example: 'claude (/path/to/project)<2>'"
  (let ((existing-numbers '()))
    (dolist (buf (buffer-list))
      (let ((name (buffer-name buf)))
        (when (string-match (concat "^" (regexp-quote base-name) "<\\([0-9]+\\)>$") name)
          (push (string-to-number (match-string 1 name)) existing-numbers))))
    (format "%s<%d>" base-name (1+ (apply 'max 0 existing-numbers)))))

(provide 'claude-code)
