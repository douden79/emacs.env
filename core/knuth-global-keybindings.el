 ;;; prelude-global-keybindings.el --- Emacs Prelude: some useful keybindings.
 ;;; copy

(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)

(setq org-agenda-files (list "~/Doc/2014/company.org"
			     "~/Doc/individual.org")) 
(setq org-todo-keywords
      '((sequence "TODO"
                  "MAYBE"
                  "NEXT"
                  "STARTED"
                  "WAITING"
                  "DELEGATED"
                  "|"
                  "DONE"
                  "DEFERRED"
                  "CANCELLED")))

(setq org-todo-keyword-faces
      '(("PROJ" :background "blue" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("TODO" :background "red1" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("NEXT" :background "red1" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("STARTED" :background "orange" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("WAITING" :background "yellow" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("DEFERRED" :background "gold" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("DELEGATED" :background "gold" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("MAYBE" :background "gray" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("APPT" :background "red1" :foreground "black" :weight bold :box (:line-width 2 :style released-button))
        ("DONE" :background "forest green" :weight bold :box (:line-width 2 :style released-button))
        ("CANCELLED" :background "lime green" :foreground "black" :weight bold :box (:line-width 2 :style released-button))))

 ;Align your code in a pretty way.
(global-set-key (kbd "C-x \\") 'align-regexp)

;; ecb mode
(require 'ecb)

;; custom-set-variables for ecb frame
(define-key ecb-mode-map (kbd "M-1") 'ecb-goto-window-directories)
(define-key ecb-mode-map (kbd "M-2") 'ecb-goto-window-sources)
(define-key ecb-mode-map (kbd "M-3") 'ecb-goto-window-methods)
(define-key ecb-mode-map (kbd "M-4") 'ecb-goto-window-history)
(define-key ecb-mode-map (kbd "M-5") 'ecb-goto-window-compilation)
(define-key ecb-mode-map (kbd "M-0") 'ecb-goto-window-edit1)

;; ecb compile window frame
(setq ecb-show-sources-in-directories-buffer 'always)
(setq ecb-compile-window-height 12)

;; move emacs windows
(global-set-key [M-left] 'windmove-left)
(global-set-key [M-right] 'windmove-right)
(global-set-key [M-up] 'windmove-up)
(global-set-key [M-down] 'windmove-down) 

(provide 'knuth-global-keybindings)

;;; helm-gtags mode configuration Section.
(require 'helm-config)
(require 'helm-gtags)

;;; Enable helm-gtags-mode
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'asm-mode-hook 'helm-gtags-mode)

;;; customize
(setq helm-gtags-path-style 'relative)
(setq helm-gtags-ignore-case t)
                                        ;(setq helm-gtags-read-only t)
(setq helm-gtags-auto-update t)

;; key bindings
(add-hook 'helm-gtags-mode-hook
          '(lambda ()
             (local-set-key (kbd "M-t") 'helm-gtags-pop-stack)
             (local-set-key (kbd "M-]") 'helm-gtags-find-tag)
             (local-set-key (kbd "M-[") 'helm-gtags-find-rtag)
             (local-set-key (kbd "M-.") 'helm-gtags-dwim)
             (local-set-key (kbd "M-,") 'helm-gtags-tags-in-this-function)
             (local-set-key (kbd "C-j") 'helm-gtags-select)
             (local-set-key (kbd "M-g M-p") 'helm-gtags-parse-file)))

;; minimap.el
(when (display-graphic-p)
  (require 'minimap)
                                        ; enable minimap
  (global-set-key (kbd "C-c m") 'minimap-toggle))

;; highlight at point
(require 'highlight-symbol)
(global-set-key [f3] 'highlight-symbol-at-point)
(global-set-key [f4] 'highlight-symbol-next) 
(global-set-key [f2] 'highlight-symbol-prev) 

;;; function-args define-keys
(require 'function-args)
(fa-config-default)
(define-key c-mode-map [(control tab)] 'moo-complete)
(define-key c++-mode-map [(control tab)] 'moo-complete)
(define-key c-mode-map (kbd "M-o") 'fa-show)
(define-key c++-mode-map (kbd "M-o") 'fa-show)

;;; magit mode
(global-set-key (kbd "C-x s") 'magit-status) ;
(global-set-key (kbd "C-x l") 'magit-log)

(require 'yasnippet)
(yas-global-mode 1)
(provide 'knuth-global-keybindings)
;; end knuth-global-keybindings
