;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'ox-publish)
(require 'blog-layout (expand-file-name "./layout.el" (file-name-directory (or load-file-name buffer-file-name default-directory))))

(defun blog/html-inner-template-post (contents info)
  (let ((date (org-export-data (plist-get info :date) info))
        (title (org-export-data (plist-get info :title) info))
       )
    (concat
     "<article class=\"post\">" "\n"
     "  <header id=\"post-header\">" "\n"
     "    <h1 id=\"post-title\" class=\"title\">" title "</h1>" "\n" ; class "title" is how org does it.
     "    <p id=\"post-date\">Date: <time datetime=\"" date "\">" date "</time></p>" "\n"
     "  </header>" "\n"
     "  " contents "\n"
     "  " (org-html-footnote-section info) "\n"
     "</article>" "\n"
    )
  )
)

(defun blog/html-postamble-post (info)
  (concat
   "<div class=\"postamble-post\">" "\n"
   "  <p>Thanks for reading till the end!" "\n"
   "    If you found this interesting, check out " blog/home-link " for more of my writing." "\n"
   "  </p>" "\n"
   "</div>" "\n"
   (blog/html-postamble-common info) "\n"
  )
)

(provide 'blog-layout-post)
