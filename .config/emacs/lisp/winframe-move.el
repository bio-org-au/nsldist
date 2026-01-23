
(require 'framemove)

;;
;; MOVE FOCUS
;;

(defun winframe-find-other-window (dir)
  (if-let* ((ow (windmove-find-other-window dir))
			  (mb? (not (window-minibuffer-p ow))))
	  ow
	nil))


(defun winframe-move (dir)
  (if-let ((ow (winframe-find-other-window dir)))
	(windmove-do-window-select dir)
	(fm-next-frame dir)))

(defun winframe-move-left ()
  (interactive)
  (winframe-move 'left))

(defun winframe-move-right ()
  (interactive)
  (winframe-move 'right))

(defun winframe-move-up ()
  (interactive)
  (winframe-move 'up))

(defun winframe-move-down ()
  (interactive)
  (winframe-move 'down))

;;
;; MOVE A BUFFER/X-WINDOW
;;

(defun winframe-buf-move-to (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (let ((buffer (current-buffer)))
	(previous-buffer)
	(exwm-workspace-switch frame-or-index)
	(switch-to-buffer buffer)))

(defun winframe-opposite (dir)
  (cl-ecase dir
	(left 'right)
	(right 'left)
	(up 'down)
	(down 'up)))

(defun winframe-buf-move-to (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (let ((buffer (current-buffer)))
	(previous-buffer)
	(exwm-workspace-switch frame-or-index)
	(switch-to-buffer buffer)))

(defun winframe-buf-or-window-move-to (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (if exwm--id
	  (progn (exwm-workspace-move-window frame-or-index)
			 (exwm-workspace-switch frame-or-index)
			 (switch-to-buffer buffer))
	(winframe-buf-move-to frame-or-index)))

(defun winframe-buf-move-far (dir)
    (interactive)
  (while (winframe-find-other-window dir)
	(buf-move-to dir)))


(defun winframe-buf-or-window-move (dir)
  (if-let ((ow (winframe-find-other-window dir)))
	  (buf-move-to dir)
	(if-let* ((of (fm-find-next-frame dir)))
		(progn (winframe-buf-or-window-move-to of)
			   (winframe-buf-move-far (winframe-opposite dir))))))

(defun winframe-buf-move (dir)
  (if-let ((ow (winframe-find-other-window dir)))
	  (buf-move-to dir)
	(if-let* ((of (fm-find-next-frame dir)))
		(progn (winframe-buf-move-to of)
			   (winframe-buf-move-far (winframe-opposite dir))))))

(defun winframe-buf-or-window-move-left ()
  (interactive)
  (winframe-buf-or-window-move 'left))

(defun winframe-buf-or-window-move-right ()
  (interactive)
  (winframe-buf-or-window-move 'right))

(defun winframe-buf-or-window-move-up ()
  (interactive)
  (winframe-buf-or-window-move 'up))

(defun winframe-buf-or-window-move-down ()
  (interactive)
  (winframe-buf-or-window-move 'down))

(defvar winframe-floating-move-amount 10 "Increment to move floating window")

(defun winframe-floating-move (dir)
  (cl-ecase dir
	(left (exwm-floating-move (- winframe-floating-move-amount) 0))
	(right (exwm-floating-move winframe-floating-move-amount 0))
	(up (exwm-floating-move 0 (- winframe-floating-move-amount))
	(down (exwm-floating-move 0 winframe-floating-move-amount)))))

(defun winframe-buf-or-window-or-floating-move (dir)
  (interactive)
  (if exwm--floating-frame
	  (winframe-floating-move dir)
	(winframe-buf-or-window-move dir)))

(defun winframe-buf-or-window-or-floating-move-left ()
  (interactive)
  (winframe-buf-or-window-or-floating-move 'left))

(defun winframe-buf-or-window-or-floating-move-right ()
  (interactive)
  (winframe-buf-or-window-or-floating-move 'right))

(defun winframe-buf-or-window-or-floating-move-up ()
  (interactive)
  (winframe-buf-or-window-or-floating-move 'up))

(defun winframe-buf-or-window-or-floating-move-down ()
  (interactive)
  (winframe-buf-or-window-or-floating-move 'down))

(provide 'winframe-move)

