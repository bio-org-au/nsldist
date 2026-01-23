
(require 'framemove)

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

(defun winframe-buf-or-window-move-to (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (if exwm--id
	  (exwm-workspace-move-window frame-or-index)
	(exwm-workspace-move-buffer frame-or-index)))

(defun winframe-buf-move-far (dir)
    (interactive)
  (while (windmove-find-other-window dir)
	(buf-move-to dir)))

(defun winframe-buf-or-window-move (dir)
  (if-let ((ow (winframe-find-other-window dir)))
	  (buf-move-to dir)
	(if-let* ((of (fm-find-next-frame dir)))
		(progn (winframe-buf-or-window-move-to of)
			   (winframe-buf-move-far (windframe-opposite dir))))))


(provide 'winframe-move)

