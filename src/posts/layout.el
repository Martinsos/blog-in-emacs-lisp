;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'ox-publish)
(require 'blog-layout (expand-file-name "../layout.el" (file-name-directory (or load-file-name buffer-file-name default-directory))))

(defun blog/html-preamble-post (_info)
  (concat
   blog/home-link "\n"
  )
)

(defun blog/post-html-inner-template (contents info)
  (let ((date (org-export-data (plist-get info :date) info))
        (title (org-export-data (plist-get info :title) info))
       )
    (concat
     "<article class=\"post\">" "\n"
     "  <header id=\"post-header\">" "\n"
     "    <h1 id=\"post-title\">" title "</h1>" "\n"
     "    <p id=\"post-date\">Date: " date "</p>" "\n"
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
   "    To learn more about my current main project, check out " blog/wasp-link "." "\n"
   "  </p>" "\n"
   "</div>" "\n"
   (blog/html-postamble-common info) "\n"
  )
)

(provide 'blog-post-layout)
