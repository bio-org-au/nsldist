(setenv "_JAVA_AWT_WM_NONREPARENTING" "1")
(require 'exwm)
(require 'exwm-systemtray)
(require 'exwm-randr)
(require 'buffer-move)

;(add-to-list 'load-path "/usr/share/emacs/site-lisp/xelb")
;(add-to-list 'load-path "/usr/share/emacs/site-lisp/exwm")

(defun cc/exwm-show-all-buffers (b)
  ;; Automatically move EXWM buffer to current workspace when selected
  (setq exwm-layout-show-all-buffers b)
  ;; Display all EXWM buffers in every workspace buffer list
  (setq exwm-workspace-show-all-buffers b))

(defun cc/exwm-toggle-show-all-buffers ()
  (cc/exwm-show-all-buffers (not exwm-layout-show-all-buffers)))

(setq exwm-layout-show-all-buffers t)
(setq exwm-workspace-show-all-buffers t)
(setq exwm-workspace-minibuffer-position 'top) 

(defun cc/build-workspaces (l n)
  (cons
   (cons n (car l))
   (if (cdr l)
       (cc/build-workspaces (cdr l) (+ n 1))
     nil)))

;; (setq exwm-input-prefix-keys
;;     '(?\C-x
;;       ?\C-u
;;       ?\C-h
;;       ?\M-x
;;       ?\M-`
;;       ?\M-&
;;       ?\M-:
;;       (kbd "<f2>")
;;       f2
;;       [f2]
;;       ?\C-\M-j  ;; Buffer list
;;       ?\C-\ ))  ;; Ctrl+Space

;(push (kbd "<f2>") exwm-input-prefix-keys)

;; Set the initial workspace number.

;(setq cc/arandr-file nil)
;(if cc/arandr-file (start-process-shell-command nil (format "~/.screenlayout/%s.sh" cc/arandr-file))) 

(defun cc/exwm-randr-screen-change ()
  (start-process-shell-command "autorandr" nil "autorandr --change" )
  (setq cc/primary (process-lines "sh" "-c" "xrandr | sed -n  's:\\([^ ]\\) connected primary.*:\\1:p'"))
  (setq cc/secondary (process-lines "sh" "-c" "xrandr | grep -v 'connected primary' | sed -n  's:\\([^ ]\\) connected .*:\\1:p'"))
  (setq cc/tertiary '())
  (setq cc/screen-list (append cc/primary cc/secondary cc/tertiary))
  (setq exwm-randr-workspace-monitor-alist (cc/build-workspaces cc/screen-list 0))
  (setq exwm-randr-workspace-monitor-plist (list-utils-flatten exwm-randr-workspace-monitor-alist))
  (let* ((last-ws (car (car (last exwm-randr-workspace-monitor-alist))))
		 (last-plus (+ last-ws 1)))
	(exwm-workspace-switch-create last-ws)
	(exwm-workspace-switch-create 0)
	(while (< last-plus (length exwm-workspace--list))
	  (exwm-workspace-delete last-plus))))
;  (exwm-randr-refresh))


;  (run-with-timer 5 nil
;				  (lambda ()
;  (if (boundp 'exwm-randr-workspace-monitor-alist)
;	  (setq old-workspace-monitor-alist exwm-randr-workspace-monitor-alist))
;  (dolist (screen (cdr exwm-randr-workspace-monitor-alist))
;	(if (<= (length exwm-workspace--list) (car screen))
;		(exwm-workspace-switch-create (car screen))))
;  (if (boundp 'old-workspace-monitor-alist)
;	  (let ((deleted-workspaces (seq-filter (lambda (c) (not (assoc (car c) exwm-randr-workspace-monitor-alist))) old-workspace-monitor-alist)))
;		(dolist (screen deleted-workspaces)
;; (let ((first (car cc/screen-list))
	;; (rest (cdr cc/screen-list)))
    ;; (dolist (screen rest)
      ;; (start-process-shell-command "xrandr" nil (format "xrandr --output %s --left-of %s --auto" screen first))))
  ;; (exwm-randr-refresh))

; multi monitor support
(add-hook 'exwm-randr-screen-change-hook #'cc/exwm-randr-screen-change)


;; Make buffer name more meaningful
;; (add-hook 'exwm-update-class-hook
          ;; (lambda ()
            ;; (exwm-workspace-rename-buffer exwm-class-name)))
(defun my/first-n-words (s n) (mapconcat (lambda (i) i) (seq-take (split-string s " ") n) " "))

(defun exwm-current-workspace()
  (exwm-workspace--position (exwm-workspace--workspace-from-frame-or-index (selected-frame))))

(defun prompt-workspace (current-prefix-arg)
  (list
   (cond
    ((null current-prefix-arg)
     (let ((exwm-workspace--prompt-add-allowed t)
           (exwm-workspace--prompt-delete-allowed t))
       (exwm-workspace--prompt-for-workspace "Move to [+/-]: ")))
    ((and (integerp current-prefix-arg)
                       (<= 0 current-prefix-arg (exwm-workspace--count)))
     current-prefix-arg)
    (t 0))))

(defun windmove-far-right ()
  (interactive)
  (while (windmove-find-other-window 'right)
	(windmove-right)))

(defun windmove-far-left ()
  (interactive)
  (while (windmove-find-other-window 'left)
	(windmove-left)))

(defun buf-move-far-right ()
  (interactive)
  (while (windmove-find-other-window 'right)
	(buf-move-right)))

(defun buf-move-far-left ()
  (interactive)
  (while (windmove-find-other-window 'left)
	(buf-move-left)))

(defun exwm-workspace-move-buffer (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (let ((buffer (current-buffer))
		(old-ws (exwm-current-workspace)))
	(previous-buffer)
	(exwm-workspace-switch frame-or-index)
	(switch-to-buffer buffer)))
   
(defun exwm-workspace-move-buffer-or-window (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (if exwm--id
	  (exwm-workspace-move-window frame-or-index)
	(exwm-workspace-move-buffer frame-or-index)))

;;;;;;;;;;;
(defun exwm-workspace-move-window-left ()
  (let* ((ws (exwm-current-workspace))
		(new-ws (- ws 1)))
	(if (<= 0 new-ws)
		(progn (exwm-workspace-move-buffer-or-window new-ws)
			   (exwm-workspace-switch new-ws)))))
	
(defun exwm-workspace-move-window-left-wrap ()
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (< 0 ws)
			(- ws 1)
			(- (length exwm-workspace--list) 1))))
	(exwm-workspace-move-buffer-or-window new-ws)
	(exwm-workspace-switch new-ws)))

(defun exwm-workspace-move-window-right ()
  (let* ((ws (exwm-current-workspace))
		 (new-ws (+ ws 1)))
	(if (< new-ws (length exwm-workspace--list))
		(progn (exwm-workspace-move-buffer-or-window new-ws)
			   (exwm-workspace-switch new-ws)))))

(defun exwm-workspace-move-window-right-wrap ()
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (< (+ ws 1) (length exwm-workspace--list))
			  (+ ws 1)
			  0)))
	(exwm-workspace-move-buffer-or-window new-ws)
	(exwm-workspace-switch new-ws)))

(defun exwm-workspace-switch-left ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws (- ws 1)))
	(if (<= 0 new-ws)
		(exwm-workspace-switch new-ws))))

(defun exwm-workspace-switch-left-wrap ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (< 0 ws)
			  (- ws 1)
			  (- (length exwm-workspace--list) 1))))
	(message "switched from workspace %s to %s of %s" ws new-ws (length exwm-workspace--list))
	(exwm-workspace-switch new-ws)))

(defun exwm-workspace-switch-right ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws (+ ws 1)))
	(if (< new-ws (length exwm-workspace--list))
		(exwm-workspace-switch (+ ws 1)))))

(defun exwm-workspace-find (direction)
  (let ((ws (exwm-current-workspace)))
	(cond ((and (eq direction 'left) (< 0 ws))
		   (- ws 1))
		  ((and (eq direction 'right) (< (+ ws 1) (length exwm-workspace--list)))
		   (+ ws 1))
		  (t nil))))
  
(defun exwm-workspace-switch-right-wrap ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (<= (length exwm-workspace--list) (+ ws 1))
			  0
			  (+ ws 1))))
	(message "switched from workspace %s to %s of %s" ws new-ws (length exwm-workspace--list))
	(exwm-workspace-switch new-ws)))

(defun exwm-buf-move-window-left ()
  (interactive)
  (if (windmove-find-other-window 'left)
	(buf-move-left)
	(if (exwm-workspace-find 'left)
		(progn (exwm-workspace-move-window-left)
			   (buf-move-far-right)))))

(defun exwm-buf-move-window-right ()
  (interactive)
  (if (windmove-find-other-window 'right)
	(buf-move-right)
	(if (exwm-workspace-find 'right)
		(progn (exwm-workspace-move-window-right)
			   (buf-move-far-left)))))

(defun exwm-windmove-right ()
  (interactive)
  (if (windmove-find-other-window 'right)
	  (windmove-right)
	(if (exwm-workspace-find 'right)
		(progn (exwm-workspace-switch-right)
			   (windmove-far-left)))))

(defun exwm-windmove-left ()
  (interactive)
  (if (windmove-find-other-window 'left)
	(windmove-left)
	(if (exwm-workspace-find 'left)
		(progn (exwm-workspace-switch-left)
			   (windmove-far-right)))))

(defun cc/exwm-update-title ()
  (cond
   ((string-match-p "Gmail" exwm-title)
    (exwm-workspace-rename-buffer "Gmail"))
   ((string-match-p "Google Keep" exwm-title)
    (exwm-workspace-rename-buffer "Keep"))
   ((string-match-p "YouTube" exwm-title)
    (exwm-workspace-rename-buffer exwm-title))
   ((string-match-p "Google Translate" exwm-title)
    (exwm-workspace-rename-buffer "Translate"))
   ((string-match-p "Google Contacts" exwm-title)
    (exwm-workspace-rename-buffer "Contacts"))
   ((string-match-p "Slack" exwm-class-name)
    (exwm-workspace-rename-buffer "Slack"))
   ((string-match-p "KeePassXC" exwm-class-name)
    (exwm-workspace-rename-buffer "KeePassXC"))
   ((string-match-p "Messenger" exwm-title)
    (exwm-workspace-rename-buffer "Messenger"))
   ((string-match-p "YouTube" exwm-title)
    (exwm-workspace-rename-buffer "YouTube"))
   ((string-match-p "Gmail" exwm-title)
    (exwm-workspace-rename-buffer "Gmail"))
   ((string= "net-sourceforge-squirrel_sql-client-Main" exwm-class-name)
    (exwm-workspace-rename-buffer (replace-regexp-in-string "Session: [0-9]* - \\(.*\\)" "\\1" exwm-title)))
   ((string= exwm-class-name "Google-chrome")
    ;; (exwm-workspace-rename-buffer (format "C | %s" (my/first-n-words exwm-title 3))))
    (exwm-workspace-rename-buffer (format "C:%s" exwm-title)))
   ((string= exwm-class-name "firefox")
    ;; (exwm-workspace-rename-buffer (format "F | %s" (my/first-n-words exwm-title 3))))
    (exwm-workspace-rename-buffer (format "F:%s" exwm-title)))
   ((string= exwm-class-name "Vivaldi-stable")
    (exwm-workspace-rename-buffer (format "V:%s" exwm-title)))
   ((or (string= exwm-class-name "com-jetbrains-toolbox-entry-ToolboxEntry")
	(string= exwm-class-name "jetbrains-toolbox"))
     (exwm-workspace-rename-buffer "Jetbrains Toolbox"))
   ((string= exwm-class-name "jetbrains-idea")
     (exwm-workspace-rename-buffer (format "Idea | %s" exwm-title)))
   (t (exwm-workspace-rename-buffer (format "%s | %s" exwm-class-name exwm-title)))))

(add-hook 'exwm-update-title-hook #'cc/exwm-update-title)

 ;; Global keybindings.
(setq exwm-input-global-keys
      `(([?\s-r] . (lambda () (interactive) (exwm-reset) (message "line-mode"))) ;; s-r: Reset (to line-mode).
        ([?\s-k] . exwm-input-release-keyboard)
	([?\s-z] . exwm-input-toggle-keyboard)
	([?\s-c] . exwm-workspace-toggle-minibuffer)
	(,(kbd "<f7>") . exwm-input-toggle-keyboard)
        ;; ([?\s-a] . (lambda () (interactive) (cc/exwm-toggle-show-all-buffers)))
        ;; ([?\s-k] . (lambda () (interactive) (exwm-input-release-keyboard) (message "char-mode")))
    ([?\s-w] . exwm-workspace-switch) ;; s-w: Switch workspace.
    ([?\s-&] . (lambda (cmd) ;; s-&: Launch application. 
                 (interactive (list (read-shell-command "$ ")))
                 (start-process-shell-command cmd nil cmd)))
	([f2] . (lambda () (interactive) (exwm-input-toggle-keyboard)))
;	([f2] . (lambda () (interactive) (my/toggle-line-char)))
	([?\s-p] . (lambda () (interactive) (message (symbol-name exwm--input-mode))))
	([?\s-s] . (lambda () (interactive) (efs/run-in-background "xscreensaver-command --activate")))
	([?\s-l] . (lambda () (interactive) (efs/run-in-background "xscreensaver-command --lock")))
	([?\s- ] . (lambda () (interactive) (efs/run-in-background "rofi -show combi")))
;	([?\s-l] . (lambda () (interactive) (start-process "xscreensaver-command", nil, "xscreensaver-command --lock")))
	([?\C-`] . kill-current-buffer)
	([?\s-`] . bury-buffer)
	([?\s-h] . exwm-floating-hide)
	([?\s-f] . exwm-floating-toggle-floating)
	([?\s-e] . exwm-layout-toggle-fullscreen)
	([?\s-g] . exwm-input-grab-keyboard)
	([?\s-m] . exwm-workspace-move-window)
	([?\s-b] . buffer-menu)


	;; (,(kbd "s-<f11>") . exwm-layout-toggle-fullscreen)
	;; (,(kbd "<f11>") . exwm-layout-toggle-fullscreen)

	(,(kbd "M-<left>") . exwm-windmove-left)
	(,(kbd "M-<right>") . exwm-windmove-right)
	(,(kbd "M-<up>") . windmove-up)
	(,(kbd "M-<down>") . windmove-down)

	(,(kbd "S-M-<left>") . exwm-workspace-switch-left)
	(,(kbd "S-M-<right>") . exwm-workspace-switch-right)

	
	(,(kbd "s-<left>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move -10 0)
							 (exwm-buf-move-window-left))))
	(,(kbd "s-<right>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move 10 0)
							 (exwm-buf-move-window-right))))
	(,(kbd "s-<up>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move 0 -10)
							 (buf-move-up))))
	(,(kbd "s-<down>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move 0 10)
							 (buf-move-down))))

	(,(kbd "S-s-<left>") . (lambda () (interactive)
							 (exwm-workspace-move-window-left)))
	(,(kbd "S-s-<right>") . (lambda () (interactive)
							 (exwm-workspace-move-window-right)))

;	(,(kbd "S-s-<left>") . windmove-swap-states-left)
;	(,(kbd "S-s-<right>") . windmove-swap-states-right)
;	(,(kbd "S-s-<up>") . windmove-swap-states-up)
;	(,(kbd "S-s-<down>") . windmove-swap-states-down)

;	(,(kbd "C-<left>") . shrink-window-horizontally)
;	(,(kbd "C-<right>") . enlarge-window-horizontally)
;	(,(kbd "C-<up>") . enlarge-window)
;	(,(kbd "C-<down>") . shrink-window)

	(,(kbd "C-<left>") . (lambda () (interactive) (exwm-layout-shrink-window-horizontally 10)))
	(,(kbd "C-<right>") . (lambda () (interactive) (exwm-layout-enlarge-window-horizontally 10)))
	(,(kbd "C-<up>") . (lambda () (interactive) (exwm-layout-enlarge-window 10)))
	(,(kbd "C-<down>") . (lambda () (interactive) (exwm-layout-shrink-window 10)))

	
	(,(kbd "C-g") . prot/keyboard-quit-dwim)

		;	([?\s-z] . (lambda () (interactive) (ace-window nil)))
        ;; s-N: Switch to certain workspace.
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))
(exwm-input--update-global-prefix-keys) ;; not necessary on startup, but maybe later
   

;; To add a key binding only available in line-mode, simply define it in
;; `exwm-mode-map'.  The following example shortens 'C-c q' to 'C-q'.
(define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)

(setq sim-key-basic
      ;; movement, cursor
      '(([?\C-b] . [left])
        ([?\C-f] . [right])
        ([?\C-p] . [up])
        ([?\C-n] . [down])
	;; forward back word
        ([?\M-b] . [C-left])
        ([?\M-f] . [C-right])
	;; move on line
        ([?\C-a] . [home])
        ([?\C-e] . [end])
	;; move by page
        ([?\M-v] . [prior])
        ([?\C-v] . [next])
	;; beginning and end of file
	([?\M-<] . [C-home])
	([?\M->] . [C-end])
        ;; cut/paste.
        ([?\C-w] . [C-x])
        ([?\M-w] . [C-c])
        ([?\C-y] . [C-v])
	;; delete
        ([?\C-d] . [delete])
        ([?\M-d] . [C-delete])
        ([?\C-k] . [S-end delete])
	;; undo
        ([?\C-/] . [C-z])
	;; search
	([?\C-s] . [C-f])
	;; change case
	([?\C-r] . [S-F3])
	;; search and replace
	([?\M-%] . [C-h])))
	;; ((kbd "C-x h") . [C-a])))
	;; ([?\C-x h] . [C-home C-a])
	;; ([?\C-x f] . [C-o])
	;; ([?\C-x C-s] . [C-s])
	;; ([?\C-x k] . [C-F4])
	;; ([?\C-x C-c] . [C-q])
	;; ([?\C-x C-u] . [C-z])
	;; ([?\C-x C-u] . [C-z])
	;; ([?\C-x 5 0] . [M-F4])))

(setq sim-key-general
      (append
       sim-key-basic
	 '(([?\C-\`] . [C-q]))))

;; (setq sim-key-idea      '(([?\C-c ?\C-c] . [C-c C-c])))


(setq sim-key-browser
      (append
       sim-key-basic
       '(([?\C-l] . [C-r])
;	 ((kbd "C-x C-left") 
;	 ([?\C-x ?\C-f] . [C-t])
;	 ([?\C-\`] . [C-w])
;	 ([?\s-left] . [s-left])
;	 ([?\s-right] . [s-right])
;	 ([?\s-up] . [s-up])
;	 ([?\s-down] . [s-down])
	 ([?\C-x ?k] . [C-w]))))

(defun cc/exwm-manage-finish ()
  (if exwm-class-name
      (cond 
       ((or (string= exwm-class-name "emacs.Emacs")
	    (string= exwm-class-name "konsole")
	    (string= exwm-class-name "org.gnome.Console")
	    (string= exwm-class-name "jetbrains-idea")
	    (string= exwm-class-name "kgx"))
	(exwm-input-set-local-simulation-keys nil))
       ;; ((string= exwm-class-name "jetbrains-idea")
	;; (exwm-input-set-local-simulation-keys sim-key-idea))
       ((or (string= exwm-class-name "Google-chrome")
	    (string= exwm-class-name "Vivaldi-stable")
	    (string= exwm-class-name "firefox"))
	(exwm-input-set-local-simulation-keys sim-key-browser))
       ;; ((or (string= exwm-class-name "jetbrains-toolbox"))
	;; (exwm-floating-toggle-floating)
	;; (exwm-input-set-local-simulation-keys sim-key-general))
       (t
	(exwm-input-set-local-simulation-keys sim-key-basic)))))

(add-hook 'exwm-manage-finish-hook #'cc/exwm-manage-finish)

(setq exwm-manage-configurations '(((or (string= exwm-class-name "jetbrains-toolbox")
				        (string= exwm-class-name "com-jetbrains-toolbox-entry-ToolboxEntry"))
                                    floating nil)))

;; (setq exwm-manage-configurations '((t floating nil)))


(setq exwm-systemtray-height 20)


(defun cc/exwm-init ()
  (cc/exwm-randr-screen-change)
  ;; (exwm-workspace-switch-create (car (car (last exwm-randr-workspace-monitor-alist))))
  (efs/run-in-background "~/.config/polybar/launch.sh")
  (efs/run-in-background "nm-applet")
  (efs/run-in-background "insync start")
  (efs/run-in-background "blueman-applet")
  (efs/run-in-background "udiskie --tray")
  (efs/run-in-background "indicator-sound-switcher")
;  (efs/run-in-background "jetbrains-toolbox")
  (efs/run-in-background "picom") ; composite manager, plank prefers it
  (efs/run-in-background "plank -n dock1"))

(add-hook 'exwm-init-hook #'cc/exwm-init)

;;  (efs/run-in-background "pavucontrol")
			    
;; Enable EXWM
					;(require 'exwm-config)
(display-battery-mode 1)
(setq display-time-day-and-date t)
(display-time-mode 1)


;(counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
;(exwm-input-set-key (kbd "s-SPC") 'counsel-linux-app)
;; (exwm-input-set-key (kbd "s-f") 'exwm-layout-toggle-fullscreen)





;; (setq exwm-randr-workspace-monitor-plist '(1 "HDMI-1" 2 "DP-1"))

;; (defun exwm-change-screen-hook ()
;;   (let ((xrandr-output-regexp "^\\([^ ]+\\) connected ")
;; 	default-output)
;;     (with-temp-buffer
;;       (call-process "xrandr" nil t nil)
;;       (goto-char (point-min))
;;       (re-search-forward xrandr-output-regexp nil 'noerror)
;;       (setq default-output (match-string 1))
;;       (forward-line)
;;       (if (not (re-search-forward xrandr-output-regexp nil 'noerror))
;; 	  (call-process "xrandr" nil nil nil "--output" default-output "--auto")
;; 	(call-process
;;          "xrandr" nil nil nil
;;          "--output" (match-string 1) "--primary" "--auto"
;;          "--output" default-output "--off")
;; 	(setq exwm-randr-workspace-monitor-plist (list 0 (match-string 1)))))))
    

;; send mouse to current workspace
(setq exwm-workspace-warp-cursor t)

;(setq mouse-autoselect-window t
;      focus-follows-mouse t)


(exwm-randr-mode 1)

;(exwm-systemtray-mode 1)
(exwm-enable)
;(exwm-config-example)

;(print (kbd "<F1>"))

;(efs/run-in-background "jetbrains-toolbox")

(require 'fancy-battery)
(fancy-battery-mode)

(exwm-input-set-key
 (kbd "<XF86AudioLowerVolume>")
 (lambda () (interactive)
   (shell-command "volume -5%")))
                ;; (lambda () (interactive) (shell-command "amixer set Master 5%- | sed -nr 's/.*: Playback.*?\\[([[:digit:]%]*)\\].*/\\1/gp' | head -1")))
(exwm-input-set-key
 (kbd "<XF86AudioRaiseVolume>")
 (lambda () (interactive)
   (shell-command "volume +5%")))
                ;; (lambda () (interactive) (shell-command "amixer set Master 5%+ | sed -nr 's/.*: Playback.*?\\[([[:digit:]%]*)\\].*/\\1/gp' | head -1")))
(exwm-input-set-key (kbd "<XF86AudioMute>")
                    (lambda () (interactive) (shell-command "volume toggle")))
                    ;; (lambda () (interactive) (shell-command "amixer set Master 1+ toggle | sed -nr 's/.*: Playback.*?\\[([[:alpha:]]*)\\].*/\\1/gp' | head -1")))
(exwm-input-set-key (kbd "<XF86MonBrightnessDown>") (lambda () (interactive) (shell-command "brightnessctl -q s 2%- ; brightnessctl g")))
(exwm-input-set-key (kbd "<XF86MonBrightnessUp>") (lambda () (interactive) (shell-command "brightnessctl -q s 2%+ ; brightnessctl g")))
(exwm-input-set-key (kbd "<print>") (lambda () (interactive) (start-process-shell-command "spectacle" nil "spectacle")))
  
;; for emacsclient
(server-start)

(defun exwm-async-run (name)
  "Run a process asynchronously"
  (interactive)
  (start-process name nil name))

(defun run-or-raise-or-dismiss (program program-buffer-name)
  "If no instance of the program is running, launch the program.
If an instance already exists, and its corresponding buffer is
displayed on the screen, move to the buffer. If the buffer is not
visible, switch to the buffer in the current window. Finally, if
the current buffer is already that of the program, bury the
buffer (=minimizing in other WM/DE)"
  ;; check current buffer
  (if (string= (buffer-name) program-buffer-name)
      (bury-buffer)
    ;; either switch to or launch program
    (progn
      (if (get-buffer program-buffer-name)
          (progn
            (if (get-buffer-window program-buffer-name)
                (select-window (display-buffer program-buffer-name) nil)
              (exwm-workspace-switch-to-buffer program-buffer-name)))
        ;; start program
        (exwm-async-run program)))))



;; (defun efs/start-panel ()
  ;; (interactive)
  ;; (efs/kill-panel)
  ;; (setq efs/polybar-process (start-process-shell-command "polybar" nil "polybar panel")
  ;; (set-process-query-on-exit-flag efs/polybar-process nil)))

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))


;(use-package my/foo/package :after exwm :config
;(after! exwm
;;  (defun exwm-layout--show (id &optional window)
;;    "Show window ID exactly fit in the Emacs window WINDOW."
;;    (exwm--log "Show #x%x in %s" id window)
;;    (let* ((edges (window-inside-absolute-pixel-edges window))
;;           (x (pop edges))
;;           (y (pop edges))
;;           (width (- (pop edges) x))
;;           (height (- (pop edges) y))
;;           frame-x frame-y frame-width frame-height)
;;      (with-current-buffer (exwm--id->buffer id)
;;        (when exwm--floating-frame
;;          (setq frame-width (frame-pixel-width exwm--floating-frame)
;;                frame-height (+ (frame-pixel-height exwm--floating-frame)
;;                                ;; Use `frame-outer-height' in the future.
;;                                exwm-workspace--frame-y-offset))
;;          (when exwm--floating-frame-position
;;            (setq frame-x (elt exwm--floating-frame-position 0)
;;                  frame-y (elt exwm--floating-frame-position 1)
;;                  x (+ x frame-x (- exwm-layout--floating-hidden-position))
;;                  y (+ y frame-y (- exwm-layout--floating-hidden-position)))
;;            (setq exwm--floating-frame-position nil))
;;          (exwm--set-geometry (frame-parameter exwm--floating-frame
;;                                               'exwm-container)
;;                              frame-x frame-y frame-width frame-height))
;;        (when (exwm-layout--fullscreen-p)
;;          (with-slots ((x* x)
;;                       (y* y)
;;                       (width* width)
;;                       (height* height))
;;              (exwm-workspace--get-geometry exwm--frame)
;;            (setq x x*
;;                  y y*
;;                  width width*
;;                  height height*)))
;;        ;; edited here
;;	;; without this, centaur tabs tab bar not visible
;;        (when
;;              (and (not (bound-and-true-p centaur-tabs-local-mode))
;;                 (not ((setenv "_JAVA_AWT_WM_NONREPARENTING" "1")
(require 'exwm)
(require 'exwm-systemtray)
(require 'exwm-randr)
(require 'buffer-move)

;(add-to-list 'load-path "/usr/share/emacs/site-lisp/xelb")
;(add-to-list 'load-path "/usr/share/emacs/site-lisp/exwm")

(defun cc/exwm-show-all-buffers (b)
  ;; Automatically move EXWM buffer to current workspace when selected
  (setq exwm-layout-show-all-buffers b)
  ;; Display all EXWM buffers in every workspace buffer list
  (setq exwm-workspace-show-all-buffers b))

(defun cc/exwm-toggle-show-all-buffers ()
  (cc/exwm-show-all-buffers (not exwm-layout-show-all-buffers)))

(setq exwm-layout-show-all-buffers t)
(setq exwm-workspace-show-all-buffers t)

(defun cc/build-workspaces (l n)
  (cons
   (cons n (car l))
   (if (cdr l)
       (cc/build-workspaces (cdr l) (+ n 1))
     nil)))

;; (setq exwm-input-prefix-keysy
;;     '(?\C-x
;;       ?\C-u
;;       ?\C-h
;;       ?\M-x
;;       ?\M-`
;;       ?\M-&
;;       ?\M-:
;;       (kbd "<f2>")
;;       f2
;;       [f2]
;;       ?\C-\M-j  ;; Buffer list
;;       ?\C-\ ))  ;; Ctrl+Space

;(push (kbd "<f2>") exwm-input-prefix-keys)

;; Set the initial workspace number.

;(setq cc/arandr-file nil)
;(if cc/arandr-file (start-process-shell-command nil (format "~/.screenlayout/%s.sh" cc/arandr-file)))

(defun cc/exwm-randr-screen-change ()
  (setq cc/primary (process-lines "sh" "-c" "xrandr | sed -n  's:\\([^ ]\\) connected primary.*:\\1:p'"))
  (setq cc/secondary (process-lines "sh" "-c" "xrandr | grep -v 'connected primary' | sed -n  's:\\([^ ]\\) connected .*:\\1:p'"))
  (setq cc/tertiary '())
  (setq cc/screen-list (append cc/primary cc/secondary cc/tertiary))
  (setq exwm-randr-workspace-monitor-alist (cc/build-workspaces cc/screen-list 0))
  (setq exwm-randr-workspace-monitor-plist (list-utils-flatten exwm-randr-workspace-monitor-alist))
  (start-process-shell-command "autorandr" nil "autorandr --change" )
  (exwm-randr-refresh))
 ;; (let ((first (car cc/screen-list))
	;; (rest (cdr cc/screen-list)))
    ;; (dolist (screen rest)
      ;; (start-process-shell-command "xrandr" nil (format "xrandr --output %s --left-of %s --auto" screen first))))
  ;; (exwm-randr-refresh))

; multi monitor support
(add-hook 'exwm-randr-screen-change-hook #'cc/exwm-randr-screen-change)


;; Make buffer name more meaningful
;; (add-hook 'exwm-update-class-hook
          ;; (lambda ()
            ;; (exwm-workspace-rename-buffer exwm-class-name)))
(defun my/first-n-words (s n) (mapconcat (lambda (i) i) (seq-take (split-string s " ") n) " "))

(defun exwm-current-workspace()
  (exwm-workspace--position (exwm-workspace--workspace-from-frame-or-index (selected-frame))))

(defun prompt-workspace (current-prefix-arg)
  (list
   (cond
    ((null current-prefix-arg)
     (let ((exwm-workspace--prompt-add-allowed t)
           (exwm-workspace--prompt-delete-allowed t))
       (exwm-workspace--prompt-for-workspace "Move to [+/-]: ")))
    ((and (integerp current-prefix-arg)
                       (<= 0 current-prefix-arg (exwm-workspace--count)))
     current-prefix-arg)
    (t 0))))

(defun exwm-workspace-move-buffer (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (let ((buffer (current-buffer))
		(old-ws (exwm-current-workspace)))
	(previous-buffer)
	(exwm-workspace-switch frame-or-index)
	(switch-to-buffer buffer)))
   
(defun exwm-workspace-move-buffer-or-window (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (if exwm--id
	  (exwm-workspace-move-window frame-or-index)
	(exwm-workspace-move-buffer frame-or-index)))

(defun exwm-workspace-move-window-left ()
  (let* ((ws (exwm-current-workspace))
		(new-ws (- ws 1)))
	(if (<= 0 new-ws)
		(progn (exwm-workspace-move-buffer-or-window new-ws)
			   (exwm-workspace-switch new-ws)))))
	
(defun exwm-workspace-move-window-left-wrap ()
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (< 0 ws)
			(- ws 1)
			(- (length exwm-workspace--list) 1))))
	(exwm-workspace-move-buffer-or-window new-ws)
	(exwm-workspace-switch new-ws)))

(defun exwm-workspace-move-window-right ()
  (let* ((ws (exwm-current-workspace))
		 (new-ws (+ ws 1)))
	(if (< new-ws (length exwm-workspace--list))
		(progn (exwm-workspace-move-buffer-or-window new-ws)
			   (exwm-workspace-switch new-ws)))))

(defun exwm-workspace-move-window-right-wrap ()
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (< (+ ws 1) (length exwm-workspace--list))
			  (+ ws 1)
			  0)))
	(exwm-workspace-move-buffer-or-window new-ws)
	(exwm-workspace-switch new-ws)))

(defun exwm-workspace-switch-left ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws (- ws 1)))
	(if (<= 0 new-ws)
		(exwm-workspace-switch new-ws))))

(defun exwm-workspace-switch-left-wrap ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (< 0 ws)
			  (- ws 1)
			  (- (length exwm-workspace--list) 1))))
	(message "switched from workspace %s to %s of %s" ws new-ws (length exwm-workspace--list))
	(exwm-workspace-switch new-ws)))

(defun exwm-workspace-switch-right ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws (+ ws 1)))
	(if (< new-ws (length exwm-workspace--list))
		(exwm-workspace-switch (+ ws 1)))))

(defun exwm-workspace-switch-right-wrap ()
  (interactive)
  (let* ((ws (exwm-current-workspace))
		 (new-ws 
		  (if (<= (length exwm-workspace--list) (+ ws 1))
			  0
			  (+ ws 1))))
	(message "switched from workspace %s to %s of %s" ws new-ws (length exwm-workspace--list))
	(exwm-workspace-switch new-ws)))

(defun exwm-buf-move-window-left ()
  (interactive)
  (if (windmove-find-other-window 'left)
	  (buf-move-left)
	(progn (exwm-workspace-move-window-left)
	  (buf-move-right))))

(defun exwm-buf-move-window-right ()
  (interactive)
  (if (windmove-find-other-window 'right)
	  (buf-move-right)
	(progn (exwm-workspace-move-window-right)
		   (buf-move-far-left))))

(defun exwm-windmove-right ()
  (if (null (windmove-find-other-window 'right))
	  (exwm-workspace-switch-right)
	(windmove-right)))

(defun exwm-windmove-left ()
  (if (null (windmove-find-other-window 'left))
	  (exwm-workspace-switch-left)
	(windmove-left)))

(defun cc/exwm-update-title ()
  (cond
   ((string-match-p "Gmail" exwm-title)
    (exwm-workspace-rename-buffer "Gmail"))
   ((string-match-p "Google Keep" exwm-title)
    (exwm-workspace-rename-buffer "Keep"))
   ((string-match-p "YouTube" exwm-title)
    (exwm-workspace-rename-buffer exwm-title))
   ((string-match-p "Google Translate" exwm-title)
    (exwm-workspace-rename-buffer "Translate"))
   ((string-match-p "Google Contacts" exwm-title)
    (exwm-workspace-rename-buffer "Contacts"))
   ((string-match-p "Slack" exwm-class-name)
    (exwm-workspace-rename-buffer "Slack"))
   ((string-match-p "KeePassXC" exwm-class-name)
    (exwm-workspace-rename-buffer "KeePassXC"))
   ((string-match-p "Messenger" exwm-title)
    (exwm-workspace-rename-buffer "Messenger"))
   ((string-match-p "YouTube" exwm-title)
    (exwm-workspace-rename-buffer "YouTube"))
   ((string-match-p "Gmail" exwm-title)
    (exwm-workspace-rename-buffer "Gmail"))
   ((string= "net-sourceforge-squirrel_sql-client-Main" exwm-class-name)
    (exwm-workspace-rename-buffer (replace-regexp-in-string "Session: [0-9]* - \\(.*\\)" "\\1" exwm-title)))
   ((string= exwm-class-name "Google-chrome")
    ;; (exwm-workspace-rename-buffer (format "C | %s" (my/first-n-words exwm-title 3))))
    (exwm-workspace-rename-buffer (format "C:%s" exwm-title)))
   ((string= exwm-class-name "firefox")
    ;; (exwm-workspace-rename-buffer (format "F | %s" (my/first-n-words exwm-title 3))))
    (exwm-workspace-rename-buffer (format "F:%s" exwm-title)))
   ((string= exwm-class-name "Vivaldi-stable")
    (exwm-workspace-rename-buffer (format "V:%s" exwm-title)))
   ((or (string= exwm-class-name "com-jetbrains-toolbox-entry-ToolboxEntry")
	(string= exwm-class-name "jetbrains-toolbox"))
     (exwm-workspace-rename-buffer "Jetbrains Toolbox"))
   ((string= exwm-class-name "jetbrains-idea")
     (exwm-workspace-rename-buffer (format "Idea | %s" exwm-title)))
   (t (exwm-workspace-rename-buffer (format "%s | %s" exwm-class-name exwm-title)))))

(add-hook 'exwm-update-title-hook #'cc/exwm-update-title)

 ;; Global keybindings.
(setq exwm-input-global-keys
      `(([?\s-r] . (lambda () (interactive) (exwm-reset) (message "line-mode"))) ;; s-r: Reset (to line-mode).
        ([?\s-k] . exwm-input-release-keyboard)
	([?\s-z] . exwm-input-toggle-keyboard)
	([?\s-c] . exwm-workspace-toggle-minibuffer)
	(,(kbd "<f7>") . exwm-input-toggle-keyboard)
        ;; ([?\s-a] . (lambda () (interactive) (cc/exwm-toggle-show-all-buffers)))
        ;; ([?\s-k] . (lambda () (interactive) (exwm-input-release-keyboard) (message "char-mode")))
    ([?\s-w] . exwm-workspace-switch) ;; s-w: Switch workspace.
    ([?\s-&] . (lambda (cmd) ;; s-&: Launch application. 
                 (interactive (list (read-shell-command "$ ")))
                 (start-process-shell-command cmd nil cmd)))
	([f2] . (lambda () (interactive) (exwm-input-toggle-keyboard)))
;	([f2] . (lambda () (interactive) (my/toggle-line-char)))
	([?\s-p] . (lambda () (interactive) (message (symbol-name exwm--input-mode))))
	([?\s-s] . (lambda () (interactive) (efs/run-in-background "xscreensaver-command --activate")))
	([?\s-l] . (lambda () (interactive) (efs/run-in-background "xscreensaver-command --lock")))
	([?\s- ] . (lambda () (interactive) (efs/run-in-background "rofi -show combi")))
;	([?\s-l] . (lambda () (interactive) (start-process "xscreensaver-command", nil, "xscreensaver-command --lock")))
	([?\C-`] . kill-current-buffer)
	([?\s-`] . bury-buffer)
	([?\s-h] . exwm-floating-hide)
	([?\s-f] . exwm-floating-toggle-floating)
	([?\s-a] . exwm-layout-toggle-fullscreen)
	([?\s-g] . exwm-input-grab-keyboard)
	([?\s-m] . exwm-workspace-move-window)
	(,(kbd "M-<left>") . exwm-windmove-left)
	(,(kbd "M-<right>") . exwm-windmove-right)
	(,(kbd "M-<up>") . windmove-up)
	(,(kbd "M-<down>") . windmove-down)

	(,(kbd "S-M-<left>") . exwm-workspace-switch-left)
	(,(kbd "S-M-<right>") . exwm-workspace-switch-right)

	
	(,(kbd "s-<left>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move -10 0)
							 (exwm-buf-move-window-left))))
	(,(kbd "s-<right>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move 10 0)
							 (exwm-buf-move-window-right))))
	(,(kbd "s-<up>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move 0 -10)
							 (buf-move-up))))
	(,(kbd "s-<down>") . (lambda () (interactive)
						   (if exwm--floating-frame
							   (exwm-floating-move 0 10)
							 (buf-move-down))))

	(,(kbd "S-s-<left>") . (lambda () (interactive)
							 (exwm-workspace-move-window-left)))
	(,(kbd "S-s-<right>") . (lambda () (interactive)
							 (exwm-workspace-move-window-right)))

;	(,(kbd "S-s-<left>") . windmove-swap-states-left)
;	(,(kbd "S-s-<right>") . windmove-swap-states-right)
;	(,(kbd "S-s-<up>") . windmove-swap-states-up)
;	(,(kbd "S-s-<down>") . windmove-swap-states-down)

;	(,(kbd "C-<left>") . shrink-window-horizontally)
;	(,(kbd "C-<right>") . enlarge-window-horizontally)
;	(,(kbd "C-<up>") . enlarge-window)
;	(,(kbd "C-<down>") . shrink-window)

	(,(kbd "C-<left>") . (lambda () (interactive) (exwm-layout-shrink-window-horizontally 10)))
	(,(kbd "C-<right>") . (lambda () (interactive) (exwm-layout-enlarge-window-horizontally 10)))
	(,(kbd "C-<up>") . (lambda () (interactive) (exwm-layout-enlarge-window 10)))
	(,(kbd "C-<down>") . (lambda () (interactive) (exwm-layout-shrink-window 10)))

	
	(,(kbd "C-g") . prot/keyboard-quit-dwim)

		;	([?\s-z] . (lambda () (interactive) (ace-window nil)))
        ;; s-N: Switch to certain workspace.
        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))
(exwm-input--update-global-prefix-keys) ;; not necessary on startup, but maybe later
   

;; To add a key binding only available in line-mode, simply define it in
;; `exwm-mode-map'.  The following example shortens 'C-c q' to 'C-q'.
(define-key exwm-mode-map [?\C-q] #'exwm-input-send-next-key)

(setq sim-key-basic
      ;; movement, cursor
      '(([?\C-b] . [left])
        ([?\C-f] . [right])
        ([?\C-p] . [up])
        ([?\C-n] . [down])
	;; forward back word
        ([?\M-b] . [C-left])
        ([?\M-f] . [C-right])
	;; move on line
        ([?\C-a] . [home])
        ([?\C-e] . [end])
	;; move by page
        ([?\M-v] . [prior])
        ([?\C-v] . [next])
	;; beginning and end of file
	([?\M-<] . [C-home])
	([?\M->] . [C-end])
        ;; cut/paste.
        ([?\C-w] . [C-x])
        ([?\M-w] . [C-c])
        ([?\C-y] . [C-v])
	;; delete
        ([?\C-d] . [delete])
        ([?\M-d] . [C-delete])
        ([?\C-k] . [S-end delete])
	;; undo
        ([?\C-/] . [C-z])
	;; search
	([?\C-s] . [C-f])
	;; change case
	([?\C-r] . [S-F3])
	;; search and replace
	([?\M-%] . [C-h])))
	;; ((kbd "C-x h") . [C-a])))
	;; ([?\C-x h] . [C-home C-a])
	;; ([?\C-x f] . [C-o])
	;; ([?\C-x C-s] . [C-s])
	;; ([?\C-x k] . [C-F4])
	;; ([?\C-x C-c] . [C-q])
	;; ([?\C-x C-u] . [C-z])
	;; ([?\C-x C-u] . [C-z])
	;; ([?\C-x 5 0] . [M-F4])))

(setq sim-key-general
      (append
       sim-key-basic
	 '(([?\C-\`] . [C-q]))))

;; (setq sim-key-idea      '(([?\C-c ?\C-c] . [C-c C-c])))


(setq sim-key-browser
      (append
       sim-key-basic
       '(([?\C-l] . [C-r])
;	 ((kbd "C-x C-left") 
;	 ([?\C-x ?\C-f] . [C-t])
;	 ([?\C-\`] . [C-w])
;	 ([?\s-left] . [s-left])
;	 ([?\s-right] . [s-right])
;	 ([?\s-up] . [s-up])
;	 ([?\s-down] . [s-down])
	 ([?\C-x ?k] . [C-w]))))

(defun cc/exwm-manage-finish ()
  (if exwm-class-name
      (cond 
       ((or (string= exwm-class-name "emacs.Emacs")
	    (string= exwm-class-name "konsole")
	    (string= exwm-class-name "org.gnome.Console")
	    (string= exwm-class-name "jetbrains-idea")
	    (string= exwm-class-name "kgx"))
	(exwm-input-set-local-simulation-keys nil))
       ;; ((string= exwm-class-name "jetbrains-idea")
	;; (exwm-input-set-local-simulation-keys sim-key-idea))
       ((or (string= exwm-class-name "Google-chrome")
	    (string= exwm-class-name "Vivaldi-stable")
	    (string= exwm-class-name "firefox"))
	(exwm-input-set-local-simulation-keys sim-key-browser))
       ;; ((or (string= exwm-class-name "jetbrains-toolbox"))
	;; (exwm-floating-toggle-floating)
	;; (exwm-input-set-local-simulation-keys sim-key-general))
       (t
	(exwm-input-set-local-simulation-keys sim-key-basic)))))

(add-hook 'exwm-manage-finish-hook #'cc/exwm-manage-finish)

(setq exwm-manage-configurations '(((or (string= exwm-class-name "jetbrains-toolbox")
				        (string= exwm-class-name "com-jetbrains-toolbox-entry-ToolboxEntry"))
                                    floating nil)))

;; (setq exwm-manage-configurations '((t floating nil)))


(setq exwm-systemtray-height 20)


(defun cc/exwm-init ()
;  (cc/exwm-randr-screen-change)
  (exwm-workspace-switch-create (car (car (last exwm-randr-workspace-monitor-alist))))
  (efs/run-in-background "~/.config/polybar/launch.sh")
  (efs/run-in-background "nm-applet")
  (efs/run-in-background "insync start")
  (efs/run-in-background "blueman-applet")
  (efs/run-in-background "udiskie --tray")
  (efs/run-in-background "indicator-sound-switcher")
;  (efs/run-in-background "jetbrains-toolbox")
  (efs/run-in-background "picom") ; composite manager, plank prefers it
  (efs/run-in-background "plank -n dock1"))

(add-hook 'exwm-init-hook #'cc/exwm-init)

;;  (efs/run-in-background "pavucontrol")
			    
;; Enable EXWM
					;(require 'exwm-config)
(display-battery-mode 1)
(setq display-time-day-and-date t)
(display-time-mode 1)


;(counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
;(exwm-input-set-key (kbd "s-SPC") 'counsel-linux-app)
;; (exwm-input-set-key (kbd "s-f") 'exwm-layout-toggle-fullscreen)





;; (setq exwm-randr-workspace-monitor-plist '(1 "HDMI-1" 2 "DP-1"))

;; (defun exwm-change-screen-hook ()
;;   (let ((xrandr-output-regexp "^\\([^ ]+\\) connected ")
;; 	default-output)
;;     (with-temp-buffer
;;       (call-process "xrandr" nil t nil)
;;       (goto-char (point-min))
;;       (re-search-forward xrandr-output-regexp nil 'noerror)
;;       (setq default-output (match-string 1))
;;       (forward-line)
;;       (if (not (re-search-forward xrandr-output-regexp nil 'noerror))
;; 	  (call-process "xrandr" nil nil nil "--output" default-output "--auto")
;; 	(call-process
;;          "xrandr" nil nil nil
;;          "--output" (match-string 1) "--primary" "--auto"
;;          "--output" default-output "--off")
;; 	(setq exwm-randr-workspace-monitor-plist (list 0 (match-string 1)))))))
    

;; send mouse to current workspace
(setq exwm-workspace-warp-cursor t)

;(setq mouse-autoselect-window t
;      focus-follows-mouse t)


(exwm-randr-mode 1)

;(exwm-systemtray-mode 1)
(exwm-enable)
;(exwm-config-example)

;(print (kbd "<F1>"))

;(efs/run-in-background "jetbrains-toolbox")

(require 'fancy-battery)
(fancy-battery-mode)

(exwm-input-set-key
 (kbd "<XF86AudioLowerVolume>")
 (lambda () (interactive)
   (shell-command "volume -5%")))
                ;; (lambda () (interactive) (shell-command "amixer set Master 5%- | sed -nr 's/.*: Playback.*?\\[([[:digit:]%]*)\\].*/\\1/gp' | head -1")))
(exwm-input-set-key
 (kbd "<XF86AudioRaiseVolume>")
 (lambda () (interactive)
   (shell-command "volume +5%")))
                ;; (lambda () (interactive) (shell-command "amixer set Master 5%+ | sed -nr 's/.*: Playback.*?\\[([[:digit:]%]*)\\].*/\\1/gp' | head -1")))
(exwm-input-set-key (kbd "<XF86AudioMute>")
                    (lambda () (interactive) (shell-command "volume toggle")))
                    ;; (lambda () (interactive) (shell-command "amixer set Master 1+ toggle | sed -nr 's/.*: Playback.*?\\[([[:alpha:]]*)\\].*/\\1/gp' | head -1")))
(exwm-input-set-key (kbd "<XF86MonBrightnessDown>") (lambda () (interactive) (shell-command "brightnessctl -q s 2%- ; brightnessctl g")))
(exwm-input-set-key (kbd "<XF86MonBrightnessUp>") (lambda () (interactive) (shell-command "brightnessctl -q s 2%+ ; brightnessctl g")))
(exwm-input-set-key (kbd "<print>") (lambda () (interactive) (start-process-shell-command "spectacle" nil "spectacle")))
  
;; for emacsclient
(server-start)

(defun exwm-async-run (name)
  "Run a process asynchronously"
  (interactive)
  (start-process name nil name))

(defun run-or-raise-or-dismiss (program program-buffer-name)
  "If no instance of the program is running, launch the program.
If an instance already exists, and its corresponding buffer is
displayed on the screen, move to the buffer. If the buffer is not
visible, switch to the buffer in the current window. Finally, if
the current buffer is already that of the program, bury the
buffer (=minimizing in other WM/DE)"
  ;; check current buffer
  (if (string= (buffer-name) program-buffer-name)
      (bury-buffer)
    ;; either switch to or launch program
    (progn
      (if (get-buffer program-buffer-name)
          (progn
            (if (get-buffer-window program-buffer-name)
                (select-window (display-buffer program-buffer-name) nil)
              (exwm-workspace-switch-to-buffer program-buffer-name)))
        ;; start program
        (exwm-async-run program)))))



;; (defun efs/start-panel ()
  ;; (interactive)
  ;; (efs/kill-panel)
  ;; (setq efs/polybar-process (start-process-shell-command "polybar" nil "polybar panel")
  ;; (set-process-query-on-exit-flag efs/polybar-process nil)))

(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))


;(use-package my/foo/package :after exwm :config
;(after! exwm
;;  (defun exwm-layout--show (id &optional window)
;;    "Show window ID exactly fit in the Emacs window WINDOW."
;;    (exwm--log "Show #x%x in %s" id window)
;;    (let* ((edges (window-inside-absolute-pixel-edges window))
;;           (x (pop edges))
;;           (y (pop edges))
;;           (width (- (pop edges) x))
;;           (height (- (pop edges) y))
;;           frame-x frame-y frame-width frame-height)
;;      (with-current-buffer (exwm--id->buffer id)
;;        (when exwm--floating-frame
;;          (setq frame-width (frame-pixel-width exwm--floating-frame)
;;                frame-height (+ (frame-pixel-height exwm--floating-frame)
;;                                ;; Use `frame-outer-height' in the future.
;;                                exwm-workspace--frame-y-offset))
;;          (when exwm--floating-frame-position
;;            (setq frame-x (elt exwm--floating-frame-position 0)
;;                  frame-y (elt exwm--floating-frame-position 1)
;;                  x (+ x frame-x (- exwm-layout--floating-hidden-position))
;;                  y (+ y frame-y (- exwm-layout--floating-hidden-position)))
;;            (setq exwm--floating-frame-position nil))
;;          (exwm--set-geometry (frame-parameter exwm--floating-frame
;;                                               'exwm-container)
;;                              frame-x frame-y frame-width frame-height))
;;        (when (exwm-layout--fullscreen-p)
;;          (with-slots ((x* x)
;;                       (y* y)
;;                       (width* width)
;;                       (height* height))
;;              (exwm-workspace--get-geometry exwm--frame)
;;            (setq x x*
;;                  y y*
;;                  width width*
;;                  height height*)))
;;        ;; edited here
;;	;; without this, centaur tabs tab bar not visible
;;        (when
;;              (and (not (bound-and-true-p centaur-tabs-local-mode))
;;                 (not (exwm-layout--fullscreen-p))
;;                 (or (bound-and-true-p centaur-tabs-mode)))
;;		     (setq y (+ y centaur-tabs-height)))
;;        (when (bound-and-true-p tab-line-mode) 
;;	  (setq y (+ y 30))) ; guesswork number, but not sure what is better
;;        ;; end edited here
;;        (exwm--set-geometry id x y width height)
;;        (xcb:+request exwm--connection (make-instance 'xcb:MapWindow :window id))
;;        (exwm-layout--set-state id xcb:icccm:WM_STATE:NormalState)
;;        (setq exwm--ewmh-state
;;              (delq xcb:Atom:_NET_WM_STATE_HIDDEN exwm--ewmh-state))
;;        (exwm-layout--set-ewmh-state id)
;;        (exwm-layout--auto-iconify)))
;;    (xcb:flush exwm--connection))
;;;)
;;



;;exwm-layout--fullscreen-p))
;;                 (or (bound-and-true-p centaur-tabs-mode)))
;;		     (setq y (+ y centaur-tabs-height)))
;;        (when (bound-and-true-p tab-line-mode) 
;;	  (setq y (+ y 30))) ; guesswork number, but not sure what is better
;;        ;; end edited here
;;        (exwm--set-geometry id x y width height)
;;        (xcb:+request exwm--connection (make-instance 'xcb:MapWindow :window id))
;;        (exwm-layout--set-state id xcb:icccm:WM_STATE:NormalState)
;;        (setq exwm--ewmh-state
;;              (delq xcb:Atom:_NET_WM_STATE_HIDDEN exwm--ewmh-state))
;;        (exwm-layout--set-ewmh-state id)
;;        (exwm-layout--auto-iconify)))
;;    (xcb:flush exwm--connection))
;;;)
;;




