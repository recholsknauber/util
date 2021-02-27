


;; Adding MELPA

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "org" (concat proto "://orgmode.org/elpa/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;;Cursor
(setq-default cursor-type 'box)
(set-cursor-color "#00ff00")

;; Set Default Directory on Windows
(setq default-directory "/home/")

;; Set C Source Directory
(setq source-directory "/home/.emacs.d/emacs-27.1")

;; Backup files to one folder
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

;; Ditching UI
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; Setting Font size
(set-face-attribute 'default nil :height 98)

;;; Flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;;; Helm
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(helm-mode 1)

;;; Helpful ;;;
;; Note that the built-in `describe-function' includes both functions
;; and macros. `helpful-function' is functions only, so we provide
;; `helpful-callable' as a drop-in replacement.
(global-set-key (kbd "C-h f") #'helpful-callable)

(global-set-key (kbd "C-h v") #'helpful-variable)
(global-set-key (kbd "C-h k") #'helpful-key)

;; Lookup the current symbol at point. C-c C-d is a common keybinding
;; for this in lisp modes.
(global-set-key (kbd "C-c C-d") #'helpful-at-point)

;; Look up *F*unctions (excludes macros).
;;
;; By default, C-h F is bound to `Info-goto-emacs-command-node'. Helpful
;; already links to the manual, if a function is referenced there.
(global-set-key (kbd "C-h F") #'helpful-function)

;; Look up *C*ommands.
;;
;; By default, C-h C is bound to describe `describe-coding-system'. I
;; don't find this very useful, but it's frequently useful to only
;; look at interactive functions.
(global-set-key (kbd "C-h C") #'helpful-command)

;; Add Elisp demos
(advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update)



;;; Projectile
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)



;;;;;     EMACS Lisp     ;;;;;
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)
(add-hook 'php-mode-hook              #'enable-paredit-mode)
(add-hook 'js-mode-hook               #'enable-paredit-mode)
(add-hook 'clojure-mode-hook          #'enable-paredit-mode)

;;; Rainbow Delimiters
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(show-paren-mode 1)

;; EMMS
;; (require 'emms-setup)
;; (emms-all)
;; (emms-default-players)
;; (setq emms-source-file-default-directory "c:/Users/ryank/Music/")

;; Company Mode for autocomplete
(use-package company
	     :ensure t
	     :config
	     (progn
	       (add-hook 'after-init-hook 'global-company-mode)))


;;; Dired Sidebar
(use-package dired-sidebar
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)

  (setq dired-sidebar-subtree-line-prefix "__")
  (setq dired-sidebar-theme 'nerd)
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-custom-font t))


;;;;;     ORG     ;;;;;

;; Agenda View
(setq org-startup-folded t)
(setq org-startup-indented '"indent")
(setq org-agenda-files '("~/kar/"))

(defun air-org-skip-subtree-if-priority (priority)
    "Skip an agenda subtree if it has a priority of PRIORITY.

PRIORITY may be one of the characters ?A, ?B, or ?C."
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
	  (pri-value (* 1000 (- org-lowest-priority priority)))
	  (pri-current (org-get-priority (thing-at-point 'line t))))
      (if (= pri-value pri-current)
	  subtree-end
	      nil)))

(defun air-org-skip-subtree-if-habit ()
  "Skip an agenda entry if it has a STYLE property equal to \"habit\"."
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (string= (org-entry-get nil "STYLE") "habit")
	subtree-end
            nil)))

(setq org-agenda-custom-commands
      '(("c" "Simple agenda view"
	 ((tags "PRIORITY=\"A\""
		((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
		 (org-agenda-overriding-header "High-priority unfinished tasks:")))
	 (agenda "")
	 (alltodo ""
		  ((org-agenda-skip-function
		    '(or (air-org-skip-subtree-if-priority ?A)
			 (air-org-skip-subtree-if-habit)
	                 (org-agenda-skip-if nil '(scheduled deadline)))))))
		  )))

;; Refiling
(setq org-refile-targets '(("~/kar/ka.org" :maxlevel . 2)
			   ("~/kar/zdone.org" :maxlevel . 2)
			   ("~/kar/zsomeday.org" :maxlevel . 3)))

(setq org-archive-location '"~/kar/zdone.org::datetree/* Finished Tasks")

;; Speed Keys
(setq org-use-speed-commands t)

;; Priorities
(setq org-default-priority ?D)


;;; SRC code blocks ;;;

;; Setting src code edit window
(setq org-src-window-setup 'current-window)
;; Fontify code blocks ;;
(setq org-src-fontify-natively t)
;; Templates
(require 'org-tempo)
;; Org Languages
(require 'org)
(require 'ob-python)
(require 'ob-emacs-lisp)
;; Cider code block processing
(require 'ob-clojure)
(setq org-babel-clojure-backend 'cider)



;;; SQL
(setq sql-ms-options (quote ("-W" "-s" "|" "-I"))
      sql-ms-program "sqlcmd")
;; Alex Schroeder--"Here is how to force Emacs to use code page 850 for every sqlcmd process and to force DOS line endings."
(add-to-list 'process-coding-system-alist '("sqlcmd" . cp850-dos))

;;; EJC SQL
(require 'ejc-sql)

(require 'ejc-autocomplete)
(add-hook 'ejc-sql-minor-mode-hook
          (lambda ()
            (auto-complete-mode t)
            (ejc-ac-setup)))
(add-hook 'ejc-sql-connected-hook
          (lambda ()
            (ejc-set-max-rows nil)
	    (ejc-set-fetch-size 500)
            (ejc-set-column-width-limit 30)
            (ejc-set-show-too-many-rows-message t)
            (ejc-set-use-unicode nil)))


;;; JavaScript
(require 'js-comint)
(add-hook 'js-mode-hook 'js2-minor-mode)


;;; PHP
;;;;; web-mode
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\.twig\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(defun my-php-mode-setup ()
  "My PHP-mode hook."
  (require 'flycheck-phpstan)
  (flycheck-mode t))

(add-hook 'php-mode-hook 'my-php-mode-setup)


;;; Clojure + Cider
(require 'cider)

;; Do not inject deps
;;(setq cider-inject-dependencies-at-jack-in nil)
;; Enable offline
;;(setq cider-lein-global-options "-o")
;; Set build to shadow-cljs
;;(setq cider-default-cljs-repl 'shadow)


;; Beacon cursor ;;
(beacon-mode 1)

;;;;;     SET KEYS     ;;;;;;

;;; Global
;; (global-set-key (kbd "M-x butterfly") ')
(global-set-key (kbd "C-c C--") 'shrink-window)
(global-set-key (kbd "C-c C-=") 'enlarge-window)
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(dolist (hook '(clojure-mode-hook cider-mode-hook))
  (add-hook hook
  (lambda ()
   (local-set-key (kbd "C-c r") 'cider-eval-region))))

(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c r") 'eval-region)))


(global-set-key (kbd "C-c C-d") #'helpful-at-point)
(global-set-key (kbd "C-c d") 'cider-debug-defun-at-point)
(global-set-key (kbd "C-c x") 'company-complete)
(global-set-key (kbd "C-c v") 'visual-line-mode)
(global-set-key (kbd "C-x g") 'magit-status)

;;;;; LANGUAGE ENVIRONMENT FOR JAPANESE/CHINESE ;;;;;
(set-language-environment "UTF-8")

;; toggle-window-split function
(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
	     (next-win-buffer (window-buffer (next-window)))
	     (this-win-edges (window-edges (selected-window)))
	     (next-win-edges (window-edges (next-window)))
	     (this-win-2nd (not (and (<= (car this-win-edges)
					 (car next-win-edges))
				     (<= (cadr this-win-edges)
					 (cadr next-win-edges)))))
	     (splitter
	      (if (= (car this-win-edges)
		     (car (window-edges (next-window))))
		  'split-window-horizontally
		'split-window-vertically)))
	(delete-other-windows)
	(let ((first-win (selected-window)))
	  (funcall splitter)
	  (if this-win-2nd (other-window 1))
	  (set-window-buffer (selected-window) this-win-buffer)
	  (set-window-buffer (next-window) next-win-buffer)
	  (select-window first-win)
	  (if this-win-2nd (other-window 1))))))
(global-set-key (kbd "C-c C-\\") 'toggle-window-split)

;;;;; MACROS ;;;;;
(fset 'kar-start
      (kmacro-lambda-form [?\M-x ?f ?i ?n ?d ?- ?f ?i ?l ?e return ?~ ?/ ?k ?a ?r ?. ?k ?a backspace backspace backspace ?/ ?k ?a ?. ?o ?r ?g return ?\M-x ?h ?e ?l ?m ?- ?m ?o ?d ?e return ?\C-c ?\\ ?P ?R ?I ?O ?R ?I ?T ?Y ?= ?\" ?A ?\" return ?\M-x ?v ?i ?s ?u tab return ?\C-x ?3 ?\C-x ?o ?\M-x ?f ?i ?n ?d ?- ?f ?i ?l ?e return ?j ?o ?u ?r ?n ?a ?l ?. ?o ?r ?g return S-tab S-tab S-tab ?\M-x ?v ?i ?s ?u tab return ?\C-x ?2 ?\C-x ?o ?\M-x ?f ?i ?n ?d ?- ?f ?i ?l ?e return ?s ?l ?u ?s ?h ?. ?r backspace ?o ?r ?g return tab ?n tab tab ?\M-x ?v ?i ?s ?u tab return ?\C-x ?o ?\M-x ?h ?e ?l ?m ?- ?m ?o ?d ?e return] 0 "%d"))
(global-set-key "\C-x\C-k\C-s" 'kar-start)

(fset 'rk-double-down
      (kmacro-lambda-form [?\C-n ?\C-n] 0 "%d"))
(global-set-key "\M-n" 'rk-double-down)

(fset 'rk-double-up
   (kmacro-lambda-form [?\C-p ?\C-p] 0 "%d"))
(global-set-key "\M-p" 'rk-double-up)

(fset 'rklwnw-start
   (kmacro-lambda-form [?\M-x ?h ?e ?l ?m ?- ?m ?o ?d ?e return ?\C-c ?\\ ?P ?R ?I ?O ?R ?I ?T ?Y ?= ?\" ?A ?\" return ?\C-x ?3 ?\C-x ?o ?\M-x ?i ?n backspace backspace ?f ?i ?n ?d ?- ?f ?i ?l ?e return ?n ?o ?t ?e ?s ?. ?o ?r ?g return S-tab S-tab S-tab ?\C-c ?v ?\C-x ?o ?\C-c ?v ?\M-x ?h ?e ?l ?m ?- ?m ?o ?d ?e return] 0 "%d"))
(global-set-key "\C-x\C-k\C-l" 'rklwnw-start)