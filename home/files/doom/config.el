;; ;;; $DOOM_DIR/config.el -*- lexical-binding: t; -*-
(load! "keymap.el" doom-user-dir)

;; ;; find file subdirectory my-packages
;; ;; and eval every single one
(let ((d (expand-file-name "my-packages" doom-user-dir)))
  (dolist (file (directory-files d t "\\.el$"))
    (load file))
  (message "==== Loaded my-packages ===="))

(defvar my-new-frame-hook nil
  "Hook run after a any new frame is created.")
(defvar my-new-gui-frame-hook nil
  "Hook run after a any new gui frame is created.")
(defvar my-new-tty-frame-hook nil
  "Hook run after a any new tty frame is created.")
(defvar my-gui-already-started nil
  "Flag to check if gui has already been started.")
(defvar my-tty-already-started nil
  "Flag to check if tty has already been started.")
(defvar my-is-gui-frame nil
  "Flag to check if frame is gui frame.")
(defun on-new-frame ()
  "This is executed when a new frame is created."
  (if (display-graphic-p)
      (progn
        (setq my-is-gui-frame t)
        (unless my-gui-already-started
          (setq my-gui-already-started t)
          (run-hooks 'my-new-gui-frame-hook)))
    (unless my-tty-already-started
      (setq my-tty-already-started t)
      (run-hooks 'my-new-tty-frame-hook))))
;; Running on daemon startup
(if (daemonp)
    (add-hook 'after-make-frame-functions (lambda (frame)
                                            (with-selected-frame frame
                                              (on-new-frame))))
  (on-new-frame))

;;;
;;; General Variables
;;;

(setq
 ;; display-line-numbers-type 'relative
 scroll-margin 16
 scroll-conservatively 101
 scroll-up-aggressively 0.01
 scroll-down-aggressively 0.01
 scroll-preserve-screen-position t
 auto-window-vscroll t
 enable-local-variables :safe

 ;; Auto save
 auto-save-default t
 make-backup-files t
 ;; Doom Variables
 doom-theme 'doom-material-dark
 doom-bin "doom"
 +snippets-dir "~/.config/doom-snippets"
 )
;; load the font set by nix
(load! "~/.config/doomfont/font.el")

;;;
;;; Free floating functions
;;;

;; (defmacro time! (name &rest body)
;;   "Measure and report the time it takes to evaluate BODY."
;;   `(let ((time (current-time)))
;;      ,@body
;;      (message "==== %s took %.06f seconds ====" ,name (float-time (time-since time)))))

(defun my-chmod-this-file ( mode )
  (interactive `(,(read-string "File Mode: " nil)))
  (if (and (buffer-file-name) (file-exists-p (buffer-file-name)))
      (shell-command (format "chmod %s %s" mode (buffer-file-name)))
    (message "Buffer has no file.")))

(defun my-comment-or-uncomment()
  "Comment or uncomment the current line or region."
  (interactive)
  (if mark-active
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))

(defun my-eval-line ()
  "Evaluate the current line."
  (interactive)
  (eval-region (line-beginning-position) (line-end-position)))

(defun my-poshandler (info)
  (cons
   ;; X
   (/ (- (plist-get info :parent-frame-width) (plist-get info :posframe-width)) 2)
   ;; Y
   (/ (plist-get info :parent-frame-height) 5)))

(defun my-create-directory (directory)
  "Create a directory recursively using mkdir -p."
  (interactive (list (read-string "Create directory: ")))
  (let ((full-directory (if (file-name-absolute-p directory)
                            directory
                          (expand-file-name directory default-directory))))
    (shell-command (concat "mkdir -p " full-directory))
    (message (concat "Created directory: " full-directory))))

(defun my--open-or-toggle-claude-code ()
  "Open or toggle Claude Code IDE interface."
  (interactive)
  (condition-case nil
      (claude-code-ide-toggle)
    (error (claude-code-ide))))
;; ;;;
;; ;;; random shit
;; ;;;

;; (add-hook! prog-mode '(lambda () (display-line-numbers-mode)))

;;;
;;; use-package
;;;

(use-package! evil-megasave
  :hook
  (prog-mode . evil-megasave-mode)
  (git-commit-mode . evil-megasave-mode)
  (conf-mode . evil-megasave-mode)
  (yaml-mode . evil-megasave-mode)
  (html-mode . evil-megasave-mode))

;; company; make it load before copilot
(use-package! company
  :hook
  (prog-mode . company-mode)
  :custom
  (company-idle-delay
   (lambda () (if (company-in-string-or-comment) nil 0.3)))
  :config
  (add-to-list 'company-backends 'company-yasnippet))

;; ;; Coplilot
;; (use-package! copilot
;;   :after company
;;   :config
;;   (setq copilot-network-proxy '(:host "127.0.0.1" :port 7890))
;;   (defun +copilot/tab ()
;;     "Copilot completion."
;;     (interactive)
;;     (or
;;      (copilot-accept-completion)
;;      (if (bound-and-true-p emmet-mode)
;;          (emmet-expand-line nil))
;;      (indent-relative)))
;;   :hook (prog-mode . copilot-mode)
;;   :bind (("<backtab>" . 'copilot-accept-completion-by-word)
;;          ("<backtab>" . 'copilot-accept-completion-by-word)
;;          :map company-active-map
;;          ("<tab>" . '+copilot/tab)
;;          ("TAB" . '+copilot/tab)
;;          :map company-mode-map
;;          ("<tab>" . '+copilot/tab)
;;          ("TAB" . '+copilot/tab)))

(use-package! company-box
  :disabled
  :hook
  (company-mode . (lambda ()
                    (when my-is-gui-frame
                      company-box-mode))))

(use-package! lsp-mode
  :custom
  (lsp-warn-no-matched-clients nil)
  :hook (lsp-mode . lsp-headerline-breadcrumb-mode)
  :config
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\tmp\\'")
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.devenv\\'")
  ;; GLSL language support
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("glslls" "--stdin"))
                    :activation-fn (lsp-activate-on "glsl")
                    :server-id 'glslls))

  (add-to-list 'lsp-language-id-configuration
               '(glsl-mode . "glsl"))

  (add-to-list 'lsp-language-id-configuration '(sql-mode . "sql"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "sqls")
    :major-modes '(sql-mode)
    :server-id 'sqls
    :priority 1))

  (add-to-list 'lsp-language-id-configuration
               '(astro-ts-mode . "astro"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("astro-ls" "--stdio"))
                    :activation-fn (lsp-activate-on "astro")
                    :server-id 'astro-ls))

  ;; templ
  ;;
  (add-to-list 'lsp-language-id-configuration '(templ-ts-mode . "templ"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("templ" "lsp"))
                    :activation-fn (lsp-activate-on "templ")
                    :priority -1
                    :server-id 'templ-ls))
  )

(use-package! dired
  :after evil-collection
  :hook
  (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "." 'dired-hide-dotfiles-mode
    "M" 'my-create-directory))

(use-package! dired-x
  :hook
  (dired-mode . dired-omit-mode)
  :config
  (setq dired-omit-files
        (concat dired-omit-files
                "node_modules"
                "\\|_templ\\.go\\'"
                "\\|_templ\\.txt\\'")))


(use-package! projectile
  :config
  (add-to-list 'projectile-globally-ignored-directories "tmp")
  (add-to-list 'projectile-globally-ignored-directories "vendor")
  (add-to-list 'projectile-globally-ignored-directories "CMakeFiles")
  (add-to-list 'projectile-globally-ignored-directories "build")
  (add-to-list 'projectile-globally-ignored-directories "^.*vendor.*$")
  (add-to-list 'projectile-globally-ignored-directories "web-legacy")
  (add-to-list 'projectile-globally-ignored-directories ".devenv"))

;;;; BELOW THIS WAS COMMENTED OUT
;; (use-package! dap-mode
;;   :after lsp-mode
;;   :config
;;   (dap-auto-configure-mode))

(use-package! vertico-posframe
  :after vertico
  :custom
  (vertico-posframe-parameters
   '((left-fringe . 20)
     (right-fringe . 20)
     ))
  (vertico-posframe-width 100)
  (vertico-posframe-height nil)
  (vertico-posframe-poshandler 'my-poshandler)
  :hook
  (my-new-gui-frame . vertico-posframe-mode))

(use-package! evil
  :config
  (evil-define-command my-evil-mkdir (arg)
    (interactive "<a>")
    (if arg
        (my-create-directory arg)
      (call-interactively 'my-create-directory)))
  (evil-ex-define-cmd "mkdir" 'my-evil-mkdir))

(use-package! read-string-posframe
  :hook
  (my-new-gui-frame . read-string-posframe-mode))

(use-package! rainbow-indent-and-delimeters
  :init
  (rainbow-indent-and-delimiters-mode 1))

(use-package! evil-terminal-cursor-changer
  :hook
  (my-new-tty-frame . evil-terminal-cursor-changer-activate))

(use-package! prisma-mode
  :disabled
  :mode "\\.prisma\\'"
  :hook (prisma-mode . lsp-mode))

(use-package! persistent-scratch
  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-autosave-mode 1))

(use-package! nix-mode
  :custom
  (lsp-nix-nixd-nixos-options-expr
   (format "(builtins.getFlake (\"git+file://\" + toString ./.)).nixosConfigurations.%s.options"
           (getenv "NIX_HOSTNAME")))
  (lsp-nix-nixd-home-manager-options-expr
   (format "(builtins.getFlake (\"git+file://\" + toString ./.)).nixosConfigurations.%s.options.home-manager.users.type.getSubOptions []"
           (getenv "NIX_HOSTNAME"))))

(use-package! templ-ts-mode
  :mode "\\.templ\\'"
  :config
  ;; Fix the tree-sitter query error
  (defun templ-ts--fix-font-lock-rules ()
    "Fix the font-lock rules for templ-ts-mode."
    (when (and (treesit-available-p) (treesit-language-available-p 'templ))
      ;; Modify the font-lock rules to use patterns that match the actual templ grammar
      (setq templ-ts--go-font-lock-rules
            (list
             :language 'templ
             :feature 'bracket
             '((["(" ")" "[" "]" "{" "}"]) @font-lock-bracket-face)

             :language 'templ
             :feature 'comment
             '((comment) @font-lock-comment-face)

             :language 'templ
             :feature 'constant
             '([(false) (nil) (true)] @font-lock-constant-face
               (const_declaration (const_spec name: (_) @font-lock-constant-face)))

             :language 'templ
             :feature 'delimiter
             '((["," "." ";" ":"]) @font-lock-delimiter-face)

             :language 'templ
             :feature 'definition
             ;; This is the section that was causing the error
             ;; Simplified version that works with the templ grammar
             '((function_declaration name: (_) @font-lock-function-name-face)
               (method_declaration name: (_) @font-lock-function-name-face)
               (field_declaration name: (_) @font-lock-property-name-face)
               (parameter_declaration name: (_) @font-lock-variable-name-face)
               (short_var_declaration left: (expression_list (_) @font-lock-variable-name-face))
               (var_spec name: (_) @font-lock-variable-name-face))

             :language 'templ
             :feature 'function
             '((call_expression function: (_) @font-lock-function-call-face))

             :language 'templ
             :feature 'keyword
             `([,@go-ts-mode--keywords] @font-lock-keyword-face)

             :language 'templ
             :feature 'number
             '([(float_literal) (imaginary_literal) (int_literal)] @font-lock-number-face)

             :language 'templ
             :feature 'string
             '([(interpreted_string_literal) (raw_string_literal) (rune_literal)] @font-lock-string-face)

             :language 'templ
             :feature 'type
             '([(package_identifier) (type_identifier)] @font-lock-type-face)

             :language 'templ
             :feature 'variable
             '((identifier) @font-lock-variable-use-face)

             :language 'templ
             :feature 'error
             :override t
             '((ERROR) @font-lock-warning-face)))

      ;; Re-initialize font-lock settings
      (setq-local treesit-font-lock-settings
                  (let* ((root-rules (append templ-ts--templ-font-lock-rules
                                             templ-ts--go-font-lock-rules))
                         (root-compiled (apply #'treesit-font-lock-rules
                                               root-rules))
                         (js-compiled js--treesit-font-lock-settings))
                    (append js-compiled root-compiled)))

      ;; Force font-lock refresh
      (when (eq major-mode 'templ-ts-mode)
        (font-lock-flush))))

  ;; Apply the fix when setting up templ-ts-mode
  (advice-add 'templ-ts--setup :after (lambda () (templ-ts--fix-font-lock-rules))))

(use-package! apheleia
  :config
  ;; Use standard Emacs functions instead of Doom macros
  (add-to-list 'apheleia-formatters '(templ-fmt . ("templ" "fmt")))
  (add-to-list 'apheleia-formatters '(nix-fmt . ("nixfmt")))

  ;; Associate modes with formatters
  (setf (alist-get 'templ-ts-mode apheleia-mode-alist) 'templ-fmt)
  (setf (alist-get 'nix-mode apheleia-mode-alist) 'nix-fmt))

(use-package! files
  :config
  (add-to-list 'completion-ignored-extensions "_templ.go")
  (add-to-list 'completion-ignored-extensions "_templ.txt"))

(use-package! projectile
  :config
  (add-to-list 'projectile-globally-ignored-file-suffixes "_templ.go")
  (add-to-list 'projectile-globally-ignored-file-suffixes "_templ.txt"))

(use-package! treesit
  :config
  (setq treesit-language-source-alist
        '((astro "https://github.com/virchau13/tree-sitter-astro")
          (css "https://github.com/tree-sitter/tree-sitter-css")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))))

(use-package! astro-ts-mode
  :hook
  (astro-ts-mode . lsp-mode)
  :config
  (add-to-list 'auto-mode-alist '("\\.astro\\'" . astro-ts-mode)))

(use-package! claude-code-ide
  :config
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools

(use-package minuet
  :hook (prog-mode . minuet-auto-suggestion-mode)
  :bind ( :map company-active-map
               ("<tab>" . '+minuet/tab)
               ("TAB" . '+minuet/tab)
               :map company-mode-map
               ("<tab>" . '+minuet/tab)
               ("TAB" . '+minuet/tab))
  :config
  (defun +minuet/tab ()
    "minuet completion."
    (interactive)
    (or
     (minuet-accept-suggestion)
     (if (bound-and-true-p emmet-mode)
         (emmet-expand-line nil))
     (indent-relative)))

  (setq minuet-provider 'openai-compatible
        minuet-auto-suggestion-debounce-delay 0
        minuet-auto-suggestion-throttle-delay 0.5
        minuet-context-window 4000
        minuet-n-completions 1)

  (plist-put minuet-openai-compatible-options :model "glm-4.6")
  (plist-put minuet-openai-compatible-options :end-point "https://api.z.ai/api/coding/paas/v4/chat/completions")
  (plist-put minuet-openai-compatible-options :api-key "ANTHROPIC_AUTH_TOKEN")
  (minuet-set-optional-options minuet-openai-compatible-options :max_tokens 64)
  (minuet-set-optional-options minuet-openai-compatible-options :temperature 0.3))

(message "=== Done Loading Config ===")


