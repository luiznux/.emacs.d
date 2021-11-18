;;; evil-config.el --- Package configuration for `evil'  -*- lexical-binding: t -*-
;;
;; Author: Luiz Tagliaferro <luiz@luiznux.com>
;; URL: https://luiznux.com
;; This file is free software :)
;;
;;; Commentary:
;;
;; Emacs Evil configuration --- Package configuration for Emacs evil
;;
;; ███████╗██╗   ██╗██╗██╗
;; ██╔════╝██║   ██║██║██║
;; █████╗  ██║   ██║██║██║
;; ██╔══╝  ╚██╗ ██╔╝██║██║
;; ███████╗ ╚████╔╝ ██║███████╗
;; ╚══════╝  ╚═══╝  ╚═╝╚══════╝
;;
;;; Code:

(use-package evil
  :commands evil-set-initial-state
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (evil-set-initial-state 'term-mode 'emacs)
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "M-.") nil)
    (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)))

(use-package evil-collection
  :after evil
  :defines evil-collection-company-use-tng
  :config
  (evil-collection-init)
  (setq evil-collection-setup-minibuffer t
        evil-collection-company-use-tng  nil))

(use-package evil-matchit
  :config
  (global-evil-matchit-mode 1))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-leader
  :config
  (global-evil-leader-mode))

(use-package evil-org
  :functions evil-org-agenda-set-keys
  :after evil org
  :config
  (add-hook 'org-mode-hook (lambda () (evil-org-mode)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (with-no-warnings
    (evil-org-set-key-theme '(textobjects insert navigation additional shift todo heading))))

;; dependency for evil-undo-system
(use-package undo-tree
  :hook (after-init . global-undo-tree-mode))


(provide 'evil-config)
;;; evil-config.el ends here
