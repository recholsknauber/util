(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(custom-enabled-themes (quote (misterioso)))
 '(custom-safe-themes
   (quote
    ("ed648f9c55e06ef2bfc8ac5967a1d9086f31f7a8b2ed05229988cd26fa0f74a6" "d6c37a914c75fe47f552c9789170dc0879be13811dd70cc34ad983da30d7c1f7" "cdb4ffdecc682978da78700a461cdc77456c3a6df1c1803ae2dd55c59fa703e3" "d91ef4e714f05fff2070da7ca452980999f5361209e679ee988e3c432df24347" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" default)))
 '(fci-rule-color "#383838")
 '(inhibit-startup-screen t)
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(org-agenda-files (quote ("~/kar/blam.org")))
 '(package-selected-packages
   (quote
    (org pdf-tools cider-hydra dired-sidebar slime clojure-mode company-jedi irony all-the-icons company csv-mode solarized-theme magit js-comint xref-js2 js2-refactor js2-mode)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3"))
;; '(custom-enabled-themes (quote (zenburn)))
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

;; Bringing Magit
(global-set-key (kbd "C-x g") 'magit-status)



;; Company Mode for autocomplete
(use-package company
	     :ensure t
	     :config
	     (progn
	       (add-hook 'after-init-hook 'global-company-mode)))

;; Company Mode company-jedi for python
;; (use-package jedi-core
;;   :ensure t
;;   :config
;;   (setq python-environment-directory "~/.emacs.d/.python-environments")
(defun my/python-mode-hook ()
  (add-to-list 'company-backends 'company-jedi))
(add-hook 'python-mode-hook 'my/python-mode-hook)

;;;;;     ORG     ;;;;;

;; Agenda View
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

;;; SRC code blocks ;;;

;; Setting src code edit window
(setq org-src-window-setup 'current-window)
;; Templates
(require 'org-tempo)
;; Org Languages
(require 'org)
(require 'ob-python)
(require 'ob-clojure)
(require 'ob-emacs-lisp)

;; Clojure + Cider

;; Enable offline
;;(setq cider-lein-global-options "-o")

;;(add-to-list 'load-path "/full-path-to/org-mode/lisp")
(setq org-babel-clojure-backend 'cider)
(require 'cider)
;; Cider Hydra
;;(add-hook 'clojure-mode-hook #'cider-hydra-mode)

;; Fontify code blocks ;;
(setq org-src-fontify-natively t)

;; Priorities
(setq org-default-priority ?D)

;; Beacon cursor ;;
(beacon-mode 1)

;;;;;     SET KEYS     ;;;;;;

;;; Global
;; (global-set-key (kbd "M-x butterfly") ')
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(global-set-key (kbd "C-c r") 'cider-eval-region)
(global-set-key (kbd "C-c x") 'company-complete)
(global-set-key (kbd "C-x g") 'magit-status)

;;;;; LANGUAGE ENVIRONMENT FOR JAPANESE/CHINESE ;;;;;
(set-language-environment "UTF-8")
