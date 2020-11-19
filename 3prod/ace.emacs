(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(zenburn))
 '(custom-safe-themes
   '("f2c35f8562f6a1e5b3f4c543d5ff8f24100fae1da29aeb1864bbc17758f52b70" default))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   '(powershell org dired-sidebar company zenburn-theme use-package magit cider beacon)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Adding MELPA
;; https://emacs.cafe/emacs/javascript/setup/2017/04/23/emacs-setup-javascript.html

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

;; Set Default Directory on Windows
(setq default-directory "/home/")

;; Backup files to one folder
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

;; Ditching UI
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; Setting Font size
(set-face-attribute 'default nil :height 110)

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


;;; Clojure + Cider
(require 'cider)

;; Do not inject deps
(setq cider-inject-dependencies-at-jack-in nil)
;; Enable offline
;;(setq cider-lein-global-options "-o")
;; Set build to shadow-cljs
;;(setq cider-default-cljs-repl 'shadow)


;; Beacon cursor ;;
(beacon-mode 1)

;;;;;     SET KEYS     ;;;;;;

;;; Global
;; (global-set-key (kbd "M-x butterfly") ')
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(global-set-key (kbd "C-c r") 'cider-eval-region)
(global-set-key (kbd "C-c d") 'cider-debug-defun-at-point)
(global-set-key (kbd "C-c x") 'company-complete)
(global-set-key (kbd "C-x g") 'magit-status)

;;;;; LANGUAGE ENVIRONMENT FOR JAPANESE/CHINESE ;;;;;
(set-language-environment "UTF-8")
