;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(defconst
  blog/html-head-common
  (string-join
   '(;; Fonts.
     "<link rel=\"preload\" href=\"/fonts/IosevkaAile/Regular.woff2\" as=\"font\" type=\"font/woff2\" crossorigin>"
     "<link rel=\"stylesheet\" href=\"/fonts/fonts.css\"/>"
     ;; Main CSS.
     "<link rel=\"stylesheet\" href=\"/main.css\"/>"
     ;; Code highlighting.
     "<link rel=\"stylesheet\" href=\"/highlightjs/atom-one-light.min.css\" media=\"(prefers-color-scheme: light), (prefers-color-scheme: no-preference)\"/>"
     "<link rel=\"stylesheet\" href=\"/highlightjs/atom-one-dark.min.css\" media=\"(prefers-color-scheme: dark)\"/>"
     "<script src=\"/highlightjs/highlight.min.js\"></script>"
     "<script src=\"/highlightjs/dirtree.js\"></script>"
     "<script src=\"/highlightjs/ascii-diagram.js\"></script>"
     "<script src=\"/highlightjs/elisp.js\"></script>"
     ;; The "code-block" class below must match `blog/code-block-class' in build/blog-org-publish-html.el.
     "<script>
          hljs.configure({ cssSelector: \".code-block code\" });
          hljs.registerLanguage('dirtree', hljsDirTree);
          hljs.registerLanguage('ascii-diagram', hljsAsciiDiagram);
          hljs.registerLanguage('elisp', hljsElisp);
          hljs.registerAliases([\"emacs-lisp\"], { languageName: \"elisp\" });
          hljs.highlightAll();
        </script>"
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
