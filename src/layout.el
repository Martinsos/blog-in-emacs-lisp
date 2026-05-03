;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'xml)

(require 'blog-common (expand-file-name "../build/blog-common.el" (file-name-directory (or load-file-name buffer-file-name default-directory))))

(defconst
  blog/html-head-common
  (string-join
   `(
     ;; Main CSS.
     "<link rel=\"stylesheet\" href=\"/main.css\"/>"

     ;; Fonts.
     "<link rel=\"stylesheet\" href=\"/fonts/fonts.css\"/>"

     ;;; Code highlighting.
     ;;; Both CSS and JS are loaded async for faster page load since they are not needed urgently.
     ;;;
     ;; Using media="print" + onload="this.media=..." trick below to make CSS loading async.
     "<link rel=\"stylesheet\" href=\"/highlightjs/atom-one-dark.min.css\"
            media=\"print\"
            onload=\"this.media='(prefers-color-scheme: dark), (prefers-color-scheme: no-preference)'\"
      />"
     "<link rel=\"stylesheet\" href=\"/highlightjs/atom-one-light.min.css\"
            media=\"print\"
            onload=\"this.media='(prefers-color-scheme: light)'\"
      />"
     "<script defer src=\"/highlightjs/highlight.min.js\"></script>"
     "<script defer src=\"/highlightjs/dirtree.js\"></script>"
     "<script defer src=\"/highlightjs/ascii-diagram.js\"></script>"
     "<script defer src=\"/highlightjs/elisp.js\"></script>"
     ;; - On DOMContentLoaded so it executes only after deferred scripts load.
     ;; - The \"code-block\" class below must match `blog/code-block-class' in
     ;; build/blog-org-publish-html.el.
     "<script>
          document.addEventListener('DOMContentLoaded', function() {
            hljs.configure({ cssSelector: \".code-block code\" });
            hljs.registerLanguage('dirtree', hljsDirTree);
            hljs.registerLanguage('ascii-diagram', hljsAsciiDiagram);
            hljs.registerLanguage('elisp', hljsElisp);
            hljs.registerAliases([\"emacs-lisp\"], { languageName: \"elisp\" });
            hljs.highlightAll();
          });
      </script>"

     ;;; RSS feed auto-discovery: it is how external tools learn about it.
     ,(concat
       "<link rel=\"alternate\" type=\"application/rss+xml\"" "\n"
       "      title=\"" (xml-escape-string blog/title t) "\"" "\n"
       "      href=\"" blog/url "/" blog/rss-xml-in-dist "\"" "\n"
       "/>"
     )
   ) "\n"
  )
)

(defun blog/html-postamble-common (_info)
  (concat
   "<div class=\"postamble-common\">" "\n"
   "  <p>Built with care with Emacs (Org Mode).</p>" "\n"
   "</div>" "\n"
  )
)

(defconst
  blog/home-link
  "<a class=\"home-link\" href=\"/\">Home</a>"
)
(defconst
  blog/wasp-link
  "<a class=\"wasp-link\" href=\"https://wasp.sh\">Wasp</a>"
)

(provide 'blog-layout)
