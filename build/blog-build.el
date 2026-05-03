;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'ox-publish)

;; Across this project we use explicit-filename `require' calls (i.e. `(require 'foo "/path/to/foo.el")')
;; instead of relying on `load-path'. This avoids any dependency on what happens to be on the user's
;; emacs `load-path' and keeps each file's dependencies fully self-contained.
;;
;; To compute "this file's directory" we need an expression that resolves correctly in all three
;; environments we run in:
;;   1. `emacs --script' (how `make build-clean' / `make build-inc' invoke this).
;;      `load-file-name' is set.
;;   2. Interactive in-buffer evaluation (e.g. `eval-buffer' while editing).
;;      `buffer-file-name' is set.
;;   3. Flycheck's byte-compile subprocess.
;;      The prior two are nil, but `default-directory' is set to the file's dir.
;; Hence the `(or load-file-name buffer-file-name default-directory)' chain.
;;
;; `eval-and-compile' is needed because explicit-filename `require's evaluate their filename argument
;; at byte-compile time, so `blog/-this-dir' must be bound at compile time too -- a plain `defconst'
;; only binds at load time.
(eval-and-compile
  (defconst blog/-this-dir
    (file-name-directory (or load-file-name buffer-file-name default-directory))))

(require 'org-export-dtrm-refs (expand-file-name "org-export-dtrm-refs.el" blog/-this-dir))
(require 'blog-org-publish-html (expand-file-name "blog-org-publish-html.el" blog/-this-dir))

(org-export-dtrm-refs-use) ; Makes generated html ids deterministic.

;; General org-html options that I wasn't able to override while defining derived backend:
(setq org-html-htmlize-output-type nil) ; Don't try to style the code snippets.

(setq org-export-with-sub-superscripts '{}) ; For export: require {} around sub/superscripts.

;; Set up org-babel so it can evaluate elisp code blocks, so I can then use them to dynamically
;; generate parts of the files (html): org-export will run them during publishing html if they have
;; `:export results :results html` in the header.
(with-eval-after-load 'org
  (org-babel-do-load-languages 'org-babel-load-languages '((emacs-lisp . t)))
  (setq org-confirm-babel-evaluate nil)
)

(require 'blog-common (expand-file-name "blog-common.el" blog/-this-dir))
(require 'blog-layout (expand-file-name "layout.el" blog/src-dir-abs))
(require 'blog-post-layout (expand-file-name "layout.el" blog/src-posts-dir-abs))
(require 'blog-data (expand-file-name "blog-data.el" blog/-this-dir))
(require 'blog-rss (expand-file-name "blog-rss.el" blog/-this-dir))

(setq
 org-publish-project-alist
 `(("org-files"
    :base-directory ,blog/src-dir-abs
    :base-extension "org"
    :exclude "README.org\\|^posts/"
    :recursive t
    :publishing-directory ,blog/dist-dir-abs
    :publishing-function blog/org-publish-to-html
    :html-head ,blog/html-head-common
    :html-postamble ,#'blog/html-postamble-common
   )
   ("org-posts"
    :base-directory ,blog/src-posts-dir-abs
    :base-extension "org"
    :recursive t
    :publishing-directory ,blog/dist-posts-dir-abs
    :publishing-function blog/org-publish-to-html
    :with-title nil
    :html-head ,blog/html-head-common
    :html-preamble ,#'blog/html-preamble-post
    :html-inner-template ,#'blog/post-html-inner-template
    :html-postamble ,#'blog/html-postamble-post
    :completion-function (,#'blog/rss-generate)
   )
   ("static-files"
    ;; Images are only copied as `.webp'. Source `.png'/`.jpg' files may sit next to
    ;; them in `src/' as masters but are deliberately not published — run
    ;; `tools/optimize-image.sh' to produce the `.webp' the build will pick up.
    ;; Likewise, original (full-size) font woff2 files live in `src/fonts/source/'
    ;; as masters and are deliberately not published — run `tools/subset-fonts.sh'
    ;; to produce the subsetted woff2 files in `src/fonts/<font>/' that the build
    ;; will pick up.
    :base-directory ,blog/src-dir-abs
    :base-extension "html\\|css\\|js\\|webp\\|svg\\|woff2"
    :include ("robots.txt")
    :exclude "^fonts/source/"
    :recursive t
    :publishing-directory ,blog/dist-dir-abs
    :publishing-function org-publish-attachment ; Just copies them.
   )
  )
)

;; Publish all projects (all files defined above).
;; By default, it will use its file timestamp cache to determine which
;; files changed and therefore need to be written.
;; You can see in its output where is this file and if it used it and which files it skipped.
;; By passing truthy FORCE, we tell it to delete the timestamp cache first,
;; therefore forcing it to regenerate all the files.
(org-publish-all (getenv "ORG_PUBLISH_FORCE"))
