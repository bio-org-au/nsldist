
(require 'framemove)
(require 'buffer-move)

;;
;; FOCUS
;;

(defun wf/winframe-find-other-window (dir)
  (if-let* ((ow (windmove-find-other-window dir))
			  (mb? (not (window-minibuffer-p ow))))
	  ow
	nil))

(defun wf/winframe-focus (dir)
  (if-let ((ow (wf/winframe-find-other-window dir)))
	(windmove-do-window-select dir)
	(fm-next-frame dir)))

(defun wf/winframe-focus-left ()
  (interactive)
  (wf/winframe-focus 'left))

(defun wf/winframe-focus-right ()
  (interactive)
  (wf/winframe-focus 'right))

(defun wf/winframe-focus-up ()
  (interactive)
  (wf/winframe-focus 'up))

(defun wf/winframe-focus-down ()
  (interactive)
  (wf/winframe-focus 'down))

;;
;; MOVE A BUFFER/X-WINDOW
;;

(defun wf/winframe-buf-move-to (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (let ((buffer (current-buffer)))
	(previous-buffer)
	(exwm-workspace-switch frame-or-index)
	(switch-to-buffer buffer)))

(defun wf/winframe-opposite (dir)
  (cl-ecase dir
	(left 'right)
	(right 'left)
	(up 'down)
	(down 'up)))

(defun wf/winframe-buf-move-to (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (let ((buffer (current-buffer)))
	(previous-buffer)
	(exwm-workspace-switch frame-or-index)
	(switch-to-buffer buffer)))

(defun wf/winframe-buf-or-window-move-to (frame-or-index)
  (interactive (prompt-workspace current-prefix-arg))
  (if exwm--id
	  (progn (exwm-workspace-move-window frame-or-index)
			 (exwm-workspace-switch frame-or-index)
			 (switch-to-buffer buffer))
	(wf/winframe-buf-move-to frame-or-index)))

(defun wf/winframe-buf-move-far (dir)
    (interactive)
  (while (wf/winframe-find-other-window dir)
	(buf-move-to dir)))


(defun wf/winframe-buf-or-window-move (dir)
  (if-let ((ow (wf/winframe-find-other-window dir)))
	  (buf-move-to dir)
	(if-let* ((of (fm-find-next-frame dir)))
		(progn (wf/winframe-buf-or-window-move-to of)
			   (wf/winframe-buf-move-far (wf/winframe-opposite dir))))))

(defun wf/winframe-buf-move (dir)
  (if-let ((ow (wf/winframe-find-other-window dir)))
	  (buf-move-to dir)
	(if-let* ((of (fm-find-next-frame dir)))
		(progn (wf/winframe-buf-move-to of)
			   (wf/winframe-buf-move-far (wf/winframe-opposite dir))))))

(defun wf/winframe-buf-or-window-move-left ()
  (interactive)
  (wf/winframe-buf-or-window-move 'left))

(defun wf/winframe-buf-or-window-move-right ()
  (interactive)
  (wf/winframe-buf-or-window-move 'right))

(defun wf/winframe-buf-or-window-move-up ()
  (interactive)
  (wf/winframe-buf-or-window-move 'up))

(defun wf/winframe-buf-or-window-move-down ()
  (interactive)
  (wf/winframe-buf-or-window-move 'down))

(defvar wf/winframe-floating-move-amount 10 "Increment to move floating window")

(defun wf/winframe-floating-move (dir)
  (cl-ecase dir
	(left (exwm-floating-move (- wf/winframe-floating-move-amount) 0))
	(right (exwm-floating-move wf/winframe-floating-move-amount 0))
	(up (exwm-floating-move 0 (- wf/winframe-floating-move-amount)))
	(down (exwm-floating-move 0 wf/winframe-floating-move-amount))))

(defun wf/winframe-buf-or-window-or-floating-move (dir)
  (interactive)
  (if exwm--floating-frame
	  (wf/winframe-floating-move dir)
	(wf/winframe-buf-or-window-move dir)))

(defun wf/winframe-buf-or-window-or-floating-move-left ()
  (interactive)
  (wf/winframe-buf-or-window-or-floating-move 'left))

(defun wf/winframe-buf-or-window-or-floating-move-right ()
  (interactive)
  (wf/winframe-buf-or-window-or-floating-move 'right))

(defun wf/winframe-buf-or-window-or-floating-move-up ()
  (interactive)
  (wf/winframe-buf-or-window-or-floating-move 'up))

(defun wf/winframe-buf-or-window-or-floating-move-down ()
  (interactive)
  (wf/winframe-buf-or-window-or-floating-move 'down))

;;
;; RESIZE
;;

(defvar wf/resize-amount 30 "Increment to resize window")


;; (defun wf/win-floating-resize (deltax deltay)
;;   "Resize the current floating frame horizontally by DELTA pixels."
;;   (interactive "nPixels to resize: ")
;;   (if exwm--floating-frame
;; 	  (set-frame-size (selected-frame) (+ (frame-pixel-width) deltax) (+ (frame-pixel-height) deltay) t)))


(defun wf/layout-resize (deltax deltay)
  (exwm-layout-enlarge-window deltax)
  (exwm-layout-enlarge-window deltay t))

(defun wf/buf-or-window-or-floating-resize (deltax deltay)
  (if exwm--floating-frame
	  (exwm-float-resize-delta deltax deltay)
	(wf/layout-resize deltax deltay)))

(defun wf/buf-or-window-or-floating-shrink-horizontally ()
  (interactive)
  (wf/buf-or-window-or-floating-resize (- wf/resize-amount) 0))

(defun wf/buf-or-window-or-floating-enlarge-horizontally ()
  (interactive)
  (wf/buf-or-window-or-floating-resize wf/resize-amount 0))

(defun wf/buf-or-window-or-floating-shrink-vertically ()
  (interactive)
  (wf/buf-or-window-or-floating-resize 0 (- wf/resize-amount)))

(defun wf/buf-or-window-or-floating-enlarge-vertically ()
  (interactive)
  (wf/buf-or-window-or-floating-resize 0 wf/resize-amount))

(provide 'winframe-move)


