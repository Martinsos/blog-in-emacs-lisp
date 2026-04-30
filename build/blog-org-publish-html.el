;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'ox-publish)

;; Here I extend the 'html (from ox-html.el) backend to define my own, customized version of it.
;; Mostly I turn off a lot of its default options (default css, default js, ...),
;; and I redefine how some parts of org are translated into HTML (usually simplification).
;; I also turn off some options from the core ox.el.
;; In general, the default 'html backend is great but cluttered with default choices that
;; are just in the way, and I create a cleaner/saner version of it here.
(org-export-define-derived-backend 'blog/html 'html
  :options-alist
  ;; Options specified here add/override those specified in 'html backend (not all, just these ones).
  ;; Each entry is (PROPERTY KEYWORD OPTION DEFAULT BEHAVIOR).
  ;; KEYWORD means it can be specified as #+<KEYWORD>: <somevalue> in the org file.
  ;; OPTION means it can be specified as one of options in #+OPTIONS: <OPTION>:<somevalue> in the org file.
  ;; BEHAVIOR specifies how multiple same KEYWORDs in the org file are combined.
  ;; Below I mostly just copy options from 'html for which I want to change default value, and change only it.
  '((:html-doctype nil nil "html5")
    (:html-html5-fancy nil nil t)
    (:html-validation-link nil nil nil)        ; I set default to nil, so this weird html validation link is not added.
    (:html-head-include-scripts nil nil nil)   ; I set default to nil, so default JS is not included.
    (:html-head-include-default-style nil nil nil) ; I set default to nil, so default CSS is not included.
    (:html-prefer-user-labels nil nil t)       ; I set default to t, so "id" is generated only if CUSTOM_ID is not set.
    (:html-preamble nil "html-preamble" nil)   ; I set default to nil.
    (:html-postamble nil "html-postamble" nil) ; I set default to nil.
    (:html-head "HTML_HEAD" nil "" newline)    ; I set default to nil.
    (:with-toc nil "toc" nil nil)              ; I set default to nil.
    (:with-author nil "author" nil nil)        ; I set default to nil.
    (:section-numbers nil "num" nil nil)       ; I set default to nil.
    (:time-stamp-file nil "timestamp" nil nil) ; I set default to nil.
    (:headline-levels nil "H" 5 nil)           ; I set default to 5.
    (:html-inner-template nil nil nil)         ; Custom option I created for wrapping the content.
   )
  :translate-alist
  '((src-block . blog/org-html-src-block)
    (inner-template . blog/org-html-inner-template)
   )
)

(defun blog/org-publish-to-html (plist filename pub-dir)
  "Publish FILENAME to PUB-DIR using the `blog/html` derived backend."
  (org-publish-org-to 'blog/html filename ".html" plist pub-dir))

(defun blog/org-html-inner-template (contents info)
  (let ((template-fn (plist-get info :html-inner-template)))
    (if template-fn
        (funcall template-fn contents info)
      ;; Like default behavior, but without footnotes: just contents.
      (concat contents "\n")
    )
  )
)

;; This value must match the "code-block" class used in src/layout.el's hljs configuration.
(defconst blog/code-block-class "code-block")

;; I wrote this function by looking at org-html-src-block from ox-html.el.
(defun blog/org-html-src-block (src-block _contents info)
  "Transcode a SRC-BLOCK element from Org to HTML.
CONTENTS holds the contents of the item.  INFO is a plist holding
contextual information."
  (if (org-export-read-attribute :attr_html src-block :textarea)
      (org-html--textarea-block src-block)
    (let* ((lang (org-element-property :language src-block))
           (code (org-html-format-code src-block info))
           (params (org-babel-parse-header-arguments (org-element-property :parameters src-block)))
           (filename (cdr (assoc :filename params)))
           (id (let ((ref (org-html--reference src-block info t)))
                 (if ref (format " id=\"%s\"" ref) "")))
          )
      (format "<div class=\"%s\">%s\n%s\n</div>"
              blog/code-block-class
              (format "\n<div class=\"code-block-info\">%s</div>"
                      (string-join (delq nil (list
                        (when lang (format "\n<span class=\"code-block-lang\">%s</span>" lang))
                        (when filename (format "\n<span class=\"code-block-filename\">file: %s</span>" filename))
                      )) " | ")
              )
              (format "<pre><code class=\"language-%s\"%s>%s</code></pre>" (or lang "plaintext") id code)
      )
    )
  )
)

(provide 'blog-org-publish-html)
