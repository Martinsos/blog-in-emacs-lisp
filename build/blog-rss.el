;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'xml)

(require 'blog-common (expand-file-name "blog-common.el" (file-name-directory (or load-file-name buffer-file-name default-directory))))
(require 'blog-data (expand-file-name "blog-data.el" (file-name-directory (or load-file-name buffer-file-name default-directory))))

(defun blog/rss-generate (_project)
  (with-temp-file (expand-file-name blog/rss-xml-in-dist blog/dist-dir-abs)
    (insert
     (concat
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" "\n"
      "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">" "\n"
      "  <channel>" "\n"
      "    <title>" (xml-escape-string blog/title) "</title>" "\n"
      "    <link>" blog/url "</link>" "\n"
      "    <description>" (xml-escape-string blog/description) "</description>" "\n"
      "    <language>en</language>" "\n"
      "    <lastBuildDate>" (blog/--rfc822-utc-date nil) "</lastBuildDate>" "\n"
      "    <atom:link href=\"" blog/url "/" blog/rss-xml-in-dist "\"" "\n"
      "               rel=\"self\" type=\"application/rss+xml\"/>" "\n"
     )
    )
    (insert
     (mapconcat
      (lambda (post)
        (let* ((date (plist-get post :date))
               (title (plist-get post :title))
               (filename (plist-get post :filename))
               (link (concat blog/url "/" blog/posts-dir-in-dist "/" (string-replace ".org" ".html" filename)))
               (description (plist-get post :description))
               (tags (plist-get post :tags))
              )
          (concat
           "    <item>" "\n"
           "      <title>" (xml-escape-string title) "</title>" "\n"
           "      <link>" link "</link>" "\n"
           "      <pubDate>" (blog/--rfc822-utc-date date) "</pubDate>" "\n"
           "      <guid isPermaLink=\"true\">" link "</guid>" "\n"
           (if description
               (concat "      <description>" (xml-escape-string description) "</description>" "\n")
             "")
           (mapconcat (lambda (tag)
                        (concat "      <category>" (xml-escape-string tag) "</category>" "\n"))
                      tags "")
           "    </item>" "\n"
          )
        )
      )
      blog/all-posts ; Global variable with metadata of all the posts.
      "\n"
     )
    )
    (insert
     (concat
      "  </channel>" "\n"
      "</rss>" "\n"
     )
    )
  )
)

(defun blog/--rfc822-utc-date (date)
  "Turns given DATE into RFC822 time format string, as UTC.
If DATE is nil, uses current time."
  ;; `system-time-locale "C"' ensures EN weekday/month abbrevs regardless of machine locale.
  (let ((system-time-locale "C"))
    (format-time-string "%a, %d %b %Y %H:%M:%S %z" date t)) ; t -> UTC.
)

(provide 'blog-rss)
