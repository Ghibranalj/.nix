;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
                                        ;(package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
                                        ;(package! another-package
                                        ;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
                                        ;(package! this-package
                                        ;  :recipe (:host github :repo "username/repo"
                                        ;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
                                        ;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
                                        ;(package! builtin-package :recipe (:nonrecursive t))
                                        ;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
                                        ;(package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
                                        ;(package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
                                        ;(unpin! pinned-package)
;; ...or multiple packages
                                        ;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (package! evil :pin "6bed0e58dbafd75755c223a5c07aacd479386568")
(package! copilot
  :pin "4f51b3c21c42756d09ee17011201ea7d6e18ff69"
  :recipe (:host github :repo "copilot-emacs/copilot.el" :files ("*.el")))
(package! company-box
  :pin "c4f2e243fba03c11e46b1600b124e036f2be7691"
  :recipe (
           :host github
           :repo "sebastiencs/company-box"
           :files ("*.el" "images" )))
(package! emmet-mode :pin "322d3bb112fced57d63b44863357f7a0b7eee1e3")
(package! yascroll
  :pin "1aa22b2c2f4900c5c14af3821bc17fa0f7183be3"
  :recipe (
           :host github
           :repo "emacsorphanage/yascroll"
           :files ("*.el")))
(package! inheritenv :pin "b9e67cc20c069539698a9ac54d0e6cc11e616c6f")
(package! language-id :pin "dbfbc4903ffb042552b458fac76ee9f67a022036")
                                        ;(package! sidekick
                                        ;  :pin "73f514efaa0c118adfc1bd375064aceaf81009e7"
                                        ;  :recipe (
                                        ;           :type git :host github :repo "VernonGrant/sidekick.el"
                                        ;           :files ("*.el")
                                        ;           :branch "main"))
(package! verb :pin "e818377f2ceddf5670dcd9a32d3de0e8bf82a8f1")
(package! all-the-icons-completion
  :pin "4c8bcad8033f5d0868ce82ea3807c6cd46c4a198"
  :recipe (:host github
           :repo "iyefrat/all-the-icons-completion"))
;; (package! helm-swoop :pin "df90efd4476dec61186d80cace69276a95b834d2")
(package! systemd :pin "8742607120fbc440821acbc351fda1e8e68a8806")
(package! lsp-ui :pin "9e92f75147599d447f569f20e5bb1b9c8b771181")
(package! vertico-posframe :pin "047474764c6bf9f6296f8e4f959d483de6b5baf7")
(package! ivy :pin "db61f55bc281c28beb723ef17cfe74f59580d2f4" )
(package! ivy-posframe :pin "660c773f559ac37f29ccf626af0103817c8d5e30")
(package! persist :pin "706970cf44ba797d67c0a22deabf494067112dd8")
(package! daemons :pin "e1c0f5bb940b8149e0db414cc77c1ce504f5e3eb")
(package! dired-hide-dotfiles :pin "0d035ba8c5decc5957d50f3c64ef860b5c2093a1")
(package! ejc-sql :pin "1fc5a38d974aed401424ecd3b49a74e0a0ebc3bb" )
(package! async-completing-read
  :pin "9efa7165250f7d781b73d84fe2fa80510fff2b03"
  :recipe (
           :type git :host github :repo "oantolin/async-completing-read"
           :files ("*.el")
           :branch "master"))
(package! lsp-tailwindcss
  :pin "8574cb3ad2e669eebb34b4d57c3cdef5a424a9b5"
  :recipe (:host github :repo "merrickluo/lsp-tailwindcss"))
                                        ; (package! smudge :pin "")
(package! pcap-mode
  :pin "52780669af0ade136f84d73f21b4dbb7ab655416"
  :recipe (
           :host github :repo "orgcandman/pcap-mode"
           :files ("*.el")))
(package! sly :pin "c48defcf58596e035d473f3a125fdd1485593146")
;; (package! tsi :recipe (:host github :repo "orzechowskid/tsi.el" :branch "main"))
;; (package! coverlay)
;; (package! origami)
;; (package! rjsx-mode)
(package! blamer
  :pin "8a79c1f370f7c5f041c980e0b727960462c192ba"
  :recipe (:host github
           :repo "Artawower/blamer.el"))  ; Full commit hash

(package! dired-posframe :pin "1a21eb9ad956a0371dd3c9e1bec53407d685f705")
(package! which-key-posframe :pin "e4a9ce9a1b20de550fca51f14d055821980d534a")
;; (package! evil-owl)
(package! prisma-mode
  :pin "f7744a995e84b8cf51265930ce18f6a6b26dade7"
  :recipe (:host github :repo "pimeys/emacs-prisma-mode" :branch "main"))
(package! pnpm-mode :pin "ec66ba36ba6e07883b029569c33fd461d28eed75")
(package! man-posframe
  :pin "1f4d625ae8801108f31585d2b7cbf0d420c18bad" 
  :recipe ( :type git :host github :repo "Ghibranalj/man-posframe.el"
                  :files ("*.el") :branch "master"))

(package! evil-terminal-cursor-changer :pin "2358f3e27d89128361cf80fcfa092fdfe5b52fd8")
(package! auto-save
  :pin "0fb3c0f38191c0e74f00bae6adaa342de3750e83"
  :recipe (:host github :repo "manateelazycat/auto-save"))
(package! udev-mode :pin "5ca236980662141518603672ebdbdf863756da5a")

(package! persistent-scratch :pin "5ff41262f158d3eb966826314516f23e0cb86c04")

(package! scratch-posframe
  :pin "d4517a4e02a2d22b4dc6f2c6c9e54e03af265fe7"
  :recipe ( :type git :host github :repo "Ghibranalj/scratch-posframe"
                  :files ("*.el") :branch "master"))

(package! vterm-posframe
  :pin "ec0ac6474630c543348c9481c21a1606739ef046"
  :recipe ( :type git :host github :repo "Ghibranalj/vterm-posframe"
                  :files ("*.el") :branch "master"))

(package! highlight-indent-guides :pin "3205abe2721053416e354a1ff53947dd122a6941")

(package! templ-ts-mode
  :pin "020976f0cf2cf27a1a6e1b59e92c443c52b03a52"
  :recipe ( :type git :host github :repo "danderson/templ-ts-mode"
                  :files ("*.el") :branch "main"))

(package! mmm-mode :pin "b1f5c7dbdc405e6e10d9ddd99a43a6b2ad61b176"
  :recipe ( :type git :host gitub :repo "dgutov/mmm-mode"
                  :branch "master"))

(package! polymode :pin "44265e35161d77f6eaa09388ea2256b89bd5dcc8")

(package! astro-ts-mode :pin "886d692378d0da2071e710c1e6db02e5b2e0dd30")
(package! rainbow-delimiters :pin "7919681b0d883502155d5b26e791fec15da6aeca")
;; (package! persp-mode :pin "124f4430008859a75b25521c474f37aa9f75afeb")

(package! inheritenv :pin "b9e67cc20c069539698a9ac54d0e6cc11e616c6f"
  :recipe (:type git :host github :repo "purcell/inheritenv" :branch "main"))

(package! claude-code-ide :pin "32d853e20b9d245a6ee89c4a153a4e568250c62c"
  :recipe (:type git :host github :repo "manzaltu/claude-code-ide.el"
           :branch "main"))

;; (package! monet :pin "72a18d372fef4b0971267bf13f127dcce681859a"
;;   :recipe (:type git :host github :repo "stevemolitor/monet" :branch "main"))


