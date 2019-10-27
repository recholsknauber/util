(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (zenburn)))
 '(custom-safe-themes
   (quote
    ("cdb4ffdecc682978da78700a461cdc77456c3a6df1c1803ae2dd55c59fa703e3" "d91ef4e714f05fff2070da7ca452980999f5361209e679ee988e3c432df24347" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" default)))
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (zenburn-theme solarized-theme magit js-comint xref-js2 js2-refactor js2-mode))))
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
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;; THEME
(require 'zenburn-theme)
(load-theme 'zenburn t)


;; Bringing Magit
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)
(global-set-key (kbd "C-x g") 'magit-status)


;;; From js-comint.el:

(require 'js)
(require 'comint)
(require 'ansi-color)

(defgroup js-comint nil
  "Run a javascript process in a buffer."
  :group 'js-comint)

(defcustom js-comint-program-command "node"
  "JavaScript interpreter."
  :group 'js-comint)

(defvar js-comint-module-paths '()
  "List of modules paths which could be used by NodeJS to search modules.")

(defvar js-comint-drop-regexp
  "\\(\x1b\\[[0-9]+[GJK]\\|^[ \t]*undefined[\r\n]+\\)"
  "Regex to silence matching output.")

(defcustom js-comint-program-arguments '()
  "List of command line arguments passed to the JavaScript interpreter."
  :group 'js-comint)

(defcustom js-comint-prompt "> "
  "Prompt used in `js-comint-mode'."
  :group 'js-comint
  :type 'string)

(defcustom js-comint-mode-hook nil
  "*Hook for customizing js-comint mode."
  :type 'hook
  :group 'js-comint)

(defcustom js-use-nvm nil
  "When t, use NVM.  Requires nvm.el."
  :type 'boolean
  :group 'js-comint)

(defvar js-comint-buffer "Javascript REPL"
  "Name of the inferior JavaScript buffer.")

;; process.stdout.columns should be set.
;; but process.stdout.columns in Emacs is infinity because Emacs returns 0 as winsize.ws_col.
;; The completion candidates won't be displayed if process.stdout.columns is infinity.
;; see also `handleGroup` function in readline.js
(defvar js-comint-code-format
  (concat
   "process.stdout.columns = %d;"
   "require('repl').start('%s', null, null, true, false, "
   "require('repl')['REPL_MODE_' + '%s'.toUpperCase()])"))

(defvar js-nvm-current-version nil
  "Current version of node.")

(defun js-comint-list-nvm-versions (prompt)
  "List all available node versions from nvm prompting the user with PROMPT.
Return a string representing the node version."
  (let ((candidates (sort (mapcar 'car (nvm--installed-versions)) 'string<)))
    (completing-read prompt
                     candidates nil t nil
                     nil
                     (car candidates))))

;;;###autoload
(defun js-do-use-nvm ()
  "Enable nvm."
  (setq js-use-nvm t))

;;;###autoload
(defun js-comint-select-node-version (&optional version)
  "Use a given VERSION of node from nvm."
  (interactive)
  (if version
      (setq js-nvm-current-version (nvm--find-exact-version-for version))
    (let ((old-js-nvm js-nvm-current-version))
      (setq js-nvm-current-version
            (nvm--find-exact-version-for
             (js-comint-list-nvm-versions
              (if old-js-nvm
                  (format "Node version (current %s): " (car old-js-nvm))
                "Node version: "))))))
  (progn
    (setq js-comint-program-command
          (concat
           (car (last js-nvm-current-version))
           "/bin"
           "/node"))))

(defun js-comint-guess-load-file-cmd (filename)
  "Create Node file loading command for FILENAME."
  (concat "require(\"" filename "\")\n"))

(defun js-comint-quit-or-cancel ()
  "Send ^C to Javascript REPL."
  (interactive)
  (process-send-string (js-comint-get-process) "\x03"))

(defun js-comint--path-sep ()
  "Separator of file path."
  (if (eq system-type 'windows-nt) ";" ":"))

(defun js-comint--suggest-module-path ()
  "Find node_modules."
  (let* ((dir (locate-dominating-file default-directory
                                      "node_modules")))
    (if dir (concat (file-name-as-directory dir)
                    "node_modules")
      default-directory)))

(defun js-comint-get-process ()
  "Get repl process."
  (and js-comint-buffer
       (get-process js-comint-buffer)))

;;;###autoload
(defun js-comint-add-module-path ()
  "Add a directory to `js-comint-module-paths'."
  (interactive)
  (let* ((dir (read-directory-name "Module path:"
                                   (js-comint--suggest-module-path))))
    (when dir
      (add-to-list 'js-comint-module-paths (file-truename dir))
      (message "\"%s\" added to `js-comint-module-paths'" dir))))

;;;###autoload
(defun js-comint-delete-module-path ()
  "Delete a directory from `js-comint-module-paths'."
  (interactive)
  (cond
   ((not js-comint-module-paths)
    (message "`js-comint-module-paths' is empty."))
   (t
    (let* ((dir (ido-completing-read "Directory to delete: "
                                     js-comint-module-paths)))
      (when dir
        (setq js-comint-module-paths
              (delete dir js-comint-module-paths))
        (message "\"%s\" delete from `js-comint-module-paths'" dir))))))

;;;###autoload
(defun js-comint-save-setup ()
  "Save current setup to \".dir-locals.el\"."
  (interactive)
  (let* (sexp
         (root (read-directory-name "Where to create .dir-locals.el: "
                                    default-directory))
         (file (concat (file-name-as-directory root)
                       ".dir-locals.el")))
    (cond
     (js-comint-module-paths
      (setq sexp (list (list nil (cons 'js-comint-module-paths js-comint-module-paths))))
      (with-temp-buffer
        (insert (format "%S" sexp))
        (write-file file)
        (message "%s created." file)))
     (t
      (message "Nothing to save. `js-comint-module-paths' is empty.")))))

(defun js-comint-setup-module-paths ()
  "Setup node_modules path."
  (let* ((paths (mapconcat 'identity
                           js-comint-module-paths
                           (js-comint--path-sep)))
         (node-path (getenv "NODE_PATH")))
    (cond
     ((or (not node-path)
          (string= "" node-path))
      ;; set
      (setenv "NODE_PATH" paths))
     ((not (string= "" paths))
      ;; append
      (setenv "NODE_PATH" (concat node-path (js-comint--path-sep) paths))
      (message "%s added into \$NODE_PATH" paths)))))

;;;###autoload
(defun js-comint-reset-repl ()
  "Kill existing REPL process if possible.
Create a new Javascript REPL process.
The environment variable `NODE_PATH' is setup by `js-comint-module-paths'
before the process starts."
  (interactive)
  (when (js-comint-get-process)
    (process-send-string (js-comint-get-process) ".exit\n")
    ;; wait the process to be killed
    (sit-for 1))
  (js-comint-start-or-switch-to-repl))

(defun js-comint-filter-output (string)
  "Filter extra escape sequences from STRING."
  (let ((beg (or comint-last-output-start
                 (point-min-marker)))
        (end (process-mark (get-buffer-process (current-buffer)))))
    (save-excursion
      (goto-char beg)
      ;; Remove ansi escape sequences used in readline.js
      (while (re-search-forward js-comint-drop-regexp end t)
        (replace-match "")))))

(defun js-comint-get-buffer-name ()
  "Get repl buffer name."
  (format "*%s*" js-comint-buffer))

(defun js-comint-get-buffer ()
  "Get rpl buffer."
  (and js-comint-buffer
       (get-buffer (js-comint-get-buffer-name))))

;;;###autoload
(defun js-comint-clear ()
  "Clear the Javascript REPL."
  (interactive)
  (let* ((buf (js-comint-get-buffer) )
         (old-buf (current-buffer)))
    (save-excursion
      (cond
       ((buffer-live-p buf)
        (switch-to-buffer buf)
        (erase-buffer)
        (switch-to-buffer old-buf)
        (message "Javascript REPL cleared."))
       (t
        (error "Javascript REPL buffer doesn't exist!"))))))
(defalias 'js-clear 'js-comint-clear)


;;;###autoload
(defun js-comint-start-or-switch-to-repl ()
  "Start a new repl or switch to existing repl."
  (interactive)
  (setenv "NODE_NO_READLINE" "1")
  (js-comint-setup-module-paths)
  (let* ((repl-mode (or (getenv "NODE_REPL_MODE") "magic"))
         (js-comint-code (format js-comint-code-format
                                 (window-width) js-comint-prompt repl-mode)))
    (pop-to-buffer
     (apply 'make-comint js-comint-buffer js-comint-program-command nil
            `(,@js-comint-program-arguments "-e" ,js-comint-code)))
    (js-comint-mode)))

;;;###autoload
(defun js-comint-repl (cmd)
  "Start a Javascript process by running CMD.
The environment variable \"NODE_PATH\" is setup by `js-comint-module-paths'."
  (interactive
   (list
    ;; You can select node version here
    (when current-prefix-arg
      (setq cmd
            (read-string "Run js: "
                         (format "%s %s"
                                 js-comint-program-command
                                 js-comint-program-arguments)))
      (when js-use-nvm
        (unless (featurep 'nvm)
          (require 'nvm))
        (unless js-nvm-current-version
          (js-comint-select-node-version)))
      (setq js-comint-program-arguments (split-string cmd))
      (setq js-comint-program-command (pop js-comint-program-arguments)))))
  (js-comint-start-or-switch-to-repl))
(defalias 'run-js 'js-comint-repl)

(defun js-comint-send-string (str)
  "Send STR to repl."
  (comint-send-string (js-comint-get-process)
                      (concat str "\n")))

;;;###autoload
(defun js-comint-send-region ()
  "Send the current region to the inferior Javascript process.
If no region selected, you could manually input javascript expression."
  (interactive)
  (let* ((str (if (region-active-p)
                  (buffer-substring-no-properties (region-beginning) (region-end))
                (read-string "input js expression: "))))
    (message "str=%s" str)
    (js-comint-send-string str)))

;;;###autoload
(defalias 'js-send-region 'js-comint-send-region)

;;;###autoload
(defun js-comint-send-last-sexp ()
  "Send the previous sexp to the inferior Javascript process."
  (interactive)
  (let* ((b (save-excursion
              (backward-sexp)
              (move-beginning-of-line nil)
              (point)))
         (e (if (and (boundp 'evil-mode)
                     evil-mode
                     (eq evil-state 'normal))
                (+ 1 (point))
              (point)))
         (str (buffer-substring-no-properties b e)))
    (js-comint-send-string str)))

;;;###autoload
(defalias 'js-send-last-sexp 'js-comint-send-last-sexp)

;;;###autoload
(defun js-comint-send-buffer ()
  "Send the buffer to the inferior Javascript process."
  (interactive)
  (js-comint-send-string
   (buffer-substring-no-properties (point-min)
                                   (point-max))))

;;;###autoload
(defalias 'js-send-buffer 'js-comint-send-buffer)

;;;###autoload
(defun js-comint-load-file (file)
  "Load FILE into the javascript interpreter."
  (interactive "f")
  (let ((file (expand-file-name file)))
    (js-comint-repl js-comint-program-command)
    (comint-send-string (js-comint-get-process) (js-comint-guess-load-file-cmd file))))

;;;###autoload
(defalias 'js-load-file 'js-comint-load-file)

(defalias 'switch-to-js 'js-comint-start-or-switch-to-repl)

(defvar js-comint-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'js-comint-quit-or-cancel)
    map))


;;;###autoload
(define-derived-mode js-comint-mode comint-mode "Javascript REPL"
  :group 'js-comint
  :syntax-table js-mode-syntax-table
  (setq-local font-lock-defaults (list js--font-lock-keywords))
  ;; No echo
  (setq comint-process-echoes t)
  ;; Ignore duplicates
  (setq comint-input-ignoredups t)
  (add-hook 'comint-output-filter-functions 'js-comint-filter-output nil t)
  (process-put (js-comint-get-process)
               'adjust-window-size-function (lambda (_process _windows) ()))
  (use-local-map js-comint-mode-map)
  (ansi-color-for-comint-mode-on))

(provide 'js-comint)
;;; js-comint.el ends here
