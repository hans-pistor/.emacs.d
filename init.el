;; init.el --- Hans Pistor's init.el -*- lexical-binding: t; -*-


(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
	  (expand-file-name
	   (file-name-directory (or load-file-name byte-compile-current-file))))))


;; Initialize package manager for compile time
(eval-and-compile
  (customize-set-variable
   'package-archives '(("org"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :doc "Use leaf as a package manager"
    :url "https://github.com/conao3/leaf.el"
    :ensure t
    :init
    (leaf el-get
      :ensure t
      :custom
      (el-get-notify-type       . 'message)
      (el-get-git-shallow-clone . t))
    (leaf hydra :ensure t)
    :config
    (leaf-keywords-init)))


;; Compile
(eval-and-compile
  (leaf *byte-compile
    :custom
    (byte-compile-warnings . '(not free-vars))
    (debug-on-error        . nil)))

(leaf *native-compile
  :doc "Native compile by gccemacs"
  :url "https://www.emacswiki.org/emacs/GccEmacs"
  :if (and (fboundp 'native-comp-available-p))
  :custom
  (comp-deferred-compilation . nil)
  (comp-speed                . 5)
  (comp-num-cpus             . 4)
  :config
  (native-compile-async "~/.emacs.d/early-init.el" 4 t)
  (native-compile-async "~/.emacs.d/init.el" 4 t)
  ;;(native-compile-async "~/.emacs.d/elpa/" 4 t)
  )


(leaf package-utils
  :doc "Interactive package manager"
  :url "https://github.com/Silex/package-utils"
  :ensure t)

(leaf no-littering
  :doc "Keep .emacs.d clean"
  :url "https://github.com/emacscollective/no-littering"
  :custom `((custom-file . ,(no-littering-expand-etc-file-name "custom.el")))
  :ensure t
  :require t)


(leaf *to-be-quiet
  :doc "Quiet the annoying messages"
  :preface
  (defun display-startup-echo-area-message()
    "No startup message"
    (message ""))
  :config
  (defalias 'yes-or-no-p #'y-or-n-p))


(leaf *formatting
  :custom
  (truncate-lines . t)
  (require-final-newline . t)
  (tab-width . 2)
  (indent-tabs-mode . nil))

(leaf *autorevert
  :doc "Revert changes when the local file is updated"
  :global-minor-mode global-auto-revert-mode
  :custom (auto-revert-interval . 0.1))

(leaf *recovery
  :doc "Save place of cursor"
  :global-minor-mode save-place-mode)

(leaf *tramp
  :doc "Edit remote files via SSH/SCP"
  :custom
  (tramp-auto-save-directory . "~/.emacs.d/.cache/tramp/")
  (tramp-chunksize . 2048))

(leaf *savehist
  :doc "save history of minibuffer"
  :global-minor-mode savehist-mode)

(leaf *recentf
  :doc "Record open file history"
  :global-minor-mode recentf-mode
  :custom
  (recentf-max-saved-items . 20000)
  (recentf-max-menu-items  . 20000)
  (recentf-auto-cleanup    . 'never)
  (recentf-exclude
   . '((expand-file-name package-user-dir)
       ".cache"
       "cache"
       "bookmarks"
       "recentf"
       "*.png"
       "*.jpg"
       "*.jpeg"
       ".org_archive"
       "COMMIT_EDITMSG\\'")))

(leaf *large-file
  :doc "Adjust large file threshold"
  :custom
  (large-file-warning-threshold . 1000000))

(leaf *delsel
  :doc "Replace the region just by typing text or delete by hitting the DEL key"
  :global-minor-mode delete-selection-mode)

(leaf undo-fu
  :doc "Undo and Redo operations"
  :url "https://github.com/emacsmirror/undo-fu"
  :ensure t
  :bind*
  ("C-/" . undo-fu-only-undo)
  ("M-/" . undo-fu-only-redo))

;; Window System

(leaf *fonts-for-gui
  :doc "Set font & font size"
  :if (window-system)
  :config
  (set-face-attribute
   'default nil
   :family "FuraMono NF"
   :height 140
   :weight 'normal
   :width 'normal))


(leaf smartparens
  :ensure t
  :require smartparens-config
  :global-minor-mode smartparens-global-mode)

(leaf *general-cursor-options
  :custom
  (kill-whole-line  . t)
  (track-eol        . t)
  (line-move-visual . nil))

(leaf mwim
  :doc "move-where-i-mean cursor to beginning/end of line/code"
  :url "https://github.com/alezost/mwim.el"
  :ensure t
  :bind*
  (("C-a" . mwim-beginning-of-code-or-line)
   ("C-e" . mwim-end-of-code-or-line)))

(leaf *window-maximizer
  :doc "Maximize the current window"
  :if (window-system)
  :custom
  (is-window-maximized . nil)
  :preface
  (defun toggle-window-maximize()
    (interactive)
    (progn
      (if is-window-maximized
          (balance-windows)
        (maximize-window))

      (setq is-window-maximized
            (not is-window-maximized)))))


(leaf yasnippet
  :doc "Templating system"
  :url "https://github.com/joaotavora/yasnippet"
  :ensure t
  :hook (prog-mode-hook . yas-minor-mode)
  :custom (yas-snippet-dirs . '("~/.emacs.d/snippets"))
  :config (yas-reload-all))

(leaf company
  :doc "Completion framework"
  :url "https://company-mode.github.io/"
  :ensure t
  :hook (prog-mode-hook . company-mode)
  :bind
  ((:company-active-map
    ("C-n" . company-select-next)
    ("C-p" . company-select-previous)
    ("<tab>" . company-complete-common-or-cycle)
    ("<return>" . nil))
   (:company-search-map
    ("C-p" . company-select-previous)
    ("C-n" . company-select-next)))
  :custom
  (company-idle-delay . 0)
  (company-echo-delay . 0)
  (company-ignore-case . t)
  (company-selection-wrap-around . t)
  (company-minimum-prefix-length . 1)
  :custom-face
  (company-tooltip . '((t (:background "#323445"))))
  (company-template-field . '((t (:foreground "#ff79c6"))))
  (yas-field-highlight-face . '((t (:foreground "#ff79c6")))))

(leaf git-modes
  :doc "Modes for git configuration files"
  :url "https://github.com/magit/git-modes"
  :ensure t)

(leaf magit
  :doc "Complete text-based user interface to git"
  :url "https://magit.vc/"
  :ensure t
  :init
  (setq magit-auto-revert-mode nil))

(leaf git-gutter
  :doc "Show git status in fringe & operate hunks"
  :url "https://github.com/emacsorphanage/git-gutter"
  :ensure t
  :global-minor-mode global-git-gutter-mode
  :custom
  (git-gutter:modified-sign . "┃")
  (git-gutter:added-sign    . "┃")
  (git-gutter:deleted-sign  . "┃")
  :custom-face
  (git-gutter:modified . '((t (:foreground "#f1fa8c"))))
  (git-gutter:added    . '((t (:foreground "#50fa7b"))))
  (git-gutter:deleted  . '((t (:foreground "#ff79c6")))))


(leaf lsp-mode
  :doc "Client for the language server protocol"
  :url "https://emacs-lsp.github.io"
  :ensure t
  :custom
  (lsp-auto-guess-root . t)
  (lsp-modeline-diagnostics-enable . t)
  (lsp-headerline-breadcrumb-enable . nil)
  :bind
  (:lsp-mode-map
   ("C-c r" . lsp-rename)
   ("C-c C-c" . lsp-execute-code-action))
  :hook
  (lsp-mode-hook
   . (lambda ()
       (setq-local
        company-backends '((company-yasnippet company-capf :separate))))))

(leaf lsp-ui
  :doc "UI integrations for LSP mode"
  :url "https://github.com/emacs-lsp/lsp-ui"
  :ensure t
  :hook (lsp-mode-hook . lsp-ui-mode)
  :custom
  (lsp-ui-flycheck-enable     . t)
  (lsp-ui-sideline-enable     . t)
  (lsp-ui-sideline-show-hover . nil)
  (lsp-ui-imenu-enable        . nil)
  (lsp-ui-peek-fontify        . 'on-demand)
  (lsp-ui-peek-enable         . t)
  (lsp-ui-doc-enable          . nil)
  (lsp-ui-doc-max-height      . 12)
  (lsp-ui-doc-max-width       . 56)
  (lsp-ui-doc-position        . 'at-point)
  (lsp-ui-doc-border          . "#323445")
  :custom-face
  (lsp-ui-doc-background . '((t (:background "#282a36"))))
  (lsp-ui-doc-header     . '((t (:foreground "#76e0f3" :weight bold))))
  (lsp-ui-doc-url        . '((t (:foreground "#6272a4"))))
  :bind
  ((:lsp-mode-map
    ("C-c C-r"   . lsp-ui-peek-find-references)
    ("C-c C-j"   . lsp-ui-peek-find-definitions)
    ("C-c C-M-j" . xref-find-definitions-other-window)
    ("C-c i"     . lsp-ui-peek-find-implementation)
    ("C-c m"     . counsel-imenu)
    ("C-c M"     . lsp-ui-imenu)
    ("C-c s"     . toggle-lsp-ui-sideline)
    ("C-c d"     . toggle-lsp-ui-doc))
   (:lsp-ui-doc-mode-map
    ("q"         . toggle-lsp-ui-doc)
    ("C-i"       . lsp-ui-doc-focus-frame)))
  :init
  (defun toggle-lsp-ui-sideline ()
    (interactive)
    (if lsp-ui-sideline-show-hover
        (progn
          (setq lsp-ui-sideline-show-hover nil)
          (message "sideline-hover disabled :P"))
      (progn
        (setq lsp-ui-sideline-show-hover t)
        (message "sideline-hover enabled :)"))))
  (defun toggle-lsp-ui-doc ()
    (interactive)
    (if lsp-ui-doc-mode
        (progn
          (lsp-ui-doc-mode -1)
          (lsp-ui-doc--hide-frame)
          (message "lsp-ui-doc disabled :P"))
      (progn
        (lsp-ui-doc-mode 1)
        (message "lsp-ui-doc enabled :)")))))


(leaf rustic
  :doc "Rust development environment"
  :url "https://github.com/brotzeit/rustic"
  :ensure t
  :require t
  :hook (rust-mode-hook . lsp-deferred)
  :bind
  (:rust-mode-map
   ("C-c C-n" . rust-run)
   ("C-c C-a" . quickrun-with-arg))
  :custom
  (rustic-format-trigger . 'on-save)
  (rustic-babel-auto-wrap-main . t))

(leaf org
  :doc "org-mode"
  :url "https://orgmode.org"
  :mode "\\.org\\'"
  :ensure t
  :init
  (setq
   org-directory "C:/Users/hpist/Documents/org/"
   org-notes-directory (concat org-directory "notes/")
   org-default-notes-file (concat org-directory "notes.org")
   org-agenda-directory (concat org-directory "agenda/"))
  :bind
  ((:org-mode-map
    ("C-c i" . org-clock-in)
    ("C-c o" . org-clock-out)))

  :custom
  (org-src-preserve-indentation . nil)
  (org-edit-src-content-indentation . 0)
  (org-src-fontify-natively . t)
  (org-image-actual-width . 500)
  (org-startup-folded . 'content))

(leaf org-theme
  :doc "Theme for org-mode"
  :custom
  (org-todo-keyword-faces
   . '(("WAIT" . (:foreground "#6272a4" :weight bold :width condensed))
       ("NEXT" . (:foreground "#f1fa8c" :weight bold :width condensed))))
  :custom-face
  (org-level-1         . '((t (:inherit outline-1 :height 1.2))))
  (org-level-2         . '((t (:inherit outline-2 :weight normal))))
  (org-level-3         . '((t (:inherit outline-3 :weight normal))))
  (org-level-4         . '((t (:inherit outline-4 :weight normal))))
  (org-level-5         . '((t (:inherit outline-5 :weight normal))))
  (org-level-6         . '((t (:inherit outline-6 :weight normal))))
  (org-link            . '((t (:foreground "#f1fa8c" :underline nil :weight normal))))
  (org-document-title  . '((t (:foreground "#f8f8f2"))))
  (org-list-dt         . '((t (:foreground "#bd93f9"))))
  (org-footnote        . '((t (:foreground "#76e0f3"))))
  (org-special-keyword . '((t (:foreground "#6272a4"))))
  (org-drawer          . '((t (:foreground "#44475a"))))
  (org-checkbox        . '((t (:foreground "#bd93f9"))))
  (org-tag             . '((t (:foreground "#6272a4"))))
  (org-meta-line       . '((t (:foreground "#6272a4"))))
  (org-date            . '((t (:foreground "#8995ba"))))
  (org-priority        . '((t (:foreground "#ebe087"))))
  (org-todo            . '((t (:foreground "#51fa7b" :weight bold :width condensed))))
  (org-done            . '((t (:background "#373844" :foreground "#216933" :strike-through nil :weight bold :width condensed)))))

(leaf org-bullets
  :doc "Change bullet icons"
  :url "https://github.com/sabof/org-bullets"
  :ensure  t
  :hook   (org-mode-hook . org-bullets-mode)
  :custom (org-bullets-bullet-list . '("" "" "" "" "" "" "" "" "" "")))

(leaf org-bullets
  :doc "Change bullet icons"
  :url "https://github.com/sabof/org-bullets"
  :ensure  t
  :hook   (org-mode-hook . org-bullets-mode)
  :custom (org-bullets-bullet-list . '("" "" "" "" "" "" "" "" "" "")))

(leaf org-modern
  :doc "To Be Modern Looks"
  :url "https://github.com/minad/org-modern"
  :ensure t
  :hook (org-mode-hook . org-modern-mode)
  :custom
  (org-modern-hide-stars     . nil)
  (org-modern-progress       . nil)
  (org-modern-todo           . nil)
  (org-modern-block          . nil)
  (org-modern-table-vertical . 1)
  (org-modern-timestamp      . t)
  ;; use nerd font icons
  (org-modern-star           . ["" "" "" "" "" "" "" "" "" ""])
  (org-modern-priority       . '((?A . "") (?B . "") (?C . "")))
  (org-modern-checkbox       . '((?X . "") (?- . "") (?\s . "")))
  :custom-face
  (org-modern-date-active   . '((t (:background "#373844" :foreground "#f8f8f2" :height 0.75 :weight light :width condensed))))
  (org-modern-time-active   . '((t (:background "#44475a" :foreground "#f8f8f2" :height 0.75 :weight light :width condensed))))
  (org-modern-date-inactive . '((t (:background "#373844" :foreground "#b0b8d1" :height 0.75 :weight light :width condensed))))
  (org-modern-time-inactive . '((t (:background "#44475a" :foreground "#b0b8d1" :height 0.75 :weight light :width condensed))))
  (org-modern-tag           . '((t (:background "#44475a" :foreground "#b0b8d1" :height 0.75 :weight light :width condensed))))
  (org-modern-statistics    . '((t (:foreground "#6272a4" :weight light :width condensed)))))


(leaf *org-agenda
  :doc "TODO & schedule management system"
  :url "https://orgmode.org/manual/Agenda-Views.html"
  :after org
  :preface
  (defun org-clock-out-save-save()
    "Save buffers and stop clock."
    (ignore-errors (org-clock-out) t)
    (save-some-buffers t))
  (defun color-org-agenda-header (tag col)
    "Sets color to org-agenda header with the specified tag."
    (interactive)
    (goto-char (point-min))
    (while (re-search-forward tag nil t)
      (add-text-properties (match-beginning 0) (point-at-eol) '(face (:foreground ,col)))))
  :hook
  (kill-emacs-hook . org-clock-out-and-save)
  (org-agenda-finalize-hook
   . (lambda ()
       (save-excursion
         (color-org-agenda-header "Event:" "#76e0f3")
         (color-org-agenda-header "Routine:" "#f1fa8c"))))
  :custom
  (org-agenda-span . 'day)
  (org-agenda-current-time-string . "← now")
  (org-clock-out-remove-zero-time-clocks . t)
  (org-agenda-log-mode-items . (quote (closed clock)))
  (org-agenda-time-grid . '((daily today require-timed)
                            (0900 01000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100 2200 2300 2400)
                            "-" "────────────────"))
  (org-agenda-files
   . '("c:/Users/hpist/Documents/org/agenda/inbox.org"))

  :custom-face
  (org-scheduled-today . '((t (:foreground "#f8f8f2")))))

(leaf ox-hugo
  :doc "Export ORG to hugo"
  :url "https://ox-hugo.scripter.co/"
  :after ox
  :ensure t
  :require t)

(leaf org-protocol
  :doc "Integrate with other applications"
  :url "https://orgmode.org/worg/org-contrib/org-protocol.html"
  :if (window-system)
  :require org-protocol)


(leaf *org-hydra
  :doc "Hydra templating for org metadata"
  :bind
  ((:org-mode-map
    :package org
    ("#" . insert-or-open-org-hydra)))
  :preface
  (defun insert-or-open-org-hydra ()
    (interactive)
    (if (or (region-active-p) (looking-back "^\s*" 1))
        (*org-hydra/body)
      (self-insert-command 1)))

  :pretty-hydra
   ((:title " Org Mode" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Header"
    (("t" (insert "#+title: ")       "title")
     ("l" (insert "#+lang: ")        "language")
     ("u" (insert "#+setupfile: ~/doc/setup.org") "setupfile")
     ("i" (insert "#+include: ")     "include")
     ("o" (insert "#+options: ")     "options")
     ("a" (insert (format-time-string "#+lastmod: [%Y-%m-%d %a %H:%M]" (current-time))) "lastmod"))
    "Hugo"
    (("d" (insert "#+draft: true")    "draft")
     ("S" (insert "#+stale: true")    "stale")
     ("m" (insert "#+menu: pin")      "pinned")
     ("g" (insert "#+tags[]: ")       "tags")
     ("x" (insert "#+hugo_base_dir: ~/Developments/src/github.com/Ladicle/blog") "base-dir")
     ("s" (insert "#+hugo_section: post") "section"))
    "Book"
    (("p" (insert "#+progress: true") "progress")
     ("f" (insert "#+format: PDF")    "format"))
    "Inline"
    (("h" (insert "#+html: ")         "HTML")
     ("r" (insert "#+attr_html: ")    "attributes")
     ("c" (insert "#+caption: ")      "caption")
     ("n" (insert "#+name: ")         "name")
     ("w" (insert (concat "{{< tweet user=\"Ladicle\" id=\"" (read-string "TweetID ⇢ ") "\" >}}")) "tweet shortcode"))
    "Others"
    (("#" self-insert-command "#")
     ("." (insert (concat "#+" (read-string "metadata: ") ": ")) "#+<metadata>:")))))



(leaf doom-themes
  :doc "Megapack of themes"
  :url "https://github.com/doomemacs/themes"
  :ensure t
  :defer-config
  (let ((display-table (or standard-display-table (make-display-table))))
    (set-display-table-slot display-table 'vertical-border (make-glyph-code ?│))
    (setq standard-display-table display-table))
  :config
  (load-theme 'doom-dracula t)
  (doom-themes-neotree-config)
  (doom-themes-org-config))
(leaf *hydra-theme
  :doc "Make emacs bindings that stick around"
  :url "https://github.com/abo-abo/hydra"
  :custom-face
  (hydra-face-red      . '((t (:foreground "#bd93f9"))))
  (hydra-face-blue     . '((t (:foreground "#8be9fd"))))
  (hydra-face-pink     . '((t (:foreground "#ff79c6"))))
  (hydra-face-teal     . '((t (:foreground "#61bfff"))))
  (hydra-face-amaranth . '((t (:foreground "#f1fa8c")))))

(leaf major-mode-hydra
  :doc "Use pretty-hydra to define templates easily"
  :url "https://github.com/jerrypnz/major-mode-hydra.el"
  :ensure t
  :require pretty-hydra)

(leaf which-key
  :doc "Displays available keybindings in popup"
  :url "https://github.com/justbur/emacs-which-key"
  :ensure t
  :global-minor-mode which-key-mode)

(leaf visual-fill-column
  :doc "Centering & Wrap text visually"
  :url "https://codeberg.org/joostkremers/visual-fill-column"
  :ensure t
  :hook ((markdown-mode-hook org-mode-hook) . visual-fill-column-mode)
  :custom
  (visual-fill-column-width . 100)
  (visual-fill-column-center-text . t))

(leaf display-fill-column-indicator-mode
  :doc "Indicate maximum colum"
  :url "https://www.emacswiki.org/emacs/FillColumnIndicator"
  :hook ((markdown-mode-hook git-commit-mode-hook) . display-fill-column-indicator-mode))

(leaf display-line-numbers
  :doc "Display line number"
  :url "https://www.emacswiki.org/emacs/LineNumbers"
  :hook (terraform-mode-hook . display-line-numbers-mode))

(leaf rainbow-mode
  :doc "Color letter that indicate the color"
  :url "https://elpa.gnu.org/packages/rainbow-mode.html"
  :ensure t
  :hook (emacs-lisp-mode-hook . rainbow-mode))

(leaf rainbow-delimiters
  :doc "Display brackets in rainbow"
  :url "https://www.emacswiki.org/emacs/RainbowDelimiters"
  :ensure t
  :hook (prog-mode-hook . rainbow-delimiters-mode))

(leaf *paren
  :doc "Highlight paired brackets"
  :global-minor-mode show-paren-mode
  :custom
  (show-paren-style . 'mixed)
  (show-paren-when-point-inside-paren . t)
  (show-paren-when-point-in-periphery . t)
  :custom-face
  (show-paren-match . '((nil (:background "#44475a" :foreground "#f1fa8c")))))


(leaf *highlight-whitespace
  :doc "highlight trailing whitespace"
  :hook
  ((prog-mode-hook org-mode-hook)
   . (lambda ()
       (interactive)
       (setq show-trailing-whitespace t))))

(leaf highlight-indent-guides
  :doc "Display structure for easy viewing"
  :url "https://github.com/DarthFennec/highlight-indent-guides"
  :ensure t
  :hook (prog-mode-hook . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-auto-enabled . t)
  (highlight-indent-guides-responsive . t)
  (highlight-indent-guides-method . 'bitmap)
  :config
  (highlight-indent-guides-auto-set-faces))

(leaf projectile
  :doc "Project navigation and management library"
  :url "https://github.com/bbatsov/projectile"
  :ensure t
  :global-minor-mode projectile-mode)

(leaf vertico
  :doc "Completion interface"
  :url "https://github.com/minad/vertico"
  :global-minor-mode vertico-mode
  :ensure t
  :custom
  (vertico-cycle . t)
  (vertico-count . 18))

(leaf consult
  :doc "Generate completion candidates and provide commands for completion"
  :url "https://github.com/minad/consult"
  :ensure t
  :bind
  ("M-y" . consult-yank-pop)
  ("C-M-s" . consult-line)
  :custom
  (consult-async-min-input . 1))

(leaf marginalia
  :doc "Adds marginalia to consult candidates"
  :url "https://github.com/minad/marginalia"
  :global-minor-mode marginalia-mode
  :ensure t
  :custom-face
  (marginalia-documentation . '((t (:foreground "#6272a4")))))

(leaf orderless
  :doc "Completion style to match multiple regexps"
  :url "https://github.com/oantolin/orderless"
  :ensure t
  :preface
  (defun flex-if-apostrophe (pattern _index _total)
    (when (string-suffix-p "'" pattern)
      '(orderless-flex . ,(substring pattern 0 -1))))
  (defun without-if-bang (pattern _index _total)
    (cond
     ((equal "!" pattern)
      '(orderless-literal . ""))
     ((string-prefix-p "!" pattern)
      '(orderless-without-literal . ,(substring pattern 1)))))

  :custom
  (completion-styles . '(orderless))
  (orderless-style-dispatchers . '(flex-if-apostrophe without-if-bang)))


(leaf *hydra-git
  :bind
  ("M-g" . *hydra-git/body)
  :pretty-hydra
  ((:title " Git" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Basic"
    (("w" magit-checkout "checkout")
     ("s" magit-status "status")
     ("b" magit-branch "branch")
     ("F" magit-pull "pull")
     ("f" magit-fetch "fetch")
     ("A" magit-apply "apply")
     ("c" magit-commit "commit")
     ("P" magit-push "push"))
    ""
    (("d" magit-diff "diff")
     ("l" magit-log "log")
     ("r" magit-rebase "rebase")
     ("z" magit-stash "stash")
     ("!" magit-run "run shell command")
     ("y" magit-show-refs "references"))
    "Hunk"
    (("," git-gutter:previous-hunk "previous" :exit nil)
     ("." git-gutter:next-hunk "next" :exit nil)
     ("g" git-gutter:stage-hunk "stage")
     ("v" git-gutter:revert-hunk "revert")
     ("p" git-gitter:popup-hunk "popup")))))

(leaf *hydra-shortcuts
  :doc "General shortcuts"
  :bind ("M-o" . *hydra-shortcuts/body)
  :pretty-hydra
  ((:title " Shortcuts" :color blue :quit-key "q" :foreign-keys warn :separator "-")
   ("Split"
    (("-" split-window-vertically "vertical")
     ("/" split-window-ho rizontally "horizontal"))
    "Window"
    (("o" other-window "o" :exit nil)
     ("d" kill-current-buffer "close")
     ("D" kill-buffer-and-window "kill")
     ("O" delete-other-windows "close others"))
    "Buffer"
    (("b" consult-buffer "open")
     ("B" consult-buffer-other-window "open other")
     ("R" (switch-to-buffer (get-buffer-create "*scratch*")) "scratch")
     ("," previous-buffer "previous" :exit nil)
     ("." next-buffer "next" :exit nil))
    "File"
    (("r" consult-buffer "recent")
     ("f" consult-find "find"))
    "Org"
    (("c" org-capture "capture")
     ("a" org-agenda "agenda")
     ("1" calendar))
    "Projectile"
    (("p" projectile-switch-project "projects")))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(leaf)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

