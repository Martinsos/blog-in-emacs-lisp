;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(let ((script-dir-abs (file-name-directory (or load-file-name buffer-file-name default-directory))))
  (defconst blog/src-dir-abs (expand-file-name "../src" script-dir-abs))
  (defconst blog/src-posts-dir-abs (expand-file-name "./posts" blog/src-dir-abs))
  (defconst blog/dist-dir-abs (expand-file-name "../dist" script-dir-abs))
  (defconst blog/dist-posts-dir-abs (expand-file-name "./posts" blog/dist-dir-abs))
)

(provide 'blog-paths)
