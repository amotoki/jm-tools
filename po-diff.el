;; MIT License
;;
;; Copyright (c) 2021 Akihiro Motoki
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;; Setup: Add the following to your ~/.emacs
;;
;;   (autoload 'po-diff "po-diff" nil t)
;;   (require 'po-mode)
;;   (define-key po-mode-map "\M-=" 'po-diff)
;;
;; Additional configurations which are not directly related to po-diff.el
;; but may help you.
;;
;;   ;; po-diff.el does not provide a way to go back to the original buffer.
;;   ;; The following keyboard macro might help you.
;;   (fset 'po-back-from-ediff "\C-x1\C-xb\C-m")
;;   (global-set-key "\C-xp" 'po-back-from-ediff)
;;
;;   ;; Turn off auto-fill-mode in PO edit buffer
;;   (add-hook 'po-subedit-mode-hook '(lambda () (auto-fill-mode 0)))

(require 'ediff)

(defun po-diff-copy-string-from-po (srcbuf dstbuf regex-beg regex-end oldp)
  (save-excursion
    (let (beg end)
      (re-search-backward "^$" nil t)
      (re-search-forward regex-beg nil t)
      (beginning-of-line)
      (setq beg (point))
      (re-search-forward regex-end nil t)
      (beginning-of-line)
      (setq end (point))
      (switch-to-buffer dstbuf)
      (setq buffer-file-name nil)
      (erase-buffer)
      (insert-buffer-substring srcbuf beg end)
      (when oldp
	(goto-char (point-min))
	(replace-regexp "^#| " ""))
      (goto-char (point-min))
      (replace-regexp "^msgid " "")
      (goto-char (point-min))
      (replace-regexp "^\"" "")
      (goto-char (point-min))
      (replace-regexp "\"$" "")
      (list (point-min) (point-max))
    )))

(defun po-diff-ensure-new-buffer (bufname)
  (if (get-buffer bufname)
      (kill-buffer (get-buffer bufname)))
  (get-buffer-create bufname))

(defun po-diff ()
  (interactive)
  (save-excursion
    (let (cb buf1 region1
	     buf2 region2)
      (setq cb (current-buffer)
	    buf1 (po-diff-ensure-new-buffer " *PO diff (1)*")
	    buf2 (po-diff-ensure-new-buffer " *PO diff (2)*"))
      ;; Old msgid
      (setq region1 (po-diff-copy-string-from-po cb buf1 "^#| msgid \"" "^msgid \"" t))
      ;; Current msgid
      (setq region2 (po-diff-copy-string-from-po cb buf2 "^msgid \"" "^msgstr \"" nil))
      (ediff-regions-internal
       buf1 (car region1) (cadr region1)
       buf2 (car region2) (cadr region2)
       () 'ediff-regions-wordwise 'word-mode nil)
      )))

(provide 'po-diff)
