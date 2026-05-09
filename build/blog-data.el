;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

;;; Blog (meta)data to be available through the blog build pipeline and layouts.

(require 'org)
(require 'blog-common (expand-file-name "blog-common.el" (file-name-directory (or load-file-name buffer-file-name default-directory))))

;; Collect post metadata (date, title, filename, ...) from all org files in src/posts/.
;; Sorted by date, newest first. Available to elisp blocks in published org files, as a global const.
(defconst
  blog/all-posts
  (let ((org-files (directory-files blog/src-posts-dir-abs t "\\.org$")))
    (sort
     (mapcar
      (lambda (f)
        (with-temp-buffer
          (insert-file-contents f)
          (org-mode)
          (let* ((keywords (org-collect-keywords '("TITLE" "DATE" "DESCRIPTION" "FILETAGS")))
                 (title (car (alist-get "TITLE" keywords nil nil #'string=)))
                 (date-str (car (alist-get "DATE" keywords nil nil #'string=)))
                 (description (car (alist-get "DESCRIPTION" keywords nil nil #'string=)))
                 (tags (split-string (or (car (alist-get "FILETAGS" keywords nil nil #'string=)) "") ":" t))
                )
            (unless title
              (error "Post %s is missing #+TITLE" f))
            (unless (and date-str (not (string-blank-p date-str)))
              (error "Post %s is missing #+DATE" f))
            (list
             :date (blog/parse-date date-str)
             :title title
             :filename (file-name-nondirectory f)
             :description description
             :tags tags
            )
          )
        )
      )
      org-files
     )
     (lambda (a b) (time-less-p (plist-get b :date) (plist-get a :date)))
    )
  )
)

(provide 'blog-data)
