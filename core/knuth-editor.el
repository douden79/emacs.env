;;; Knuth-editor.el --- Emacs Knuth: enhanced core editing experience.
;;
;;; Code:

;; Death to the tabs!  However, tabs historically indent to the next
;; 8-character offset; specifying anything else will cause *mass*
;; confusion, as it will change the appearance of every existing file.
;; In some cases (python), even worse -- it will change the semantics
;; (meaning) of the program.
;;
;; Emacs modes typically provide a standard means to change the
;; indentation width -- eg. c-basic-offset: use that to adjust your
;; personal indentation width, while maintaining the style (and
;; meaning) of any files you load.
(setq-default indent-tabs-mode nil)   ;; don't use tabs to indent
(setq-default tab-width 4)            ;; but maintain correct appearance
(scroll-bar-mode -1)

;; Newline at end of file
(setq require-final-newline t)

;; delete the selection with a keypress
(delete-selection-mode t)

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)

;; hippie expand is dabbrev expand on steroids
(setq hippie-expand-try-functions-list '( try-expand-dabbrev
                                          try-expand-dabbrev-all-buffers
                                          try-expand-dabbrev-from-kill
                                          try-complete-file-name-partially
                                          try-complete-file-name
                                          try-expand-all-abbrevs
                                          try-expand-list
                                          try-expand-line
                                          try-complete-lisp-symbol-partially
                                          try-complete-lisp-symbol ))

;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

;; smart pairing for all
(require 'smartparens-config)
(setq sp-base-key-bindings 'paredit)
(setq sp-autoskip-closing-pair 'always)
(setq sp-hybrid-kill-entire-symbol nil)
(sp-use-paredit-bindings)

(show-smartparens-global-mode +1)

;; disable annoying blink-matching-paren
(setq blink-matching-paren nil)

;; diminish keeps the modeline tidy
(require 'diminish)

;; meaningful names for buffers with the same name
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-separator "/")
(setq uniquify-after-kill-buffer-p t)    ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers

;; advise all window switching functions
;(add-hook 'mouse-leave-buffer-hook 'knuth-auto-save-command)

;(when (version<= "24.4" emacs-version)
;  (add-hook 'focus-out-hook 'knuth-auto-save-command))
;

(defadvice set-buffer-major-mode (after set-major-mode activate compile)
  "Set buffer major mode according to `auto-mode-alist'."
  (let* ((name (buffer-name buffer))
         (mode (assoc-default name auto-mode-alist 'string-match)))
    (with-current-buffer buffer (if mode (funcall mode)))))

;; highlight the current line
(global-hl-line-mode +1)

(require 'volatile-highlights)
(volatile-highlights-mode t)
(diminish 'volatile-highlights-mode)

;; tramp, for sudo access
(require 'tramp)
;; keep in mind known issues with zsh - see emacs wiki
(setq tramp-default-method "ssh")

;;; Bug flychecker sudo trampmode.
(add-hook 'find-file-hook
          (lambda ()
            (unless (tramp-tramp-file-p (buffer-file-name))
              (flycheck-mode))))

(set-default 'imenu-auto-rescan t)

;; flyspell-mode does spell-checking on the fly as you type
(require 'flyspell)
(setq ispell-program-name "aspell" ; use aspell instead of ispell
      ispell-extra-args '("--sug-mode=ultra"))

;; enabled change region case commands
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; enable erase-buffer command
(put 'erase-buffer 'disabled nil)

(require 'expand-region)

;; projectile is a project management mode
(require 'projectile)
(setq projectile-cache-file (expand-file-name  "projectile.cache" knuth-savefile-dir))
(projectile-global-mode t)

;; anzu-mode enhances isearch & query-replace by showing total matches and current match position
(require 'anzu)
(diminish 'anzu-mode)
(global-anzu-mode)

(global-set-key (kbd "M-%") 'anzu-query-replace)
(global-set-key (kbd "C-M-%") 'anzu-query-replace-regexp)

;; shorter aliases for ack-and-a-half commands
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)

;; dired - reuse current buffer by pressing 'a'
(put 'dired-find-alternate-file 'disabled nil)

;; always delete and copy recursively
(setq dired-recursive-deletes 'always)
(setq dired-recursive-copies 'always)

;; if there is a dired buffer displayed in the next window, use its
;; current subdir, instead of the current subdir of this dired buffer
(setq dired-dwim-target t)

;; enable some really cool extensions like C-x C-j(dired-jump)
(require 'dired-x)

;; ediff - don't start another frame
(require 'ediff)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; clean up obsolete buffers automatically
(require 'midnight)

(defadvice exchange-point-and-mark (before deactivate-mark activate compile)
  "When called with no active region, do not activate mark."
  (interactive
   (list (not (region-active-p)))))

(defmacro with-region-or-buffer (func)
  "When called with no active region, call FUNC on current buffer."
  `(defadvice ,func (before with-region-or-buffer activate compile)
     (interactive
      (if mark-active
          (list (region-beginning) (region-end))
        (list (point-min) (point-max))))))

(with-region-or-buffer indent-region)
(with-region-or-buffer untabify)

;; automatically indenting yanked text if in programming-modes
(defun yank-advised-indent-function (beg end)
  "Do indentation, as long as the region isn't too large."
  (if (<= (- end beg) prelude-yank-indent-threshold)
      (indent-region beg end nil)))

;; abbrev config
(add-hook 'text-mode-hook 'abbrev-mode)

;; make a shell script executable automatically on save
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;; whitespace-mode config
(require 'whitespace)
(setq whitespace-line-column 80) ;; limit line length
(setq whitespace-style '(face tabs empty trailing lines-tail))

;; saner regex syntax
(require 're-builder)
(setq reb-re-syntax 'string)

;; Compilation from Emacs
(defun knuth-colorize-compilation-buffer ()
  "Colorize a compilation mode buffer."
  (interactive)
  ;; we don't want to mess with child modes such as grep-mode, ack, ag, etc
  (when (eq major-mode 'compilation-mode)
    (let ((inhibit-read-only t))
      (ansi-color-apply-on-region (point-min) (point-max)))))

(require 'compile)
(setq compilation-ask-about-save nil  ; Just save before compiling
      compilation-always-kill t       ; Just kill old compile processes before
                                        ; starting the new one
      compilation-scroll-output 'first-error ; Automatically scroll to first
                                        ; error
      )

;; Colorize output of Compilation Mode, see
;; http://stackoverflow.com/a/3072831/355252
(require 'ansi-color)
(add-hook 'compilation-filter-hook #'knuth-colorize-compilation-buffer)

;; sensible undo
(global-undo-tree-mode)
(diminish 'undo-tree-mode)

;; enable winner-mode to manage window configurations
(winner-mode +1)

;; diff-hl
(global-diff-hl-mode +1)
(add-hook 'dired-mode-hook 'diff-hl-dired-mode)

;; semantic edit preference and setup.
(require 'cc-mode)
(require 'semantic)

(global-semanticdb-minor-mode 1)
(global-semantic-idle-scheduler-mode 1)

(semantic-mode 1)

;; semantic-mode system include paths
(semantic-add-system-include "/usr/include/boost" 'c++mode)
(semantic-add-system-include "/usr/include/")
(semantic-add-system-include "~/[KERNEL]/linux-3.12.20")

;;; source code information
(global-semantic-idle-summary-mode 1)

;;; global-semantic-stickfunc-mode
(global-semantic-stickyfunc-mode 1)

;;; folding function define
(add-hook 'c-mode-common-hook 'hs-minor-mode)
(global-set-key (kbd "C-b") 'hs-hide-block)
(global-set-key (kbd "C-s") 'hs-show-block)

;;; Description under url for e-ide and tips.
;;; tuhdo.github.io/c-ide.html
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t)

; set multiple cusor
(require 'multiple-cursors)
(global-set-key (kbd "C-l") 'mc/edit-lines)
(global-set-key (kbd "C-;") 'mc/mark-all-words-like-this)

;;; linux-c-mode setting
;;; linux kernel c style and mode
;;; under line fix path for your linux kernel directory.
(defun linux-c-mode ()
  "C mode with adjusted defaults for use with the Linux kernel."
  (interactive)
  (c-mode)
  (c-set-style "K&R")
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq c-basic-offset 8))

;;; python-mode
(add-hook 'python-mode-hook
          (function (lambda ()
                      (setq indent-tabs-mode t)
                      (setq tab-width 4)
                      (setq python-indent 4))))

;;; file property auto-mode-alist
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . linux-c-mode))

;;; default coding system setting
(prefer-coding-system 'utf-8)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;; coding system read file
(modify-coding-system-alist 'file "\\.c\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.py\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.S\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.h\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.txt\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.cpp\\'" 'utf-8)
(modify-coding-system-alist 'file "\\.txt\\'" 'utf-8)

; load korean font set.
(set-fontset-font "fontset-default" '(#x1100 . #xffdc)
                   '("Gulim" . "iso10646-1"))
(set-fontset-font "fontset-default" '(#xe0bc . #xf66e)
                   '("Gulim" . "iso10646-1"))

(setq face-font-rescale-alist
       '((".*hiragino.*" . 1.0)
		           (".*Gulim.*" . 1.0)))

;;; org2blog mode
(require 'org2blog-autoloads)

(setq org2blog/wp-blog-alist
	  '(("wordpress"
		 :url "http://kamase79.cafe24.com/wp/xmlrpc.php"
		 :username "knuth"
		 :default-title "Hello World"
		 :default-categories ("emacs")
		 :tags-as-categories nil)
		 ))

;; Auto-complete default true.
(require 'auto-complete)
(global-auto-complete-mode t)

;;; smex : A smart M-x enhancement for Emacs.
(require 'smex)         ; Not needed if you use package.el
(smex-initialize)       ; Canbe ommited. This might cause a (minimal) delay
                        ; when Smex is auto-initalized on its first run.
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)

;;; This is your Old M-x.
(global-set-key (kbd "C-c C-c M-x") 'excute-extended-command)

;;; max-listp-eval-depth
(setq max-lisp-eval-depth 10000)

;;; toggle fullscreen
;;; http://www.emacswiki.org/emacs/FullScreen
(defun toggle-fullscreen ()
  "Toggle full screen on X11"
  (interactive)
  (when (eq window-system 'x)
    (set-frame-parameter
     nil 'fullscreen
     (when (not (frame-parameter nil 'fullscreen)) 'fullboth))))
(global-set-key [f11] 'toggle-fullscreen)

;;; linumber default true.
(global-linum-mode 1)

;;; c-turn-on-eldoc-mode
;;; Provides helpful description of the arguments to C functions.
(add-hook 'c-mode-hook 'c-turn-on-eldoc-mode)

(provide 'knuth-editor)

;;; knuth-editor.el ends here
