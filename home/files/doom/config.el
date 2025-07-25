;;; $DOOM_DIR/config.el -*- lexical-binding: t; -*-
(load! "keymap.el" doom-user-dir)
;; find file subdirectory my-packages
;; and eval every single one

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
 org-directory "~/org/"
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
 ;; doom-font (font-spec
 ;;            :family "Source Code Pro"
 ;;            :size 16)
 ;; doom-variable-pitch-font (font-spec
 ;;                           :family "Source Code Pro"
 ;;                           :size 16)
 ;; doom-big-font (font-spec
 ;;                :family "Source Code Pro"
 ;;                :size 20)
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
;;;
;;; random shit
;;;

(add-hook! prog-mode '(lambda () (display-line-numbers-mode)))

;;;
;;; use-package
;;;

;; man pages
(use-package! man
  :init
  (defun my-open-man-here (page)
    (interactive `(,(read-string "Man: " nil)))
    (man page))
  :custom
  (Man-notify-method 'pushy)
  :hook
  (Man-mode . 'my-add-buffer-to-project))

(use-package! man-posframe
  :init
  (defun my-open-man (page)
    (interactive `(,(read-string "Man: " nil)))
    (man-posframe-show page ))
  :custom
  (man-posframe-width  100)
  (man-posframe-height  30))

(use-package! evil-megasave
  :hook
  (prog-mode . evil-megasave-mode)
  (git-commit-mode . evil-megasave-mode)
  (conf-mode . evil-megasave-mode)
  (yaml-mode . evil-megasave-mode)
  (html-mode . evil-megasave-mode))

;; tremacs colors
(use-package treemacs
  :disabled
  :config
  (custom-set-faces!
    '(treemacs-root-face :foreground "#F78C6C")
    '(doom-themes-treemacs-root-face :foreground "#F78C6C")))

(use-package! yasnippet
  :hook
  (prog-mode . yas-minor-mode)
  :config
  )

;; company; make it load before copilot
(use-package! company
  :hook
  (prog-mode . company-mode)
  :custom
  (company-idle-delay
      (lambda () (if (company-in-string-or-comment) nil 0.3)))
  :config
  (add-to-list 'company-backends 'company-yasnippet))

;; Coplilot
(use-package! copilot
  :after company
  :config
  (defun +copilot/tab ()
    "Copilot completion."
    (interactive)
    (or
     (copilot-accept-completion)

     (if (bound-and-true-p emmet-mode)
         (emmet-expand-line nil))
     (indent-relative)))
  :hook (prog-mode . copilot-mode)
  :bind (("<backtab>" . 'copilot-accept-completion-by-word)
         ("<backtab>" . 'copilot-accept-completion-by-word)
         :map company-active-map
         ("<tab>" . '+copilot/tab)
         ("TAB" . '+copilot/tab)
         :map company-mode-map
         ("<tab>" . '+copilot/tab)
         ("TAB" . '+copilot/tab)))

(use-package! company-box
  :disabled
  :hook
  (company-mode . (lambda ()
                  (when my-is-gui-frame
                    company-box-mode))))

(use-package! lsp-ui-sideline
  :custom
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-code-actions t)
  (lsp-ui-sideline-show-symbol t)
  :hook (lsp-mode . lsp-ui-sideline-mode))

(use-package! lsp-ui
  :hook (prog-mode . lsp-ui-mode))

(use-package! lsp-mode
  :custom
  (lsp-headerline-breadcrumb-mode t)
  (lsp-warn-no-matched-clients nil)
  :hook
  (lsp-mode . lsp-headerline-breadcrumb-mode)
  (prog-mode . lsp-deferred)
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

(use-package! magit
  :custom
  (magit-clone-default-directory "~/Workspace/")
  ;; :hook
  ;; (magit-post-refresh . forge-pull)
  )

(use-package! consult
  :config
  (defvar my-consult--terminal-source
    (list :name     "Terminal"
          :category 'buffer
          :narrow   ?o
          :face     'consult-buffer
          :history  'buffer-name-history
          :state    #'consult--buffer-state
          :require-match t
          :items
          (lambda ()
            (mapcar #'buffer-name
                    (seq-filter
                     (lambda (x)
                       (or
                        (eq (buffer-local-value 'major-mode x) 'vterm-mode)))
                     (persp-buffer-list))))))
  (defvar my-consult--dired-source
    (list :name     "Dired"
          :category 'buffer
          :narrow   ?o
          :face     'consult-buffer
          :history  'buffer-name-history
          :state    #'consult--buffer-state
          :require-match t
          :items
          (lambda ()
            (mapcar #'buffer-name
                    (seq-filter
                     (lambda (x)
                       (or
                        (eq (buffer-local-value 'major-mode x) 'dired-mode)))
                     (persp-buffer-list))))))
  (defvar my-consult--workspace-source
    (list :name    "Workspace Buffers"
          :category 'buffer
          :narrow   ?o
          :face     'consult-buffer
          :history  'buffer-name-history
          :state    #'consult--buffer-state
          :require-match t
          :items
          (lambda ()
            (mapcar #'buffer-name
                    (seq-filter
                     (lambda (x)
                       (and
                        (not (eq (buffer-local-value 'major-mode x) 'vterm-mode))
                        (not (eq (buffer-local-value 'major-mode x) 'dired-mode))
                        (or (not (boundp 'minimap-buffer-name))
                            (not (string= (buffer-name x) minimap-buffer-name)))))
                     (persp-buffer-list))))))

  (add-to-list 'consult-buffer-sources 'my-consult--terminal-source 'append)
  (add-to-list 'consult-buffer-sources 'my-consult--workspace-source 'append)
  (add-to-list 'consult-buffer-sources 'my-consult--dired-source 'append)
  (defun my-consult-terminal ()
    "Open terminal."
    (interactive)
    (consult-buffer '(my-consult--terminal-source)))

  (defun my-consult-workspace ()
    "Switch to buffer in workspace.
Shows terminal and dired in seperate section."
    (interactive)
    (consult--multi
     '( my-consult--terminal-source my-consult--dired-source my-consult--workspace-source)
     :require-match
     (confirm-nonexistent-file-or-buffer)
     :prompt (format "Switch to buffer (%s): "
                     (+workspace-current-name))
     :history 'consult--buffer-history
     :sort nil)))

(use-package! dired
  :hook
  (dired-mode . dired-hide-dotfiles-mode)
  ;; (dired-mode . lsp-dired-mode)
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-dwim-target t)
  (delete-by-moving-to-trash t)
  (dired-mouse-drag-files t)

  :config
  (require 'dired-x)
  (defun my-dired-navigate-into ()
    "Open directory in same dired buffer. Open file in new buffer"
    (interactive)
    (let (
          (file (dired-get-filename nil t)))
      (if (file-directory-p file)
          (dired-find-alternate-file)
        (dired-find-file))))

  (evil-collection-init)
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" '(lambda () (interactive) (find-alternate-file ".."))
    ;; "l" 'dired-find-alternate-file
    "l" 'my-dired-navigate-into
    "." 'dired-hide-dotfiles-mode
    "," 'dired-posframe-show
    "s" 'my-dired-posframe-scroll-down
    "w" 'my-dired-posframe-scroll-up
    "e" 'lsp-dired-mode)
  (put 'dired-find-alternate-file 'disabled nil))

(use-package! dired-x
  :hook
  (dired-mode . dired-omit-mode)
  :config
  (setq dired-omit-files
        (concat dired-omit-files
                "node_modules"
                "\\|_templ\\.go\\'"
                "\\|_templ\\.txt\\'")))

(use-package! ivy-posframe
  :custom
  (ivy-posframe-border-width 2)
  (ivy-posframe-width 10)
  (ivy-posframe-display-functions-alist '((t . ivy-posframe-display-at-frame-top-center)))
  (ivy-posframe-parameters
   '((left-fringe . 8)
     (right-fringe . 8)))
  :config
  (define-key ivy-minibuffer-map (kbd "<escape>") 'minibuffer-keyboard-quit)
  (set-face-attribute 'ivy-posframe-border nil :background "#585858")
  (set-face-attribute 'ivy-posframe nil :background "#212121" :foreground "#EEFFFF")
  :hook
  (my-new-gui-frame . ivy-posframe-mode))

(use-package! persp-mode
  :init
  (defun my-add-buffer-to-project ()
    "Add current buffer to current project."
    (interactive)
    (persp-add-buffer (current-buffer)))
  (defun my-save-current-workspace ()
    "Save current workspace."
    (interactive)
    (+workspace/save (+workspace-current-name)))
  (defun my-delete-other-workspace ()
    (interactive)
    (dolist (workspace (+workspace-list-names))
      (unless (eq workspace (+workspace-current-name))
        (+workspace/delete workspace)))))

(use-package! daemons
  :disabled
  ;;   :config
  ;;   (evil-collection-define-key 'normal 'daemons-mode-map
  ;;     "<ret>" 'daemons-status-at-point
  ;;     "s" 'daemons-start-at-point
  ;;     "S" 'daemons-stop-at-point
  ;;     "r" 'daemons-reload-at-point
  ;;     "R" 'daemons-restart-at-point
  ;;     "e" 'daemons-enable-at-point
  ;;     "d" 'daemons-disable-at-point
  ;;     "t" 'daemons-systemd-toggle-user))

  )
(use-package! vterm
  :custom
  (vterm-always-compile-module t))

(use-package! cc-mode
  :hook
  (c-mode . (lambda ()(c-toggle-comment-style -1))))

(use-package! ccls
  :config
  (defun ccls-navigate (DIRECTION)
    (cond
     ((string= DIRECTION "D")
      (evil-window-right 1))
     ((string= DIRECTION "L")
      (evil-window-up 1))
     ((string= DIRECTION "R")
      (evil-window-down 1))
     ((string= DIRECTION "U")
      (evil-window-left 1)))))

(use-package! web-mode
  :config
  (defun +web/indent-or-yas-or-emmet-expand ()
    "decide if copilot, yas or emmet should expand."
    (interactive)
    (or (emmet-expand-line nil)
        ;; (copilot-accept-completion)
        (indent-relative))))

(use-package! projectile
  :config
  (add-to-list 'projectile-globally-ignored-directories "tmp")
  (add-to-list 'projectile-globally-ignored-directories "vendor")
  (add-to-list 'projectile-globally-ignored-directories "CMakeFiles")
  (add-to-list 'projectile-globally-ignored-directories "build")
  (add-to-list 'projectile-globally-ignored-directories "^.*vendor.*$")
  (add-to-list 'projectile-globally-ignored-directories "web-legacy")
  (add-to-list 'projectile-globally-ignored-directories ".devenv"))

(use-package! dap-mode
  :after lsp-mode
  :config
  (dap-auto-configure-mode))

;; Git Blame
(use-package blamer
  :bind (("s-i" . blamer-show-commit-info))
  :defer 20
  :custom
  (blamer-idle-time 0.2)
  (blamer-min-offset 40)
  (blamer-author-formatter "  ✎ %s ")
  (blamer-datetime-formatter "[%s] ")
  :custom-face
  (blamer-face ((t :foreground "#805d96"
                   :background nil
                   :height 80
                   :italic t)))
  :config
  (global-blamer-mode 0))

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
  (evil-define-command my-evil-man (arg)
    (interactive "<a>")
    (if arg
        (my-open-man arg)
      (call-interactively 'my-open-man)))
  (evil-define-command my-evil-chmod (mode)
    (interactive "<a>")
    (my-chmod-this-file mode))
  (evil-ex-define-cmd "man" 'my-evil-man)
  (evil-ex-define-cmd "chmod" 'my-evil-chmod)
  (evil-ex-define-cmd "sr" 'projectile-replace-regexp)
  (evil-ex-define-cmd "dired" 'dired-jump)
  (evil-ex-define-cmd "systemd" 'daemons)
  (evil-ex-define-cmd "mkdir" 'my-evil-mkdir))

(use-package! read-string-posframe
  :hook
  (my-new-gui-frame . read-string-posframe-mode))

(use-package! which-key-posframe
  :custom
  (which-key-posframe-poshandler 'my-poshandler)
  (which-key-posframe-parameters
   '((left-fringe . 10)
     (right-fringe . 20)
     ))
  :hook
  (my-new-gui-frame . which-key-posframe-mode))

(use-package! rainbow-indent-and-delimeters
  :init
  (rainbow-indent-and-delimiters-mode 1))


(use-package! smudge
  :disabled
  ;;  :ensure t
  ;;  :init
  ;;  (if (file-exists-p "~/.spotify-secrets.el")
  ;;      (load "~/.spotify-secrets.el")
  ;;    (progn
  ;;      (message "No spotify secrets found.")
  ;;      (setq spotify-client-id nil)
  ;;      (setq spotify-client-secret nil)))
  ;;  (and spotify-client-id spotify-client-secret
  ;;       (global-smudge-remote-mode 1))
  ;;  :custom
  ;;  (smudge-oauth2-callback-port "3725")
  ;;  (smudge-oauth2-client-id  spotify-client-id)
  ;;  (smudge-oauth2-client-secret spotify-client-secret)
  ;;  :bind
  ;;  (:map smudge-track-search-mode-map
  ;;        ("RET" . smudge-track-select))
  ;;  :config
  ;;  (defun my-pause-music-start-again (time)
  ;;    (interactive '("2 min"))
  ;;    (unless (featurep 'smudge)
  ;;      (my-start-smudge))
  ;;    (smudge-api-pause)
  ;;    (run-at-time time nil #'smudge-api-play))
  ;;  ;;;
  ;;  (defun my-smudge-set-volume (volume)
  ;;    (interactive `(,(read-string "Volume: " nil)))
  ;;    (if (stringp volume)
  ;;        (setq volume (string-to-number volume)))
  ;;    (when (and  smudge-selected-device-id (<= volume 100) (>= volume 0) )
  ;;      (smudge-api-set-volume smudge-selected-device-id volume))))
  )

(use-package! evil-terminal-cursor-changer
  :hook
  (my-new-tty-frame . evil-terminal-cursor-changer-activate))

;; (use-package! auto-save
;;   :custom
;;   (auto-save-idle 5)
;;   (auto-save-silent t)
;;   (auto-save-delete-trailing-whitespace nil)
;;   :config
;;   (auto-save-enable)
;;   )

(use-package! prisma-mode
  :disabled
  :mode "\\.prisma\\'"
  :hook (prisma-mode . lsp-mode))

(use-package! scratch-posframe
  :custom
  (scratch-posframe-parameters
   '((left-fringe . 10)
     (right-fringe . 20)
     ))
  (scratch-posframe-buffer-setup
   #'(lambda ()
       (setq cursor-type 'box)))
  :config
  (defun my-open-scratch ()
    (interactive)
    (if my-is-gui-frame
        (call-interactively 'scratch-posframe-toggle)
      (call-interactively 'doom/open-scratch-buffer))))

(use-package! persistent-scratch
  :config
  (persistent-scratch-setup-default)
  (persistent-scratch-autosave-mode 1))

(use-package! vterm-posframe
  :custom
  (vterm-posframe-parameters
   '((left-fringe . 10)
     (right-fringe . 20)
     ))
  (vterm-posframe-vterm-func '+vterm/toggle)
  (vterm-posframe-vterm-func-interactive t))

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
  ;; Define the templ formatter
  (pushnew! apheleia-formatters
           '(templ-fmt . ("templ" "fmt")))
  (pushnew! apheleia-formatters
            '(nix-fmt . ("nixfmt")))
 ;; Associate templ-ts-mode with the formatter
  (setf (alist-get 'templ-ts-mode apheleia-mode-alist) 'templ-fmt)
  (setf (alist-get 'nix-mode apheleia-mode-alist) 'nix-fmt))

;; (use-package!  emmet-mode
;;   :config
;;   (templ-ts-mode . emmet-mode))

(use-package! lsp-tailwindcss
  :config
  (add-to-list 'lsp-tailwindcss-major-modes 'templ-ts-mode))

(use-package! all-the-icons
  :config
  (add-to-list 'all-the-icons-icon-alist
               '("\\.templ\\'" all-the-icons-fileicon "html5" :face all-the-icons-orange)))

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

(message "=== Done Loading Config ===")
