;;; $Id: maxframe.el 367 2007-03-29 19:46:23Z ryan $
;; maximize the emacs frame based on display size

;; Copyright (C) 2007 Ryan McGeary
;; Version: 0.1  Author: Ryan McGeary
;; Keywords: display frame window maximize

;; This code is free; you can redistribute it and/or modify it under the
;; terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.

;;; Commentary:
;;
;; Purpose
;; -------
;; maxframe provides the ability to maximize the emacs frame and stay within
;; the display resolution.
;;
;; Usage
;; -----
;; Example of lines to be added to your .emacs:
;;
;;     (require 'maxframe)
;;     (add-hook 'window-setup-hook 'maximize-frame t)
;;
;; How it works
;; ------------
;; puts the emacs frame in the top left corner of the display and calculates
;; the maximum number of columns and rows that can fit in the display
;;
;; Limitations
;; -----------
;; Requires Emacs 22 (for fringe support), but maximize-frame still works
;; under Emacs 21 on Windows.
;;
;; Emacs does not recognize when the display's resolution is changed. This is
;; a problem because I would like to be able to re-maximize the frame after
;; connecting to a display with different resolution. Unfortunately,
;; display-pixel-width and display-pixel-height yield the display resolution
;; values from when emacs was started instead of the current display
;; values. Perhaps there's a way to have emacs re-sniff these values, but I'm
;; not yet sure how.


(defgroup maxframe nil "Handle maximizing frames.")

(defcustom mf-display-padding-width 0
  "*Any extra display padding that you want to account for while
determining the maximize number of columns to fit on a display"
  :type 'integer
  :group 'maxframe)

;; The default accounts for a Mac OS X display with a menubar 
;; height of 22 pixels, a titlebar of 23 pixels, and no dock.
(defcustom mf-display-padding-height (+ 22 23)
  "*Any extra display padding that you want to account for while
determining the maximize number of rows to fit on a display"
  :type 'integer
  :group 'maxframe)

(defun w32-maximize-frame ()
  "Maximize the current frame (windows only)"
  (interactive)
  (w32-send-sys-command 61488))

(defun w32-restore-frame ()
  "Restore a minimized/maximized frame (windows only)"
  (interactive)
  (w32-send-sys-command 61728))

(defun mf-max-columns (width)
  "Calculates the maximum number of columns that can fit in
pixels specified by WIDTH."
  (let ((scroll-bar (or (frame-parameter nil 'scroll-bar-width) 0))
        (left-fringe (or left-fringe-width (nth 0 (window-fringes)) 0))
        (right-fringe (or right-fringe-width (nth 1 (window-fringes)) 0)))
    (/ (- width scroll-bar left-fringe right-fringe
          mf-display-padding-width)
       (frame-char-width))))

(defun mf-max-rows (height)
  "Calculates the maximum number of rows that can fit in pixels
specified by HEIGHT."
  (/ (- height
        mf-display-padding-height)
     (frame-char-height)))

(defun mf-set-frame-pixel-size (frame width height)
  "Sets size of FRAME to WIDTH by HEIGHT, measured in pixels."
  (set-frame-size frame (mf-max-columns width) (mf-max-rows height)))

(defun x-maximize-frame ()
  "Maximize the current frame (x or mac only)"
  (interactive)
  (mf-set-frame-pixel-size (selected-frame)
                           (display-pixel-width)
                           (display-pixel-height))
  (set-frame-position (selected-frame) 0 0))

(defun maximize-frame ()
  "Maximizes the frame to fit the display if under a windowing
system."
  (interactive)
  (cond ((eq window-system 'w32) (w32-maximize-frame))
        ((memq window-system '(x mac)) (x-maximize-frame))))

(defalias 'mf 'maximize-frame)

(provide 'maxframe)
