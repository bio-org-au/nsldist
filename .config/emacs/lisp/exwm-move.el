
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

