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
  :demand t
  :commands evil-set-initial-state
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-undo-system 'undo-tree)

  (with-eval-after-load 'evil
    (define-key evil-normal-state-map (kbd "M-.") nil)
    (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up))

  :config
  (evil-mode 1)

  ;; dependency for evil-undo-system
  (use-package undo-tree
    :hook (after-init . global-undo-tree-mode))

  (use-package evil-collection
    :demand t
    :after evil
    :defines evil-collection-company-use-tng
    :init
    (setq evil-collection-setup-minibuffer nil
          evil-collection-company-use-tng  nil)
    :config
    (evil-collection-init))

  (use-package evil-org
    :demand t
    :functions evil-org-agenda-set-keys
    :after evil org
    :config
    (add-hook 'org-mode-hook (lambda () (evil-org-mode)))
    (require 'evil-org-agenda)
    (evil-org-agenda-set-keys)
    (with-no-warnings
      (evil-org-set-key-theme '(textobjects insert navigation additional shift todo heading))))

  (use-package evil-multiedit
    :config
    (with-no-warnings
      (evil-multiedit-default-keybinds)))

  (use-package evil-goggles
    :init
    (custom-set-faces
     '(evil-goggles-delete-face ((t (:inherit 'shadow))))
     '(evil-goggles-paste-face ((t (:inherit 'lazy-highlight))))
     '(evil-goggles-yank-face ((t (:inherit 'isearch-fail)))))

    (setq evil-goggles-mode t)
    )

  (use-package evil-surround
    :config
    (global-evil-surround-mode 1))

  (use-package evil-leader
    :config
    (global-evil-leader-mode))

  (use-package evil-matchit
    :config
    (global-evil-matchit-mode 1)))


(provide 'evil-config)
;;; evil-config.el ends here
