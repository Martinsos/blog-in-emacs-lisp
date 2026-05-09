;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(defconst blog/title "TODO My blog")
(defconst blog/url "https://todo-myblog.com")
(defconst blog/description "TODO My blog where I write about things I like")

(defconst blog/rss-xml-in-dist "rss.xml")
(defconst blog/posts-dir-in-dist "posts")

(let ((script-dir-abs (file-name-directory (or load-file-name buffer-file-name default-directory))))
  (defconst blog/src-dir-abs (expand-file-name "../src" script-dir-abs))
  (defconst blog/src-posts-dir-abs (expand-file-name "./posts" blog/src-dir-abs))
  (defconst blog/dist-dir-abs (expand-file-name "../dist" script-dir-abs))
  (defconst blog/dist-posts-dir-abs (expand-file-name blog/posts-dir-in-dist blog/dist-dir-abs))
)

(defun blog/parse-date (date-str)
  "Parse DATE-STR. Must be YYYY-MM-DD. Time is assumed as UTC midnight."
  (unless (string-match-p "\\`[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\'" date-str)
    (error "Invalid #+DATE: %S (expected YYYY-MM-DD)" date-str))
  (date-to-time (concat date-str "T00:00:00+0000"))
)

(provide 'blog-common)
