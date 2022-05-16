;;; basic.el --- Basic emasc config file  -*- lexical-binding: t -*-
;;
;; Author: Luiz Tagliaferro <luiz@luiznux.com>
;; URL: https://luiznux.com
;; This file is free software :)
;;
;;; Commentary:
;;
;; basics Emacs config.
;;
;;  ██████╗  █████╗ ███████╗██╗ ██████╗
;;  ██╔══██╗██╔══██╗██╔════╝██║██╔════╝
;;  ██████╔╝███████║███████╗██║██║
;;  ██╔══██╗██╔══██║╚════██║██║██║
;;  ██████╔╝██║  ██║███████║██║╚██████╗
;;  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝
;;
;;; Code:

(require 'subr-x)
(require 'constants)
(require 'custom-config)
(require 'functions)

(with-no-warnings
  ;; Garbage Collector Magic Hack
  (use-package gcmh
    :diminish
    :init
    (setq gcmh-idle-delay 5
          gcmh-high-cons-threshold #x1000000) ; 16MB
    (gcmh-mode 1)))

;; Environment
(when (or sys/mac-x-p sys/linux-x-p (daemonp))
  (use-package exec-path-from-shell
    :init
    (setq exec-path-from-shell-variables '("SSH_AUTH_SOCK" "SSH_AGENT_PID" "GPG_AGENT_INFO"
                                           "PATH" "MANPATH"
                                           "LANG" "LC_CTYPE"))
    ;; change params for bash
    (if (equal (getenv "SHELL") "/bin/bash")
        (setq exec-path-from-shell-arguments '("-l"))
      (setq exec-path-from-shell-arguments '("-i")))

    (exec-path-from-shell-initialize)))

;; Start server
(require 'server)
(use-package server
  :ensure nil
  :if luiznux-server
  :init
  (if (or (server-running-p) (daemonp))
      (message "Server/Daemon already running!")
    (add-hook 'after-init-hook 'server-start)))

;; Increase how much is read from processes in a single chunk (default is 4kb)
(setq read-process-output-max #x10000)  ; 64kb

;; History
(use-package saveplace
  :ensure nil
  :hook (after-init . save-place-mode))

(use-package recentf
  :ensure nil
  :bind (("C-x C-r" . recentf-open-files))
  :hook (after-init . recentf-mode)
  :init (setq recentf-max-saved-items 300
              recentf-exclude
              '("\\.?cache" ".cask" "url" "COMMIT_EDITMSG\\'" "bookmarks"
                "\\.\\(?:gz\\|gif\\|svg\\|png\\|jpe?g\\|bmp\\|xpm\\)$"
                "\\.?ido\\.last$" "\\.revive$" "/G?TAGS$" "/.elfeed/"
                "^/tmp/" "^/var/folders/.+$" "^/ssh:" "/persp-confs/"
                "/org/*" ;; prevent  show recent org-agenda files
                (lambda (file) (file-in-directory-p file package-user-dir))))
  :config
  (push (expand-file-name recentf-save-file) recentf-exclude)
  (add-to-list 'recentf-filename-handlers #'abbreviate-file-name))

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode)
  :init (setq enable-recursive-minibuffers t ; Allow commands in minibuffers
              history-length 1000
              savehist-additional-variables '(mark-ring
                                              global-mark-ring
                                              search-ring
                                              regexp-search-ring
                                              extended-command-history)
              savehist-autosave-interval 300))

(use-package simple
  :ensure nil
  :hook ((after-init . size-indication-mode)
         (text-mode . visual-line-mode)
         ((prog-mode markdown-mode conf-mode) . enable-trailing-whitespace))
  :init
  (setq column-number-mode t
        line-number-mode   t
        ;; kill-whole-line t            ; Kill line including '\n'
        line-move-visual nil
        track-eol   t                   ; Keep cursor at end of lines. Require line-move-visual is nil.
        set-mark-command-repeat-pop t)  ; Repeating C-SPC after popping mark pops it again

  ;; Visualize TAB, (HARD) SPACE, NEWLINE
  (setq-default show-trailing-whitespace nil) ; Don't show trailing whitespace by default
  (defun enable-trailing-whitespace ()
    "Show trailing spaces and delete on saving."
    (setq show-trailing-whitespace t)
    (add-hook 'before-save-hook #'delete-trailing-whitespace nil t))

  ;; Prettify the process list
  (with-no-warnings
    (add-hook 'process-menu-mode-hook
              (lambda ()
                (setq tabulated-list-format
                      (vconcat `(("" , 2)) tabulated-list-format))))

    (defun my-list-processes--prettify ()
      "Prettify process list."
      (when-let ((entries tabulated-list-entries))
        (setq tabulated-list-entries nil)
        (dolist (p (process-list))
          (when-let* ((val (cadr (assoc p entries)))
                      (icon (all-the-icons-octicon "zap"
                                                   :height 0.8 :v-adjust -0.05
                                                   :face 'all-the-icons-lblue))
                      (name (aref val 0))
                      (pid (aref val 1))
                      (status (aref val 2))
                      (status (list status
                                    'face
                                    (if (memq status '(stop exit closed failed))
                                        'error
                                      'success)))
                      (buf-label (aref val 3))
                      (tty (list (aref val 4) 'face 'font-lock-doc-face))
                      (thread (list (aref val 5) 'face 'font-lock-doc-face))
                      (cmd (list (aref val (if emacs/>=27p 6 5)) 'face 'completions-annotations)))
            (push (list p (if emacs/>=27p
                              (vector icon name pid status buf-label tty thread cmd)
                            (vector icon name pid status buf-label tty cmd)))
		          tabulated-list-entries)))))
    (advice-add #'list-processes--refresh :after #'my-list-processes--prettify)))

(use-package so-long
  :hook (after-init . global-so-long-mode))

;; Fullscreen
(when (display-graphic-p)
  (bind-keys ("C-<f11>" . toggle-frame-fullscreen)
             ("S-s-<return>" . toggle-frame-fullscreen)
             ("M-S-<return>" . toggle-frame-fullscreen)))

;; Misc
(if (boundp 'use-short-answers) ; Simplify Yes/No Prompt
    (setq use-short-answers t)
  (fset 'yes-or-no-p 'y-or-n-p))

(setq indent-line-function 'insert-tab)
(setq-default major-mode        'text-mode
              fill-column       80
              tab-width         4
              indent-tabs-mode  nil) ; Permanently indent with spaces, never with TABs

(setq password-cache-expiry     nil
      load-prefer-newer         t
      system-time-locale        "C")

(setq line-breaker page-delimiter)

(global-hl-line-mode 1)

(setq inhibit-compacting-font-caches  t ; Don’t compact font caches during GC.
      delete-by-moving-to-trash       t ; Deleting files go to OS's trash folder
      delete-old-versions             t ; Delete excess backup files silently
      delete-selection-mode           t
      tab-always-indent               'complete
      uniquify-buffer-name-style      'post-forward-angle-brackets ; Show path if names are same

      adaptive-fill-regexp "[ t]+|[ t]*([0-9]+.|*+)[ t]*"
      adaptive-fill-first-line-regexp "^* *$"
      sentence-end "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*"
      sentence-end-double-space nil)

;;; Backup Files
;; Don’t clutter project directories with backup files, e.g.
;; Emacs.org\~ Watch this great explanation about Emacs temporary
;; files such as backups, autosaves, etc:
;; https://www.youtube.com/watch?v=XZjyJG-sFZI
(setq backup-directory-alist
      `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))

;;; Auto Save Files
;;auto-save-mode will create temporary files in the same folder as
;;edited files: #Emacs.org# You can change this using
;;auto-save-file-name-transforms:
;; auto-save-mode doesn't create the path automatically!
(make-directory (expand-file-name "tmp/auto-saves/" user-emacs-directory) t)

(setq auto-save-list-file-prefix (expand-file-name "tmp/auto-saves/sessions/" user-emacs-directory)
      auto-save-file-name-transforms `((".*" ,(expand-file-name "tmp/auto-saves/" user-emacs-directory) t)))


;; Global keybindings
(bind-keys ("C-c K" . revert-this-buffer))


(provide 'basic)
;;; basic.el ends here
