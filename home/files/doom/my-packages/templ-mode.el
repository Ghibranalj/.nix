;;; poly-templ-mode.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2025 
;;
;; Author:  ghibranalj
;; Maintainer:  ghibranalj
;; Created: April 28, 2025
;; Modified: April 28, 2025
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/ghibralj/poly-templ-mode
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

;; 1. Define host and inner modes
(define-hostmode poly-templ-hostmode
  :mode 'go-mode)

(define-innermode poly-templ-html-innermode
  :mode 'html-mode
  :head-matcher "^\\s-*templ\\b.*{\\s-*$"
  :tail-matcher "^\\s-*}\\s-*$"
  :head-mode 'host
  :tail-mode 'host)

(define-innermode poly-templ-go-expr-innermode
  :mode 'go-mode
  :head-matcher "{{\\s-*"
  :tail-matcher "\\s-*}}"
  :head-mode 'host
  :tail-mode 'host)

;; 2. Define main polymode
(define-polymode poly-templ-mode
  :hostmode 'poly-templ-hostmode
  :innermodes '(poly-templ-html-innermode
                poly-templ-go-expr-innermode))

;; 4. File association
(add-to-list 'auto-mode-alist '("\\.templ\\'" . poly-templ-mode))

;; 3. Configure LSP
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection '("templ" "lsp"))
                  :major-modes '(poly-templ-mode)
                  :activation-fn (lambda (file-name _mode)
                                   (string-match "\\.templ\\'" file-name))
                  :server-id 'templ-lsp
                  :priority 1))

(add-to-list 'lsp-language-id-configuration '(poly-templ-mode . "templ"))

;; 5. Handle Go mode inheritance
(with-eval-after-load 'go-mode
  (defun poly-templ--go-mode-setup ()
    (when (derived-mode-p 'poly-templ-mode)
    (setq-local lsp-disabled-clients '(gopls)))))

(provide 'poly-templ-mode)
;;; templ-mode.el ends here
