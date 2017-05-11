;;; bootstrap use-package

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;; load secrets
(load-file "~/.emacs.d/lisp/secrets.el")

;;; Actual packages

(use-package avy
  :bind ("C-t" . avy-goto-char)
  :init
  (setq avy-keys
        (nconc (number-sequence ?a ?z)
               (number-sequence ?A ?Z)
               (number-sequence ?1 ?9)
               '(?0))))

(use-package cargo)

(use-package column-marker
  :init
  (add-hook 'prog-mode-hook (lambda () (column-marker-1 79))))

(use-package company
  :init
  (setq company-global-modes '(not shell-mode gud-mode))
  (setq company-dabbrev-downcase nil)
  :config
  (define-key company-active-map (kbd "TAB") nil)
  (define-key company-active-map [tab] nil)
  (define-key company-active-map (kbd "RET") nil)
  (define-key company-active-map [return] nil)
  (global-company-mode))

(use-package compile
  :init
  (setq compilation-always-kill t)
  (setq compilation-ask-about-save nil))

(use-package counsel)

(use-package dirtrack
  :init
  (setq dirtrack-list '(".*?:\(.*?\)]" 1))
  :config
  (dirtrack-mode 1))

(use-package elm-mode
  :init
  (setq elm-sort-imports-on-save t)
  (setq elm-format-on-save t)
  (add-to-list 'company-backends 'company-elm)
  (add-hook 'elm-mode-hook 'elm-oracle-setup-completion))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package flycheck
   :init
   (setq flycheck-disabled-checkers '(emacs-lisp emacs-lisp-checkdoc))
   (setq flycheck-emacs-lisp-load-path 'inherit)
   (setq flycheck-display-errors-function 'nil)
   (setq flycheck-standard-error-navigation 'nil))

(use-package haskell-mode)

(use-package hledger-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.journal\\'" . hledger-mode))
  (add-to-list 'company-backends 'hledger-company))

(use-package intero
  :init
  (defun anders-intero-mode-unless-global-project ()
    "Run intero-mode iff we're in a project with a stack.yaml"
    (interactive)
    (unless (string-match-p
             (regexp-quote "global")
             (shell-command-to-string "stack path --project-root --verbosity silent"))
      (intero-mode)))
  (add-hook 'haskell-mode-hook 'anders-intero-mode-unless-global-project))

(use-package ivy
  :config
  (ivy-mode 1))

(use-package magit
  :init
  (setq magit-commit-show-diff nil)
  (setq magit-delete-by-moving-to-trash nil)
  (setq magit-diff-expansion-threshold 2.0)
  (setq magit-diff-use-overlays nil)
  (setq magit-revert-buffers t)
  (setq magit-use-overlays nil))

(use-package man
  :init
  (setq Man-width 80)
  (setq Man-notify-method 'pushy))

(use-package markdown-mode
  :init
  (add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))

(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package nix-mode)

(use-package org
  :bind (("C-c l" . org-store-link)
         ("C-c c" . org-capture)
         ("C-c a" . anders-org-agenda)
         ("C-c b" . org-iswitchb))
  :init
  (setq org-read-date-force-compatible-dates nil)
  (setq org-agenda-include-diary t)
  (setq org-default-notes-file "~org/notes.org")
  (setq org-archive-location "~/org/archive.org::")
  (setq org-agenda-files
        '("~/org/todo.org"
          "~/org/gcal.org"
          "~/org/orgzly.org"))
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-agenda-start-on-weekday nil)
  (setq org-agenda-window-setup 'current-window)
  (setq org-capture-templates
        '(("t" "Todo" entry
           (file+headline "~/org/todo.org" "Tasks")
           "* TODO %?\n  %i")
          ("m" "Meeting" entry
           (file+headline "~/org/todo.org" "People")
           "* MEET %?\n  %i")
          ("h" "Habit" entry
           (file+headline "~/org/todo.org" "Tasks")
           "* TODO %?\n  %i\n  SCHEDULED:\n  :PROPERTIES:\n    :STYLE: habit\n  :END:")
          ("j" "Journal" entry
           (file+datetree "~/org/journal.org")
           "* %?\nEntered on %U\n  %i")
          ("n" "Note" entry
           (file+datetree "~/org/notes.org")
           "* %U %?")))
  (setq org-default-notes-file "~org/notes.org")
  (setq org-enforce-todo-dependencies t)
  (setq org-fast-tag-selection-single-key t)
  (setq org-from-is-user-regexp nil)
  (setq org-hide-leading-stars t)
  (setq org-journal-dir "~/org/journal")
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-modules
        '(org-bbdb
          org-bibtex
          org-docview
          org-gnus
          org-habit
          org-info
          org-irc
          org-mhe
          org-rmail
          org-w3m))
  (setq org-habit-graph-column 80)
  (setq org-habit-show-habits-only-for-today nil)
  (setq org-agenda-sorting-strategy
        '((agenda time-up habit-down priority-down category-keep)
         (todo priority-down category-keep)
         (tags priority-down category-keep)
         (search category-keep)))
  (setq org-read-date-popup-calendar nil)
  (setq org-refile-targets
        '(("todo.org" :maxlevel . 1)))
  (setq org-todo-keywords
        '((sequence "TODO(t!)" "|" "DEFERRED(f!)" "CANCELLED(c!)" "DONE(d!)")))
  (defun anders-org-agenda ()
    (interactive)
    (org-agenda)
    (org-agenda-day-view)))

(use-package org-gcal
  :init
  (setq org-gcal-file-alist '(("anderspapitto@gmail.com" . "~/org/gcal.org")))
  (add-hook 'org-agenda-mode-hook (lambda () (org-gcal-sync) ))
  (add-hook 'org-capture-after-finalize-hook (lambda () (org-gcal-sync) )))

(use-package prodigy)

(use-package projectile
  :init
  (setq projectile-keymap-prefix (kbd "M-t"))
  (setq projectile-mode-line
        ''(:eval (format "Projectile[%s]" default-directory)))
  (setq projectile-switch-project-action 'projectile-vc)
  (setq projectile-use-git-grep t)
  (setq projectile-completion-system 'ivy)
  :config
  (projectile-global-mode)
  (ad-deactivate 'compilation-find-file))

(use-package rainbow-delimiters
  :init
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package real-auto-save)

(use-package rust-mode)

(use-package shackle
  :init
  (setq shackle-rules '(("\\*input/output of.*\\*" :regexp t :ignore t))))

(use-package subword
  :config
  (global-subword-mode))

(use-package swiper)

(use-package tramp
  :init
  (add-to-list 'tramp-remote-path "/run/current-system/sw/bin")
  (setq tramp-default-method "ssh")
  (setq tramp-use-ssh-controlmaster-options nil))

(use-package undo-tree
  :init
  (setq undo-tree-auto-save-history t)
  (setq undo-tree-history-directory-alist '(("." . "/tmp/undo-tree")))
  :config
  (global-undo-tree-mode))

(use-package vimish-fold
  :config
  (vimish-fold-global-mode 1))

(use-package whitespace
  :bind ("C-x C-s" . save-with-delete-trailing-whitespace)
  :init
  (setq-default indent-tabs-mode nil)
  (setq whitespace-style '(face tabs))
  (add-hook 'prog-mode-hook 'whitespace-mode)
  (defun save-with-delete-trailing-whitespace ()
    (interactive)
    (delete-trailing-whitespace)
    (save-buffer)))

(use-package yaml-mode)

;;; Miscellaneous

(global-set-key (kbd "C-z") nil)
(setq auto-save-file-name-transforms '((".*" "/tmp/" t)))
(setq backup-directory-alist '((".*" . "/tmp/")))
(setq dired-auto-revert-buffer t)
(setq gdb-display-io-nopopup t)
(setq recenter-positions '(bottom middle top))
(setq view-read-only t)
(global-set-key (kbd "C-x k") 'kill-this-buffer)
(global-set-key (kbd "<f12>") 'browse-url-at-point)
(global-set-key (kbd "<XF86Explorer>") 'browse-url-at-point)

;;; copy/paste

(setq kill-do-not-save-duplicates t)
(setq save-interprogram-paste-before-kill t)
(setq select-enable-clipboard nil)
(setq select-enable-primary t)

;;; Window management

(defun switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))
(global-set-key "\M-o" 'switch-to-previous-buffer)
(setq frame-auto-hide-function 'delete-frame)
(setq display-buffer-alist
      '(("*shell*" (display-buffer-same-window) ())
        (".*" (display-buffer-reuse-window
               display-buffer-same-window
               display-buffer-pop-up-frame)
         (reusable-frames . t))))
(defun anders-same-window-instead
    (orig-fun buffer alist)
  (display-buffer-same-window buffer nil))
(advice-add 'display-buffer-pop-up-window :around 'anders-same-window-instead)
(defun anders-do-select-frame (orig-fun buffer &rest args)
  (let* ((old-frame (selected-frame))
         (window (apply orig-fun buffer args))
         (frame (window-frame window)))
    (unless (eq frame old-frame)
      (select-frame-set-input-focus frame))
    (select-window window)
    window))
(advice-add 'display-buffer :around 'anders-do-select-frame)
(advice-add 'set-window-dedicated-p :around
            (lambda (orig-fun &rest args) nil))

;;; Luddite mode

(set-scroll-bar-mode nil)
(setq tool-bar-mode nil)
(setq menu-bar-mode nil)
(setq initial-scratch-message nil)

;;; Looks

(set-face-attribute 'default nil :height 105)
(set-face-attribute 'default nil :family "Inconsolata")

(defun anders-switch-theme (from-theme to-theme org-hide-face)
  (progn
    (disable-theme from-theme)
    (load-theme to-theme t)
    (set-face-foreground 'org-hide org-hide-face)))
(defun enable-dark-theme ()
  (interactive)
  (anders-switch-theme 'adwaita 'wheatgrass "#000000"))
(defun enable-light-theme ()
  (interactive)
  (anders-switch-theme 'wheatgrass 'adwaita "#EDEDED"))
(enable-light-theme)


(setq safe-local-variable-values
      '((projectile-project-compilation-cmd . "./build/Build.hs")))

;;; various stuff that I just always want to have open

(when (daemonp)
  (progn
    (defun spawn-shell (name command)
      (pop-to-buffer (get-buffer-create name))
      (shell (current-buffer))
      (process-send-string nil command))
    (spawn-shell "*sudo*" "echo; exec sudo -i\n")
    (find-file-noselect "/etc/nixos/configuration/config/init.el")
    (find-file-noselect "/etc/nixos/configuration/private/bad-hosts.nix")))
