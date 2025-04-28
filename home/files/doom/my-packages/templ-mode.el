;;; templ-mode.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 
;;
;; Author:  ghibranalj
;; Maintainer:  ghibranalj
;; Created: April 28, 2025
;; Modified: April 28, 2025
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/gibi/templ-mode
;; Package-Requires: ((emacs "24.3"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;  Because templ-ts-mode sucks balls im gonna make my own mode
;;  Description
;;
;;; Code:
(require 'polymode)
(require 'lsp-mode)

;; 1. Disable problematic minor modes in polymode buffers
(defun disable-problematic-modes ()
  (whitespace-mode -1)
  (when (boundp 'highlight-indentation-mode)
    (highlight-indentation-mode -1))
  (setq-local font-lock-maximum-decoration nil))

;; 2. Define modes
(define-hostmode poly-templ-hostmode
  :mode 'go-mode)

(define-innermode poly-templ-html-innermode
  :mode 'html-mode
  :head-matcher "\\btempl\\b.*{"
  :tail-matcher "^\\s-*}\\s-*$"
  :head-mode 'host
  :tail-mode 'host)

(define-innermode poly-templ-go-innermode
  :mode 'go-mode
  :head-matcher "{{"
  :tail-matcher "}}"
  :head-mode 'host
  :tail-mode 'host)

;; 3. Main polymode definition with proper initialization
(define-polymode poly-templ-mode
  :hostmode 'poly-templ-hostmode
  :innermodes '(poly-templ-html-innermode
                poly-templ-go-innermode))

;; 4. Setup function
(defun poly-templ-mode-setup ()
  (setq-local lsp-disabled-clients '(gopls))
  (disable-problematic-modes)
  (setq-local jit-lock-contextually nil)
  (setq-local font-lock-multiline t)
  (font-lock-flush))

(add-hook 'poly-templ-mode-hook 'poly-templ-mode-setup)

;; 5. File association
(add-to-list 'auto-mode-alist '("\\.templ\\'" . poly-templ-mode))

;; 6. LSP Configuration
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection '("templ" "lsp"))
                  :major-modes '(poly-templ-mode)
                  :activation-fn (lambda (file-name _mode)
                                  (string-match "\\.templ\\'" file-name))
                  :server-id 'templ-lsp
                  :priority 1))

(add-to-list 'lsp-language-id-configuration '(poly-templ-mode . "templ"))

;; 7. Robust font-lock handling
(with-eval-after-load 'polymode
  (defun pm-safe-fontify-region (beg end &optional loudly)
    (condition-case err
        (progn
          (when (> end beg)
            (font-lock-default-fontify-region beg end loudly)))
      (error (message "Font-lock error in range %s-%s: %S" beg end err))))
  
  (advice-add 'font-lock-default-fontify-region :around #'pm-safe-fontify-region)
  
  ;; Fix for jit-lock arguments
  (defun pm-fix-jit-lock (orig-fun &rest args)
    (if (and (eq major-mode 'poly-templ-mode)
             (>= (length args) 4))
        (apply orig-fun (butlast args))
      (apply orig-fun args)))
  
  (advice-add 'jit-lock--run-functions :around #'pm-fix-jit-lock)
  
  ;; Workaround for overlay issues
  (defun pm-fix-post-command ()
    (when (and (eq major-mode 'poly-templ-mode)
      (ignore-errors
        (remove-hook 'post-command-hook 'whitespace-post-command-hook t)))))
  
  (add-hook 'poly-templ-mode-hook 'pm-fix-post-command))
;;; templ-mode.el ends here
