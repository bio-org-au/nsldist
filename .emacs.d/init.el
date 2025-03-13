; MELPA package library https://melpa.org/#/getting-started
;(setq debug-on-error t)
;(setq debug-on-message "Package cl is deprecated")

(global-set-key "\C-x\C-b" 'buffer-menu)
(defun efs/run-in-background (command)
  (let ((command-parts (split-string command "[ ]+")))
    (apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" "https://melpa.org/packages/") t)
;;  (add-to-list 'package-archives (cons "melpa-stable" "https://stable.melpa.org/packages/") t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/"))
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#21252B" "#E06C75" "#98C379" "#E5C07B" "#61AFEF" "#C678DD" "#56B6C2" "#ABB2BF"])
 '(custom-enabled-themes '(manoj-dark))
 '(custom-safe-themes
   '("b23f3067e27a9940a563f1fb3bf455aabd0450cb02c3fa4ad43f75a583311216" "24fc62afe2e5f0609e436aa2427b396adf9a958a8fa660edbaab5fb13c08aae6" default))
 '(package-selected-packages
   '(async avy winner-mode-enable direx filetree treesit-auto projectile dirtree-prosjekt dirtree dired-sidebar dir-treeview-themes dir-treeview neotree melpa-upstream-visit magit exwm counsel list-utils fancy-battery ace-jump-mode backlight fontawesome list-utils dmenu centaur-tabs lsp-javacomp company helm-lsp lsp-ivy lsp-ui dap-mode lsp-mode lsp-groovy yaml-mode xah-get-thing vterm simple-httpd mark-thing-at lsp-java hide-comnt groovy-mode groovy-imports find-things-fast fancy-battery exwm elgrep desktop-environment counsel arjen-grey-theme arc-dark-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Courier New" :foundry "outline" :slant normal :weight normal :height 120 :width normal))))
 '(mode-line ((t (:background "#330000" :foreground "white" :box (:line-width (1 . -1) :style released-button) :height 0.9))))
 '(mode-line-buffer-id ((t (:background "black" :distant-foreground "gold" :foreground "white" :weight bold :height 0.9))))
 '(mode-line-inactive ((t (:background "gray14" :foreground "white" :box (:line-width (1 . 1) :color "gray40") :weight light :height 0.9))))
 '(tab-bar ((t (:inherit variable-pitch :background "black" :foreground "light gray")))))

(setq-default buffer-file-coding-system 'utf-8-unix) ;; Unix line endings always

(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'load-path "~/.emacs.d/lisp/treemacs/")

(setq *win32* (eq system-type 'windows-nt) )
;(if window-system (color-scheme-blah))
;window-system can be 'x or 'mswindows or possibly even other values, but it's always nil when you are on a terminal.

(if *win32*
    (progn
      (setq cygwin-mount-cygwin-bin-directory "c:/cygwin/bin")
      (require 'cygwin-mount)
      (cygwin-mount-activate)))

;(require 'thing-cmds)
;(thgcmd-bind-keys)

(require 'avy)
(global-set-key (kbd "C-:") 'avy-goto-char)
(global-set-key (kbd "C-'") 'avy-goto-char-2)
(global-set-key (kbd "M-g f") 'avy-goto-line)
(global-set-key (kbd "M-g w") 'avy-goto-word-1)
(global-set-key (kbd "M-g e") 'avy-goto-word-0)
(avy-setup-default)
(global-set-key (kbd "C-c C-j") 'avy-resume)
(global-set-key (kbd "C-c C-s") 'avy-goto-char-timer) ;; isearch-forward
(setq avy-background t)

;; (define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
;; (define-key global-map (kbd "C-x SPC") 'ace-jump-mode-pop-mark)


; To disable the menu bar, place the following line in your .emacs file:
(menu-bar-mode -1)
;; (menu-bar-mode 1)
; To disable the scrollbar, use the following line:
(scroll-bar-mode -1)
; To disable the toolbar, use the following line:
(tool-bar-mode -1)

;(autoload browse-kill-ring-yank-commands)

;(set-buffer "*scratch*")



(put 'downcase-region 'disabled nil)


; Make Aquamacs unify clipboard and kill ring
(setq x-select-enable-clipboard t)

(setq inhibit-startup-message t)

(setq-default visible-bell t) ; No beep, flash instead

(defun ask-before-closing ()
  "Close only if y was pressed."
  (interactive)
  (if (y-or-n-p (format "Are you sure you want to close this frame? "))
      (save-buffers-kill-emacs)                                                                                            
    (message "Canceled frame close")))

(when (daemonp)
  (global-set-key (kbd "C-x C-c") 'ask-before-closing))
(put 'upcase-region 'disabled nil)

(keymap-global-set "C-c z" 'ace-window)
;(ace-window-display-mode t)

(keymap-global-set "C-c <left>" 'windmove-left)
(keymap-global-set "C-c <right>" 'windmove-right)
(keymap-global-set "C-c <up>" 'windmove-up)
(keymap-global-set "C-c <down>" 'windmove-down)

(keymap-global-set "C-c C-<left>" 'windmove-swap-states-left)
(keymap-global-set "C-c C-<right>" 'windmove-swap-states-right)
(keymap-global-set "C-c C-<up>" 'windmove-swap-states-up)
(keymap-global-set "C-c C-<down>" 'windmove-swap-states-down)

(add-to-list 'auto-mode-alist '("\\.gsp\\'" . xml-mode))

(keymap-global-set "C-c C-c" 'comment-line)

(defun use-least-recent-window (orig-fun &rest args)
  (let ((display-buffer-alist '((".*" display-buffer-use-least-recent-window))))
    (apply orig-fun args)))

(advice-add 'switch-to-buffer-other-window :around #'use-least-recent-window)
(tab-bar-mode)


;;If at any point you want to get rid of the advice, then evaluate the following:
;;(advice-remove 'switch-to-buffer-other-window  #'use-least-recent-window)

;(windmove-find-other-window 'right)

;;; use groovy-mode when file ends in .groovy or has #!/bin/groovy at start
;(add-to-list 'load-path "~/.emacs.d/lisp/vendor/groovy-mode")
;(autoload 'groovy-mode "groovy-mode" "Major mode for editing Groovy code." t)
;(add-to-list 'auto-mode-alist '("\.groovy$" . groovy-mode))
;(add-to-list 'auto-mode-alist '("\.gradle$" . groovy-mode))
;(add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode))
 
;;; make Groovy mode electric by default.
;(add-hook 'groovy-mode-hook
;          #'(lambda ()
;             (require 'groovy-electric)
;             (groovy-electric-mode)))

;(use-package lsp-mode
;  :ensure t
;  :hook (lsp-mode . lsp-lens-mode)
;            (lsp-mode . lsp-enable-which-key-integration)
;  :config
;  (setq lsp-prefer-flymake nil
;        lsp-client-packages '(lsp-clients lsp-metals)))

;(use-package lsp-java
;  :ensure t
;  :init
;  :config
;  (add-hook 'java-mode-hook 'lsp)
;  (add-hook 'java-ts-mode-hook 'lsp)
;  (add-to-list 'lsp-language-id-configuration '(java-ts-mode . "java")))

;(use-package lsp-groovy
;  :ensure t
;  :init
;  :config
;  (add-hook 'groovy-mode-hook 'lsp)
;  (add-hook 'groovy-ts-mode-hook 'lsp)
 ;" (add-to-list 'lsp-language-id-configuration '(groovy-ts-mode . "groovy")))



;; (if window-system
;;     (face-spec-set 'mode-line
;; 		   '((((class color) (min-colors 88))
;; 		      :box (:line-width -1 :style released-button)
;; 		      :background "#330000" :foreground "white")
;; 		     (t
;; 		      :inverse-video t)))
;;     ;; (face-spec-set 'mode-line-inactive
;; 		   ;; '((((class color) (min-colors 88))
;; 		      ;; :box (:line-width -1 :style released-button)
;; 		      ;; :background "#003300" :foreground "white")
;; 		     ;; (t
;; 		      ;; :inverse-video t)))
;;   (face-spec-set 'mode-line-inactive
;; 		 '((default
;; 		    :inherit mode-line)
;; 		   (((class color) (min-colors 88) (background light))
;; 		    ;; :weight light
;; 		    ;; :box (:line-width -1 :color "green" :style nil)
;; 		    ;; :foreground "green" :background "blue")
;; 		   (((class color) (min-colors 88) (background dark))
;; 		    :background "#222222" :foreground "green" :box nil))))
;;   (face-spec-set 'mode-line-buffer-id
;; 		 ((t (:background "#000000" :foreground "black")))))
;;   ;; (face-spec-set 'mode-line-highlight
		 ;; '((((class color) (min-colors 88))
		    ;; :foreground "green")
		   ;; (t
		    ;; :inherit highlight))))

(use-package centaur-tabs
  :demand
  :config
  (centaur-tabs-mode t)
  (setq centaur-tabs-style "rounded")
  (setq centaur-tabs-set-icons t)
  (setq centaur-tabs-icon-type 'all-the-icons)
  (setq centaur-tabs-set-bar 'left)
  (setq centaur-tabs-set-modified-marker t)
  (setq centaur-tabs-show-new-tab-button t)
  (setq centaur-tabs-new-tab-text " + ")
  (setq centaur-tabs-show-navigation-buttons t)
  (setq centaur-tabs-height 24)
  (setq centaur-tabs-cycle-scope 'tabs)
  (setq centaur-tabs-label-fixed-length 20)
  (centaur-tabs-change-fonts "arial" 100)
;  :hook
;  (exwm-mode . centaur-tabs-local-mode) ;; ????? crap? 
  :bind
  ("C-<prior>" . centaur-tabs-backward)
  ("C-<next>" . centaur-tabs-forward))

;; (defun centaur-tabs-hide-tab (x)
;;   nil)

;; Basic means these are not tabbed applications
(setq basic-titles
   '(("Gmail" . "Gmail")
     ("Google Keep" . "Keep")
     ("Google Calendar" . "Calendar")
     ("YouTube" . "YouTube")
     ("Google Translate" . "Translate")
     ("Google Contacts" . "Contacts")
     ("Slack" . "Slack")
     ("KeePassXC" . "KeePassXC")
     ("Messenger" . "Messenger")
     ("YouTube" . "YouTube")
     ("Gmail" . "Gmail")))

;; Basic means these are not tabbed applications
(setq basic-names
      '(("Slack" . "Slack")
	("KeePassXC" . "KeePassXC")))

(defvar mycentaur-t ()
  "(BUFFER-OR-NAME . group-name)")
(defvar mycentaur-groups (make-hash-table :test 'equal))

(defun mycentaur-tabs-buffer-group-default ()
 (cond
  ((when-let* ((project-name (centaur-tabs-project-name)))
     project-name))
  ((memq major-mode '(exwm-mode))
    (let ((title (seq-find (lambda (x) (string-match-p (car x) exwm-title)) basic-titles))
	  (name (seq-find (lambda (x) (string-match-p (car x) exwm-class-name)) basic-names)))
      (cond
       (title (cdr title))
       (name (cdr name))
       (t exwm-class-name))))
  ((memq major-mode '(vterm-mode)) "Terminal")
  ((memq major-mode '(treemacs-mode)) "Treemacs")
    ((memq major-mode '( magit-process-mode
                         magit-status-mode
                         magit-diff-mode
                         magit-log-mode
                         magit-file-mode
                         magit-blob-mode
                         magit-blame-mode))
     "Magit")
    ((derived-mode-p 'shell-mode) "Shell")
    ((derived-mode-p 'eshell-mode) "EShell")
    ((derived-mode-p 'dired-mode) "Dired")

    ((derived-mode-p 'prog-mode)
     "Editing")
    ((derived-mode-p 'emacs-lisp-mode) "Elisp")
    ((memq major-mode '(helpful-mode
			help-mode))
     "Help")
    ((memq major-mode '(org-mode
			org-agenda-clockreport-mode
			org-src-mode
			org-agenda-mode
			org-beamer-mode
			org-indent-mode
			org-bullets-mode
			org-cdlatex-mode
			org-agenda-log-mode
			diary-mode))
     "OrgMode")
    (t
     (centaur-tabs-get-group-name (current-buffer)))))

(defun centaur-tabs-buffer-groups ()
  "`centaur-tabs-buffer-groups' control buffers' group rules.
Group centaur-tabs with mode if buffer is derived from `eshell-mode' `emacs-lisp-mode' `dired-mode' `org-mode' `magit-mode'.
All buffer name start with * will group to \"Emacs\".
Other buffer group by `centaur-tabs-get-group-name' with project name."
  (list (mycentaur-tabs-buffer-group-default)))
 

(defun centaur-tabs--create-new-tab ()
  "Create a context-aware new tab."
  (interactive)
  (cond
   ((eq major-mode 'exwm-mode)
    (let ((title (seq-find (lambda (x) (string-match-p (car x) exwm-title)) basic-titles))
	  (name (seq-find (lambda (x) (string-match-p (car x) exwm-class-name)) basic-names)))
      (cond
       (title nil)
       (name nil)
       ((string= exwm-class-name "Google-chrome")
	(efs/run-in-background "google-chrome-stable"))
       ((string= exwm-class-name "Vivaldi-stable")
	(efs/run-in-background "vivaldi-stable"))
       ((string= exwm-class-name "net-sourceforge-squirrel_sql-client-Main")
	(efs/run-in-background "squirrel-sql"))
       (t (efs/run-in-background (format "%s" exwm-class-name))))))
     ;; (t nil)))
   ((eq major-mode 'eshell-mode)
    (eshell t))
   ((eq major-mode 'vterm-mode)
    (vterm t))
   ((eq major-mode 'treemacs-mode)
    (treemacs t))
   ((eq major-mode 'term-mode)
    (ansi-term "/bin/bash"))
   ((derived-mode-p 'eww-mode)
    (let ((current-prefix-arg 4))
      (call-interactively #'eww)))
   (t
    (centaur-tabs--create-new-empty-buffer))))


;; (defun vz/shell-inside-p (&optional buffer)
  ;; "Return t if the current \"active\" process is a shell.
;; If BUFFER is nil, the current buffer is used instead."
  ;; (let ((it (process-running-child-p (get-buffer-process (or buffer (current-buffer))))))
    ;; (or (null it)
        ;; (equal (alist-get 'comm (process-attributes it))
               ;; (file-name-base explicit-shell-file-name)))))

(defun my/vterm-better-kill (orig-fun &rest args)
  "Override kill-buffer for vterm: kill without confirmation when vterm is idle."
  (if (eq major-mode 'vterm-mode) 
      (set-process-query-on-exit-flag (get-buffer-process (current-buffer)) nil))
      ;; (let ((process (get-buffer-process (current-buffer))))
	;; (if (and (vz/shell-inside-p) (vterm--at-prompt-p))
            ;; (set-process-query-on-exit-flag process nil)
          ;; (set-process-query-on-exit-flag process t))))
  (apply orig-fun args))
;; (defun my/vterm-better-kill (orig-fun &rest args)
  ;; "Override kill-buffer for vterm: kill without confirmation when vterm is idle."
  ;; (if (eq major-mode 'vterm-mode)
      ;; (let ((process (get-buffer-process (current-buffer))))
        ;; (when process
          ;; (if (vterm--at-prompt-p)
              ;; (set-process-query-on-exit-flag process nil)
            ;; (set-process-query-on-exit-flag process t)))))
  ;; (apply orig-fun args))

(advice-add 'kill-buffer :around #'my/vterm-better-kill)

;(add-hook 'kill-buffer-hook  asdf)

(require 'vterm)
(define-key vterm-mode-map (kbd "C-`") #'(lambda () (interactive) (kill-buffer (current-buffer))))

;(require 'treemacs)

(winner-mode 1)
