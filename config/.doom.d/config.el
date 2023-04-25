;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Cica" :size 30)
      doom-unicode-font (font-spec :family "Cica" :size 30))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-nord)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Dropbox/memo/org/")
(setq org-roam-directory "~/Dropbox/memo/org/roam")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; OS判定
(defun macp ()
  (eq system-type 'darwin))
(defun linuxp ()
  (eq system-type 'gnu/linux))
(defun bsdp ()
  (eq system-type 'gnu/kfreebsd))
(defun winp ()
  (eq system-type 'windows-nt))
(defun wslp ()
  (and (eq system-type 'gnu/linux)
       (file-exists-p "/proc/sys/fs/binfmt_misc/WSLInterop")))

;; Ctrl-h
(map! "C-h" 'delete-backward-char)

;; delete character without yanking
(map! :n "x" 'delete-char)

;; leader key
(add-hook! 'org-mode-hook #'+org-init-keybinds-h)
(setq evil-snipe-override-evil-repeat-keys nil)
(setq doom-localleader-key ",")
(setq doom-localleader-alt-key "M-,")

;; auto save
(use-package! super-save
  :config
  (setq super-save-auto-save-when-idle t
        super-save-idle-duration 2)
  (super-save-mode +1)
  )

;; Disable exit confirmation.
(setq confirm-kill-emacs nil)

;; org-mode の日付を英語にする
(setq system-time-locale "C")

(after! org
  (map!
    "C-c a" #'org-agenda
    "C-c c" #'org-capture
    )
  (setq org-todo-keywords
    (quote ((sequence "TODO(t)" "|" "DONE(d)")
             (sequence "WAITING(w/!)" "|" "CANCELLED(c/!)"))))
  (setq org-capture-templates
    '(
       ("t" "Task" entry (file+headline "~/Dropbox/memo/org/gtd.org" "Inbox")
         "* TODO %? \nCREATED: %U\n %i")
       ("T" "Task from protocol" entry (file+headline "~/Dropbox/memo/org/gtd.org" "Inbox")
         "* TODO %? [[%:link][%:description]] \nCREATED: %U\n%i\n\n")
       ("L" "ReadItLater" entry (file+headline "~/Dropbox/memo/org/gtd.org" "ReadItLater")
         "* TODO %? [[%:link][%:description]] \nCREATED: %U\n%i\n")
       ("m" "Memo" entry (file+headline org-default-notes-file "Memo")
         "* %? %U %i")
       ("M" "Memo from protocol" entry (file+headline org-default-notes-file "Memo")
         "* %? [[%:link][%:description]] \nCaptured On: %U\n%i\n")
       ("R" "Review entry" entry (file+datetree "~/Dropbox/memo/org/review.org") (file "~/Dropbox/memo/org/template-review.org"))
       ))
  )
(after! evil-org
  (remove-hook 'org-tab-first-hook #'+org-cycle-only-current-subtree-h)
  )
(after! org-roam
  (map!
    "C-c n l" #'org-roam-buffer-toggle
    "C-c n f" #'org-roam-node-find
    "C-c n i" #'org-roam-node-insert
    "C-c j" #'org-roam-dailies-capture-today
    "C-c n d" #'org-roam-dailies-goto-today
    :map org-mode-map
    "C-M-i" #'completion-at-point
    )
  (setq org-roam-capture-templates
    '(
       ("d" "default" plain
         "%?"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n"))
       ("l" "programming language" plain
         "* Characteristics\n\n- Family: %?\n- Inspired by: \n\n* Reference:\n\n"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n"))
       ("b" "book notes" plain
         "\n* Source\n\nAuthor: %^{Author}\nTitle: ${title}\nYear: %^{Year}\n\n* Summary\n\n%?"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n"))
       ("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+filetags: Project"))
       )
    )
  (setq org-roam-dailies-capture-templates
    '(("d" "default" entry "* %<%H:%M> %?"
        :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))
       )
    )
  )

(map! :after evil-org
      :map evil-org-mode-map
      :ni "C-<return>" #'org-insert-heading-respect-content
      :ni "C-S-<return>" #'org-insert-todo-heading-respect-content
      )
(defun get-basename-from-fullpath (fullpath)
  "フルパスから最後のスラッシュまで削除した部分を返します。"
  (let ((parts (split-string fullpath "/")))
    (car (last parts))))

(defun my-org-screenshot-win ()
  "Take a screenshot into a time stamped unique-named file in the
   same directory as the org-buffer and insert a link to this file."
  (interactive)
  (setq filename
        (concat (expand-file-name "~/Dropbox/memo/org/img/")
                (get-basename-from-fullpath
                 (concat
                  (make-temp-name
                   (concat (buffer-file-name)
                           "_"
                           (format-time-string "%Y%m%d_%H%M%S_")) ) ".png"))))
  (shell-command "snippingtool /clip")
  (shell-command (concat "powershell -command \"Add-Type -AssemblyName System.Windows.Forms;if ($([System.Windows.Forms.Clipboard]::ContainsImage())) {$image = [System.Windows.Forms.Clipboard]::GetImage();[System.Drawing.Bitmap]$image.Save('" filename "',[System.Drawing.Imaging.ImageFormat]::Png); Write-Output 'clipboard content saved as file'} else {Write-Output 'clipboard does not contain image data'}\""))
  (setq pastepath
        (concat "~/Dropbox/memo/org/img/" (get-basename-from-fullpath filename)))
  (insert (concat "[[" pastepath "]]"))
  (org-display-inline-images))

(defun my-org-screenshot-darwin ()
  "Save a clipboard's screenshot into a time stamped unique-named file
   in a specified directory and insert a link to this file."
  (interactive)
  (setq filename
        (concat
         (make-temp-name
          (concat (buffer-name)
                  "_"
                  (format-time-string "%Y%m%d_%H%M%S_")) ) ".png"))
  (call-process "pngpaste" nil nil nil (concat (expand-file-name "~/Dropbox/memo/org/img/") filename))
  (setq pastepath
        (concat "~/Dropbox/memo/org/img/" filename))
  (insert (concat "[[" pastepath "]]"))
  (org-display-inline-images))

(defun my-org-screenshot ()
  (interactive)
  (if (eq system-type 'darwin)
      (my-org-screenshot-darwin)
    (my-org-screenshot-win)
    )
  )

(global-set-key (kbd "C-^") 'my-org-screenshot)
