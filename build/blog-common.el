;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(defconst blog/title "Martinsos' blog")
(defconst blog/url "https://martinsos.com")
(defconst blog/description "Personal blog post about software engineering, computer science, startups, and other fun stuff.")

(defconst blog/rss-xml-in-dist "rss.xml")
(defconst blog/posts-dir-in-dist "posts")

(let ((script-dir-abs (file-name-directory (or load-file-name buffer-file-name default-directory))))
  (defconst blog/src-dir-abs (expand-file-name "../src" script-dir-abs))
  (defconst blog/src-posts-dir-abs (expand-file-name "./posts" blog/src-dir-abs))
  (defconst blog/dist-dir-abs (expand-file-name "../dist" script-dir-abs))
  (defconst blog/dist-posts-dir-abs (expand-file-name blog/posts-dir-in-dist blog/dist-dir-abs))
)

(provide 'blog-common)
