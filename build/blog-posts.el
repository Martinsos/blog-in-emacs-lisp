;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'org)
(require 'blog-paths (expand-file-name "blog-paths.el" (file-name-directory (or load-file-name buffer-file-name default-directory))))

;; Collect post metadata (date, title, filename) from all org files in src/posts/.
;; Sorted by date, newest first. Available to elisp blocks in published org files, as a global const.
(defconst
  blog/all-posts
  (let* ((org-files (directory-files blog/src-posts-dir-abs t "\\.org$")))
    (sort
     (mapcar
      (lambda (f)
        (with-temp-buffer
          (insert-file-contents f)
          (org-mode)
          (let* ((keywords (org-collect-keywords '("TITLE" "DATE")))
                 (title (car (alist-get "TITLE" keywords nil nil #'string=)))
                 (date-str (car (alist-get "DATE" keywords nil nil #'string=))))
            (unless title (error "Post %s is missing #+TITLE" f))
            (unless (and date-str (not (string-blank-p date-str)))
              (error "Post %s is missing #+DATE" f))
            (list (date-to-time date-str) title (file-name-nondirectory f)))))
      org-files)
     (lambda (a b) (time-less-p (car b) (car a))))
  )
)

(provide 'blog-posts)
