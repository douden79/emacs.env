;;; knuth-packages.el --- Emacs knuth : default package selection.
;;
;;; Code:

(require 'cl)
(require 'package)

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
;; set package-user-dir to be relative to Knuth install path
(setq package-user-dir (expand-file-name "elpa" knuth-dir))
(package-initialize)

(defvar knuth-packages
  '(ace-jump-mode
    ace-jump-buffer
    ace-window
    anzu
    ecb
    cedet
    browse-kill-ring
    dash
    discover-my-major
    diff-hl
    diminish
    easy-kill
    elisp-slime-nav
    epl
    expand-region
    flycheck
    gist
    git-timemachine
    gitconfig-mode
    gitignore-mode
    god-mode
    grizzl
    guru-mode
    ov
    projectile
    magit
    move-text
    operate-on-number
    rainbow-mode
    smartparens
    smartrep
    undo-tree
    volatile-highlights
    highlight-symbol
    zenburn-theme
    auto-complete
    flymake-python-pyflakes
    flymake-cursor
    flymake
    ggtags
    helm-gtags
    metaweblog
    org2blog
    xml-rpc
    multiple-cursors
    mark-multiple
    markdown-mode
    minimap
    function-args
    smex
    ac-helm
    elpy 
    jedi 
    nlinum 
    yasnippet
    monokai-theme
    c-eldoc )
  "A list of packages to ensure are installed at launch.")

;;; requirement elpy packages.
;; sudo apt-get install pip
(defun knuth-packages-installed-p ()
  "Check if all packages in `knuth-packages' are installed."
  (every #'package-installed-p knuth-packages))

(defun knuth-require-package (package)
  "Install PACKAGE unless already installed."
  (unless (memq package knuth-packages)
    (add-to-list 'knuth-packages package))
  (unless (package-installed-p package)
    (package-install package)))

(defun knuth-require-packages (packages)
  "Ensure PACKAGES are installed.
Missing packages are installed automatically."
  (mapc #'knuth-require-package packages))

(define-obsolete-function-alias 'knuth-ensure-module-deps 'knuth-require-packages)

(defun knuth-install-packages ()
  "Install all packages listed in `knuth-packages'."
  (unless (knuth-packages-installed-p)
    ;; check for new packages (package versions)
    (message "%s" "Emacs Knuth is now refreshing its package database...")
    (package-refresh-contents)
    (message "%s" " done.")
    ;; install the missing packages
    (knuth-require-packages knuth-packages)))

;; run package installation
(knuth-install-packages)

(defun knuth-list-foreign-packages ()
  "Browse third-party packages not bundled with Knuth.

Behaves similarly to `package-list-packages', but shows only the packages that
are installed and are not in `knuth-packages'.  Useful for
removing unwanted packages."
  (interactive)
  (package-show-package-list
   (set-difference package-activated-list knuth-packages)))

(defmacro knuth-auto-install (extension package mode)
  "When file with EXTENSION is opened triggers auto-install of PACKAGE.
PACKAGE is installed only if not already present.  The file is opened in MODE."
  `(add-to-list 'auto-mode-alist
                `(,extension . (lambda ()
                                 (unless (package-installed-p ',package)
                                   (package-install ',package))
                                 (,mode)))))

(defvar knuth-auto-install-alist
  '(("\\.clj\\'" clojure-mode clojure-mode)
    ("\\.coffee\\'" coffee-mode coffee-mode)
    ("\\.css\\'" css-mode css-mode)
    ("\\.csv\\'" csv-mode csv-mode)
    ("\\.d\\'" d-mode d-mode)
    ("\\.dart\\'" dart-mode dart-mode)
    ("\\.ex\\'" elixir-mode elixir-mode)
    ("\\.exs\\'" elixir-mode elixir-mode)
    ("\\.elixir\\'" elixir-mode elixir-mode)
    ("\\.erl\\'" erlang erlang-mode)
    ("\\.feature\\'" feature-mode feature-mode)
    ("\\.go\\'" go-mode go-mode)
    ("\\.groovy\\'" groovy-mode groovy-mode)
    ("\\.haml\\'" haml-mode haml-mode)
    ("\\.hs\\'" haskell-mode haskell-mode)
    ("\\.kv\\'" kivy-mode kivy-mode)
    ("\\.latex\\'" auctex LaTeX-mode)
    ("\\.less\\'" less-css-mode less-css-mode)
    ("\\.lua\\'" lua-mode lua-mode)
    ("\\.markdown\\'" markdown-mode markdown-mode)
    ("\\.md\\'" markdown-mode markdown-mode)
    ("\\.ml\\'" tuareg tuareg-mode)
    ("\\.pp\\'" puppet-mode puppet-mode)
    ("\\.php\\'" php-mode php-mode)
    ("PKGBUILD\\'" pkgbuild-mode pkgbuild-mode)
    ("\\.rs\\'" rust-mode rust-mode)
    ("\\.sass\\'" sass-mode sass-mode)
    ("\\.scala\\'" scala-mode2 scala-mode)
    ("\\.scss\\'" scss-mode scss-mode)
    ("\\.slim\\'" slim-mode slim-mode)
    ("\\.swift\\'" swift-mode swift-mode)
    ("\\.textile\\'" textile-mode textile-mode)
    ("\\.thrift\\'" thrift thrift-mode)
    ("\\.yml\\'" yaml-mode yaml-mode)
    ("\\.yaml\\'" yaml-mode yaml-mode)
    ("Dockerfile\\'" dockerfile-mode dockerfile-mode)))

;; markdown-mode doesn't have autoloads for the auto-mode-alist
;; so we add them manually if it's already installed
(when (package-installed-p 'markdown-mode)
  (add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
  (add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode)))

(when (package-installed-p 'pkgbuild-mode)
  (add-to-list 'auto-mode-alist '("PKGBUILD\\'" . pkgbuild-mode)))

;; build auto-install mappings
(mapc
 (lambda (entry)
   (let ((extension (car entry))
         (package (cadr entry))
         (mode (cadr (cdr entry))))
     (unless (package-installed-p package)
       (knuth-auto-install extension package mode))))
 knuth-auto-install-alist)

(provide 'knuth-packages)
;; Local Variables:
;; byte-compile-warnings: (not cl-functions)
;; End:

;;; knuth-packages.el ends here
