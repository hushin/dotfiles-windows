;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

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

(setq doom-font (font-spec :family "Cica" :size (if (winp) 30 18))
  doom-variable-pitch-font (font-spec :family "Cica"))
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
(setq display-line-numbers-type nil)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Dropbox/memo/org/")
(setq org-roam-directory org-directory)
(setq org-roam-file-exclude-regexp "/archives/")

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



;; Ctrl-h
                                        ;(map! "C-h" 'delete-backward-char)

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
    super-save-idle-duration 1)
  (super-save-mode +1)
  )

;; Disable exit confirmation.
(setq confirm-kill-emacs nil)

;; org-mode の日付を英語にする
(setq system-time-locale "C")
;; UTF-8をデフォルトのエンコーディングとして設定
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; Windows 用のクリップボード設定
(when (winp)
  (set-selection-coding-system 'utf-16le-dos))
;; Windows search-project で 日本語で検索できるようにする
(when (winp)
  (defun advice:with-japanese-coding-system (orig-fun &rest args)
    (let ((coding-system-for-write 'cp932))
      (apply orig-fun args)))
  (advice-add '+default/search-project :around 'advice:with-japanese-coding-system))

;; Displaying week numbers in calendar
(copy-face font-lock-constant-face 'calendar-iso-week-face)
(set-face-attribute 'calendar-iso-week-face nil
  :height 0.8)
(setq calendar-intermonth-text
  '(propertize
     (format "w%2d"
       (car
         (calendar-iso-from-absolute
           (calendar-absolute-from-gregorian
             (list month (- day (1- calendar-week-start-day)) year)))))
     'font-lock-face 'calendar-iso-week-face))

;; ファイル移動
(defun move-buffer-file-to-directory ()
  "Move the current buffer file to a new directory, keeping the same file name."
  (interactive)
  (let* ((old-location (buffer-file-name))
         (file-name (file-name-nondirectory old-location))
         (new-dir (file-name-as-directory (expand-file-name (read-directory-name "Move to directory: ")))))
    (when (file-exists-p (concat new-dir file-name))
      (error "File '%s' already exists in directory '%s'!" file-name new-dir))
    (rename-file old-location (concat new-dir file-name) 1)
    (set-visited-file-name (concat new-dir file-name))
    (set-buffer-modified-p nil)
    (when (fboundp 'recentf-add-file)
      (recentf-add-file (concat new-dir file-name))
      (recentf-remove-if-non-kept old-location))
    (message "File moved from '%s' to '%s'" old-location (concat new-dir file-name))))
;; ファイル削除
(defun delete-file-and-buffer ()
  "Kill the current buffer and deletes the file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (if (vc-backend filename)
        (vc-delete-file filename)
        (progn
          (delete-file filename)
          (message "Deleted file %s" filename)
          (kill-buffer))))))
;; アーカイブフォルダへ移動
(defun org-roam-move-file-to-archives ()
  "Move the current org-roam file to the archives directory, maintaining the directory structure, and open the moved file in a buffer."
  (interactive)
  (let* ((file-path (buffer-file-name))
         (relative-path (file-relative-name file-path org-roam-directory))
         (archive-path (concat (file-name-as-directory org-roam-directory)
                               "archives/"
                               relative-path)))
    (when (and (org-roam-file-p)
               (not (string-prefix-p (concat (file-name-as-directory org-roam-directory)
                                             "archives/")
                                     file-path)))
      (mkdir (file-name-directory archive-path) t)
      (rename-file file-path archive-path)
      (set-visited-file-name archive-path)
      (set-buffer-modified-p nil)
      (when (fboundp 'recentf-add-file)
        (recentf-add-file archive-path)
        (recentf-remove-if-non-kept file-path))
      (message "File moved to archives: %s" archive-path))))

(defun org-roam-move-file-to-canceled-archives ()
  "Move the current org-roam file to the archives/canceled directory, maintaining the directory structure, and open the moved file in a buffer."
  (interactive)
  (let* ((file-path (buffer-file-name))
         (relative-path (file-relative-name file-path org-roam-directory))
         (archive-path (concat (file-name-as-directory org-roam-directory)
                               "archives/canceled/"
                               relative-path)))
    (when (and (org-roam-file-p)
               (not (string-prefix-p (concat (file-name-as-directory org-roam-directory)
                                             "archives/canceled/")
                                     file-path)))
      (mkdir (file-name-directory archive-path) t)
      (rename-file file-path archive-path)
      (set-visited-file-name archive-path)
      (set-buffer-modified-p nil)
      (when (fboundp 'recentf-add-file)
        (recentf-add-file archive-path)
        (recentf-remove-if-non-kept file-path))
      (message "File moved to archives: %s" archive-path))))
(map! :leader
  (:prefix "f"
    :desc "Move buffer file to directory" "m" #'move-buffer-file-to-directory)
  (:prefix "f"
    :desc "Delete file" "D" #'delete-file-and-buffer)
  (:prefix "f"
    :desc "archive file" "A" #'org-roam-move-file-to-archives)
  (:prefix "f"
    :desc "archive/cancel file" "Q" #'org-roam-move-file-to-canceled-archives)
  )

(after! org
  (map!
    "C-c a" #'org-agenda
    "C-c c" #'org-capture
    "C-c j" #'org-journal-new-entry
    )
  (setq org-todo-keywords
    (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
             (sequence "WAITING(w/!)" "|" "CANCELED(c/!)"))))
  (setq org-log-done 'time)
  ; 見出し入れるときは空行を入れない
  (setq org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))
  (defun my/property-values-function (property)
    "Return allowed values for PROPERTY."
    (cond
      ((string= property "Type")
        '("Book" "Web" "Anime" "Game" "Podcast" "Video" "Movie"))
      ((string= property "Rating")
        '("★★★★★" "★★★★" "★★★" "★★" "★"))
      ((string= property "Canceled")
        '("true" ""))
      ))

  (setq org-property-allowed-value-functions
    '(my/property-values-function))
  (defun cmp-date-property-stamp (prop)
    "Compare two `org-mode' agenda entries, `A' and `B', by some date property.
If a is before b, return -1. If a is after b, return 1. If they
are equal return nil."
    ;; source: https://emacs.stackexchange.com/questions/26351/custom-sorting-for-agenda/26369#26369
    (lambda (a b)
      (let* ((a-pos (get-text-property 0 'org-marker a))
              (b-pos (get-text-property 0 'org-marker b))
              (a-date (or (org-entry-get a-pos prop)
                        (format "<%s>" (org-read-date t nil "now"))))
              (b-date (or (org-entry-get b-pos prop)
                        (format "<%s>" (org-read-date t nil "now"))))
              (cmp (compare-strings a-date nil nil b-date nil nil)))
        (if (eq cmp t) nil (cl-signum cmp)))))

  ;; agenda
  (setq org-agenda-files
    (append
      (directory-files org-directory t "\\.org$")
      (directory-files-recursively (concat org-roam-directory "areas") "\\.org$")
      (directory-files-recursively (concat org-roam-directory "projects") "\\.org$")
      (directory-files-recursively (concat org-roam-directory "resources") "\\.org$")))

  ;; org-roam で作ったファイルの category 表示をいい感じにする
  ;; refs. https://d12frosted.io/posts/2020-06-24-task-management-with-roam-vol2.html
  (setq org-agenda-prefix-format
      '((agenda . " %i %(vulpea-agenda-category 18)%?-18t% s")
        (todo . " %i %(vulpea-agenda-category 18) ")
        (tags . " %i %(vulpea-agenda-category 18) ")
        (search . " %i %(vulpea-agenda-category 18) ")))
  (defun vulpea-agenda-category (&optional len)
    "Get category of item at point for agenda.

Category is defined by one of the following items:

- CATEGORY property
- TITLE keyword
- TITLE property
- filename without directory and extension

When LEN is a number, resulting string is padded right with
spaces and then truncated with ... on the right if result is
longer than LEN.

Usage example:

  (setq org-agenda-prefix-format
        '((agenda . \" %(vulpea-agenda-category) %?-12t %12s\")))

Refer to `org-agenda-prefix-format' for more information."
    (let* ((file-name (when buffer-file-name
                        (file-name-sans-extension
                          (file-name-nondirectory buffer-file-name))))
            (title (vulpea-buffer-prop-get "title"))
            (category (org-get-category))
            (result
              (or (if (and
                        title
                        (string-equal category file-name))
                    title
                    category)
                "")))
      (if (numberp len)
        (let* ((truncated (truncate-string-to-width result (- len 3) 0 ?\s "..."))
                (width (string-width truncated))
                (padded (concat truncated (make-string (- len width) ?\s))))
          padded)
        result)))
  (defun vulpea-buffer-prop-get (name)
    "Get a buffer property called NAME as a string."
    (org-with-point-at 1
      (when (re-search-forward (concat "^#\\+" name ": \\(.*\\)")
              (point-max) t)
        (buffer-substring-no-properties
          (match-beginning 1)
          (match-end 1)))))
  
  (setq
    ;; org-agenda-skip-scheduled-if-done t
    ;; org-agenda-skip-deadline-if-done t
    ;; org-agenda-include-deadlines t
    ;; org-agenda-block-separator nil
    ;; org-agenda-compact-blocks t
    ;; org-agenda-start-with-log-mode t
    org-agenda-start-day nil)

  (setq org-agenda-custom-commands
    '(
       ("r" "Resonance Cal" tags "Type={.}"
         ((org-agenda-files
            (directory-files-recursively
              (concat org-roam-directory "resources/rez") "\\.org$"))
           (org-overriding-columns-format
             "%35Item %Type %Start %Fin %Rating")
           (org-agenda-cmp-user-defined
             (cmp-date-property-stamp "Start"))
           (org-agenda-sorting-strategy
             '(user-defined-down))
           (org-agenda-overriding-header "C-u r to re-run Type={.}")
           (org-agenda-view-columns-initially t)
           )
         )
       ("d" "Done today"
         ((agenda ""
            (
              (org-agenda-span 'day)
              (org-agenda-log-mode-items '(closed clock))
              (org-agenda-show-log t)
              ;; (org-agenda-entry-types '(:closed :clock))
              (org-super-agenda-groups
                '(
                   (:name "Done today"
                     :and (:regexp "State \"DONE\""
                            :log t))
                   (:name "Clocked today"
                     :log t)
                   (:discard (:anything t))
                   ))
              )))
         )
       ("a" "Default agenda" 
         (
           (todo "NEXT" ((org-agenda-overriding-header "\nNEXT")))
           ;; TODO 会議など、今日の calendar 表示
           (agenda ""
            (
              (org-agenda-span 'day)
              (org-super-agenda-groups
                '(
                   (:name "Today"
                     :scheduled today
                     :deadline today)
                   (:name "Overdue"
                     :deadline past)
                   (:name "Reschedule"
                     :scheduled past)
                   ;; (:name "Due Soon"
                   ;;   :deadline future
                   ;;   :scheduled future                     ;; なぜか 将来の scheduled が表示されない
                   ;;   )
                   (:discard (:anything t))
                   ))))
           (agenda ""
             (
               (org-agenda-start-day "+1d")
               (org-agenda-span 12)
               (org-agenda-show-log nil)
               (org-agenda-clockreport-mode nil)))
           (tags (concat "w" (format-time-string "%V"))
             ((org-agenda-overriding-header  (concat "ToDos Week " (format-time-string "%V")))
               (org-super-agenda-groups
                 '((:discard (:deadline t))
                    (:discard (:scheduled t))
                    (:discard (:todo ("DONE")))
                    ))))
           (alltodo ""
             (
               (org-agenda-overriding-header "Tasks")
               (org-super-agenda-groups
                 '(
                    (:name "Important"
                      :tag "Important"
                      :priority "A"
                      )
                    (:name "Next Action"
                      :category "Next Action"
                      :priority "B")
                    (:name "Shopping"
                      :category "Shopping")
                    (:name "Projects"
                      :file-path "projects/")
                    (:name "Areas"
                      :file-path "areas/")
                    (:name "Resources"
                      :file-path "resources/")
                    (:name "Inbox"
                      :category "Inbox")
                    ))
               ))
           ))
       )
    )
  (setq org-capture-templates
    '(
       ("t" "Task" entry (file+headline "gtd.org" "Inbox")
         "* TODO %? \nCREATED: %U\n %i")
       ("n" "Task NEXT" entry (file+headline "gtd.org" "Inbox")
         "* NEXT %? \nCREATED: %U\n %i ")
       ("T" "Task from protocol" entry (file+headline "gtd.org" "Inbox")
         "* TODO %? [[%:link][%:description]] \nCREATED: %U\n%i\n\n")
       ("L" "ReadItLater" entry (file+headline "gtd.org" "ReadItLater")
         "* TODO %? [[%:link][%:description]] \nCREATED: %U\n%i\n")
       ))

  ;; C-S-Enter で見出し作ったときにタイムスタンプをつける
  (defun my/org-insert-created-timestamp ()
    "Insert timestamp as plain text after heading"
    (interactive)
    (let ((heading-pos (point)))  ; 現在位置（見出し）を保存
      (org-back-to-heading t)
      (end-of-line)
      (insert "\nCREATED: " (format-time-string "[%Y-%m-%d %a %H:%M]"))
      (goto-char heading-pos)     ; 元の位置（見出し末尾）に戻る
      (end-of-line)))            ; 見出しの末尾に移動
  (defun my/org-insert-todo-with-timestamp (&rest _)
    "Advice function to add timestamp after creating a TODO heading"
    (when (org-at-heading-p)
      (my/org-insert-created-timestamp)))

  (advice-add 'org-insert-todo-heading-respect-content
    :after #'my/org-insert-todo-with-timestamp)
  
  ;; journal
  (setq org-journal-file-format "%Y-%m-%d")
  (setq org-journal-date-format "%Y-%m-%d %A")
  ;; (setq org-journal-time-format "%R ")
  (setq org-journal-file-type 'weekly)
  (setq org-journal-find-file 'find-file)
  (setq org-extend-today-until '3)
  (add-hook 'org-journal-after-entry-create-hook 'evil-insert-state)
  (setq org-startup-with-inline-images t)

  (setq org-M-RET-may-split-line t)
  ;; FIXME 動いていない
  (when (winp)
    (setq org-download-screenshot-method "magick convert clipboard: %s")
    )

  ;; export周りの設定
  (setq org-export-with-toc nil)
  (setq org-export-with-section-numbers nil)
  (setq org-export-with-creator nil)
  (setq org-use-sub-superscripts nil)
  (setq org-export-with-sub-superscripts nil)


  (defun my/get-title-or-filename (buffer file)
    "Get the Org file #+TITLE property or use the filename if title is nil."
    (with-current-buffer buffer
      (or (org-element-map (org-element-parse-buffer 'element) 'keyword
            (lambda (kw)
              (when (string= "TITLE" (org-element-property :key kw))
                (org-element-property :value kw)))
            nil t)
        (file-name-nondirectory file))))

  (defun my/collect-next-tasks-from-agenda-files ()
    "Collect NEXT tasks, today's tasks, and overdue incomplete tasks from `org-agenda-files`."
    (interactive)
    (let (tasks
           (today (format-time-string "%Y-%m-%d")))
      (dolist (file (org-agenda-files))
        (let ((buffer (find-file-noselect file)))
          (with-current-buffer buffer
            (org-with-wide-buffer
              (let ((title-or-filename (my/get-title-or-filename buffer file))
                     (parsed-buffer (org-element-parse-buffer 'headline)))
                (org-element-map parsed-buffer 'headline
                  (lambda (headline)
                    (let* ((todo-keyword (org-element-property :todo-keyword headline))
                            (title (org-element-property :raw-value headline))
                            (begin (org-element-property :begin headline))
                            (deadline (org-element-property :deadline headline))
                            (scheduled (org-element-property :scheduled headline))
                            (is-next (and todo-keyword (string= todo-keyword "NEXT")))
                            (is-not-done (and todo-keyword (not (string= todo-keyword "DONE"))))
                            (deadline-date (when deadline 
                                             (format-time-string "%Y-%m-%d" 
                                               (org-timestamp-to-time deadline))))
                            (scheduled-date (when scheduled 
                                              (format-time-string "%Y-%m-%d" 
                                                (org-timestamp-to-time scheduled))))
                            (is-overdue (or 
                                          (and deadline-date (string< deadline-date today))
                                          (and scheduled-date (string< scheduled-date today))))
                            (is-today (or
                                        (and deadline-date (string= deadline-date today))
                                        (and scheduled-date (string= scheduled-date today)))))
                      ;; Collect if it's NEXT, today's task, or overdue
                      (when (or is-next
                              (and is-not-done (or is-today is-overdue)))
                        (push (list 
                                title 
                                begin 
                                file 
                                title-or-filename
                                (cond
                                  (is-next "NEXT")
                                  ((and deadline-date is-overdue) (format "期限超過 (%s)" deadline-date))
                                  ((and scheduled-date is-overdue) (format "予定超過 (%s)" scheduled-date))
                                  ((and deadline-date is-today) "今日期限")
                                  ((and scheduled-date is-today) "今日予定"))
                                todo-keyword)
                          tasks))))))))))
      
      ;; Sort tasks by priority: NEXT -> Today's tasks -> Overdue tasks
      (setq tasks (sort tasks
                    (lambda (a b)
                      (let ((a-type (nth 4 a))
                             (b-type (nth 4 b)))
                        (cond
                          ((string= a-type "NEXT")
                            (if (string= b-type "NEXT")
                              (string< (car a) (car b))
                              t))
                          ((or (string= a-type "今日期限") (string= a-type "今日予定"))
                            (if (string= b-type "NEXT")
                              nil
                              (if (or (string= b-type "今日期限") (string= b-type "今日予定"))
                                (string< (car a) (car b))
                                t)))
                          (t (if (or (string= b-type "NEXT") 
                                   (string= b-type "今日期限")
                                   (string= b-type "今日予定"))
                               nil
                               (string< (car a) (car b)))))))))
      
      ;; Insert the collected tasks at point
      (dolist (task tasks)
        (let* ((task-title (nth 0 task))
                (task-pos   (nth 1 task))
                (task-file  (nth 2 task))
                (task-category (nth 3 task))
                (task-type (nth 4 task))
                (todo-keyword (nth 5 task))
                ;; Check if the title contains a link by looking for [[ pattern
                (contains-link (string-match-p "\\[\\[" task-title)))
          (insert 
            (format "** TODO %s (%s) : %s\n"
              ;; If title contains a link, use it as is, otherwise create a link to the heading
              (if contains-link
                task-title
                (format "[[file:%s::*%s][%s]]"
                  task-file
                  task-title
                  task-title))
              task-type
              task-category))))))
  
  )

(map! :after evil-org
  :map evil-org-mode-map
  :ni "C-<return>" #'org-insert-heading-respect-content
  :ni "C-S-<return>" #'org-insert-todo-heading-respect-content
  :ni "M-<left>" #'org-metaleft
  :ni "M-<right>" #'org-metaright
  )

(after! evil-org
  (remove-hook 'org-tab-first-hook #'+org-cycle-only-current-subtree-h)
  )
(after! org-roam
  (map!
    "C-c n l" #'org-roam-buffer-toggle
    "C-c n f" #'org-roam-node-find
    "C-c l" #'org-roam-dailies-goto-today
    "C-c d" #'org-roam-dailies-map
    :map org-mode-map
    "C-c n i" #'org-roam-node-insert
    "C-M-i" #'completion-at-point
    )
  (setq org-roam-completion-everywhere nil)

  (setq org-roam-node-display-template
    (format "%s ${doom-hierarchy:*} %s"
      (propertize "${doom-type:15}" 'face 'font-lock-keyword-face)
      (propertize "${doom-tags:10}" 'face '(:inherit org-tag :box nil))))
  (setq org-roam-dailies-capture-templates
    '(("d" "default" entry "* %<%H:%M> %?"
        :target (file+head "%<%Y-%m-%d>.org"
                  "#+title: %<%Y-%m-%d>

* 今日の目標

* 思い+タスク


** TODO 日記を書く

* できれば
"))
       )
    )
  (setq org-roam-capture-templates
    '(
       ("d" "default (Zettelkasten Permanent)" plain
         "%?"
         :target (file+head "zk/%<%Y%m%d%H%M%S>-${slug}.org"
                   "#+title: ${title}
#+filetags: :draft:")
         :unnarrowed t)
       ("p" "project" plain
         "* 目的・目標
- %?

* Tasks
** TODO Add initial tasks

* Notes
"
         :target (file+head "projects/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}")
         :unnarrowed t)
       ("a" "area" plain
         "* 目標
# このエリアで達成したい長期的な目標や維持すべき基準
%?

* Projects

* Someday Projects
:PROPERTIES:
:CATEGORY: Someday PJ
:END:

* 定期タスク

* Resource

"
         :target (file+head "areas/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}")
         :unnarrowed t)
       ("r" "rez (Resonance Calendar)" plain "* ${title}
:PROPERTIES:
:Type: %?
:Start: <%<%Y-%m-%d %a>>
:Fin: 
:Canceled: 
:Rating: 
:Creator: 
:URL: 
:ReleaseDate:
:END:

** Why
# なぜ読もう・見ようと思ったのか

** Tasks
*** TODO 読む・見る

** Key Ideas

** Review

** Quotes

** Notes

"
         :target (file+head "resources/rez/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}")
         :unnarrowed t)
       ("e" "exp (Experiments)" plain "* ${title}
:PROPERTIES:
:Type: Exp
:Start:
:Fin:
:Assess: <yyyy-mm-dd aaa>
:Qs:
:Status:
:Outcome:
:END:

** Tasks

** 仮説

** 実験手順

** 観察とメモ

** 結果と考察

** 注意点

** 次の実験アイデア

"
         :target (file+head "resources/rez/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}")
         :unnarrowed t)
       )
    )

  (defun my/create-weekly-review ()
    "Create a new org-roam file for weekly review using org-roam-capture-."
    (interactive)
      (let* ((week-number (format-time-string "%V"))
         (year (format-time-string "%Y"))
         (slug (concat year "w" week-number))
         (file-path (format "weekly/%s.org" slug))
         (title (format "Weekly Review %sw%s" year week-number)))
      (org-roam-capture-
        :node (org-roam-node-create :title title)
        :props '(:finalize find-file)
        :templates
        `(("w" "weekly review" plain
            "* Review
レビュー日 <%<%Y-%m-%d %a>>
** 明確にする
*** 把握する
Inboxに収集する
- [ ] Keep memo
- [ ] 紙の書類
- [ ] コミュニケーションツール
  - [ ] メール
  - [ ] LINE
  - [ ] チャットツール
- [ ] カレンダーの予定を確認し、適切なアクションを登録する
*** 頭を空っぽにする
- [ ] 5分で新しいプロジェクト、連絡待ちの事柄、いつかやろうと思っていることなどを書き出し、頭を空にする
** 見極める
*** Inboxを空にする
- [ ] Inboxに入っている明らかになっていないものを仕分け、Inboxを空にする
  - すぐにできるものは実行
*** アクションリストを見直す
- [ ] 完了したアクションはDONEにする
- [ ] 必要があればリマインダーをセットする
- [ ] 連絡待ちリストの更新
- [ ] 参考資料などを適切な場所に保存
*** 次に取るべき行動を考える
- [ ] アクションを推進するためのタスクを定義して追加する
  - プロジェクトリストや行動できていない項目について、次に取るべき行動は何かを考える
** 整理する
- [ ] プロジェクトリストの更新
  - 長期的なゴールやビジョンに沿ったアクションを見直す
  - プロジェクトリストを見返し、目標や結果の状態を一つ一つ評価する
  - 各項目について少なくとも1つの次の取るべき行動があることを確認する
- [ ] いつかやるリストの更新
** 閉じる
- [ ] org-agenda タスクをアーカイブする
** 今週振り返り
*** Good
*** Problem
*** Try
** 来週達成したいこと
"
            :if-new (file+head ,file-path
                      ,(format "#+title: %s\n" title))
            :immediate-finish t
            :unnarrowed t)))))
  
  (setq org-roam-capture-ref-templates
    '(
       ("r" "ref" plain
         "%?"
         :target (file+head "resources/ref/%<%Y%m%d%H%M%S>-${slug}.org"
                   "#+title: ${title}\n${ref}\n${body}")
         :unnarrowed t)
       ("z" "rez (Resonance Calendar) from protocol" plain "%?"
         :target (file+head "resources/rez/%<%Y%m%d%H%M%S>-${slug}.org"
                   "#+title: ${title}
* ${title}
:PROPERTIES:
:Type: ${type}
:Start: <%<%Y-%m-%d %a>>
:Fin: 
:Canceled: 
:Rating: 
:Creator: ${creator}
:URL: ${ref}
:ReleaseDate: ${releaseDate}
:END:

** Why
# なぜ読もう・見ようと思ったのか

** Tasks
*** TODO 読む・見る

** Key Ideas

** Review

** Quotes

** Notes

")
         :unnarrowed t)
       ))

  (defun my/org-get-title-from-file (file)
    "Extracts the #+TITLE from the org FILE, or uses the filename if none found."
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (if (re-search-forward "^#\\+title:\\s-*\\(.+\\)$" nil t)
          (match-string 1)
        (file-name-nondirectory file))))

  (defun my/org-list-files-in-directory (dir)
    "Lists all org files in the given directory DIR within org-roam-directory."
    (directory-files (expand-file-name dir org-roam-directory)
                     t "\\.org$"))

  (defun my/org-open-file-main-window (file)
    "Open FILE in the main window."
    (let ((main-window (get-largest-window)))
      (select-window main-window)
      (find-file file)))

  (defun my/org-file-link-action (file)
    "Custom action for org file links to open in main window."
    (my/org-open-file-main-window file))

  (defun my/org-generate-buffer-from-files (files dir)
    "Create a buffer that lists FILES with their titles as links, and display it in a side window.
DIR is the directory name for display purposes."
    (let* ((buf (get-buffer-create "*Org-Roam Files*"))
           (window (display-buffer-in-side-window
                    buf
                    '((side . left)
                      (slot . 0)
                      (window-width . 30)
                      (preserve-size . (t . nil))))))
      (with-current-buffer buf
        (erase-buffer)
        (org-mode)
        (org-link-set-parameters "orgfile"
                                 :follow #'my/org-file-link-action)
        (insert (format "Files in %s\n\n" dir))
        (dolist (file files)
          (let ((title (my/org-get-title-from-file file)))
            (insert (format "- [[orgfile:%s][%s]]\n" file title))))
        (goto-char (point-min))
        (read-only-mode 1))
      ;; サイドウィンドウにフォーカスを移動
      (select-window window)))

  (defun my/org-open-areas-files ()
    "Opens a list of the org files in the 'areas' directory."
    (interactive)
    (let ((files (my/org-list-files-in-directory "areas")))
      (my/org-generate-buffer-from-files files "areas")))

  (defun my/org-open-projects-files ()
    "Opens a list of the org files in the 'projects' directory."
    (interactive)
    (let ((files (my/org-list-files-in-directory "projects")))
      (my/org-generate-buffer-from-files files "projects")))
  )

(after! org-roam-protocol
  (defun org-roam-protocol-open-ref (info)
    "Process an org-protocol://roam-ref?ref= style url with INFO."
    (let ((org-capture-link-is-already-stored t))
      (org-roam-capture-
        :keys (plist-get info :template)
        :node (org-roam-node-create :title (plist-get info :title))
        :info (list :ref (plist-get info :ref)
                :body (plist-get info :body)
                ;; 独自の変数を送れるように追加
                :type (plist-get info :type)
                :creator (plist-get info :creator)
                :releaseDate (plist-get info :releaseDate)
                )
        :templates org-roam-capture-ref-templates))
    nil)
  )

(use-package! org-super-agenda
  :after org-agenda
  :hook (org-agenda-mode . org-super-agenda-mode)
  :config
  ;; evil keymap https://github.com/alphapapa/org-super-agenda/issues/50
  (setq org-super-agenda-header-map (make-sparse-keymap))
  )

(use-package! org-roam-timestamps
  :after org-roam
  :config (org-roam-timestamps-mode))

;; GnuPG for auth-source
(when (winp)
  (custom-set-variables
    '(epg-gpg-home-directory "~/scoop/apps/gpg/current/home")
    '(epg-gpg-program "~/scoop/apps/gpg/current/bin/gpg.exe")
    '(epg-gpgconf-program "~/scoop/apps/gpg/current/bin/gpgconf.exe")
    )
  )
(use-package! org-ai
  :after org
  :commands (org-ai-mode)
  :init
  (add-hook 'org-mode-hook #'org-ai-mode) ; enable org-ai in org-mode
  ;; https://github.com/rksm/org-ai/issues/18#issuecomment-1737931580
  (defun my/org-ai-after-chat-insertion-hook (type _text)
    (when (and (eq type 'end) (eq major-mode 'org-mode) (memq 'org-indent-mode minor-mode-list))
      (org-indent-indent-buffer)))
  (add-hook 'org-ai-after-chat-insertion-hook #'my/org-ai-after-chat-insertion-hook)
  ;; warning 抑制
  (defun my/suppress-org-ai-warnings (old-fun &rest args)
    (with-demoted-errors "org-ai: %S"
      (apply old-fun args)))
  (advice-add 'org-element-cache-reset :around #'my/suppress-org-ai-warnings)
  :config
  (setq org-ai-default-chat-model "gpt-4o")
  )
(setq markdown-fontify-code-blocks-natively t)
