;;; -*- lexical-binding: t; flycheck-disabled-checkers: (emacs-lisp-checkdoc) -*-

(require 'ox-publish)

;;; Generate deterministic IDs instead of random ones for HTML export.
;;; Headings get slugified title-based IDs, other elements get sequential IDs.

(defun org-export-dtrm-refs-use ()
  "Override `org-export-get-reference' to generate deterministic IDs."
  (advice-add 'org-export-get-reference :override #'org-export-dtrm-refs--get-ref))

;; TODO: Review this function.
(defun org-export-dtrm-refs--get-ref (datum info)
  "Like `org-export-get-reference' but generates deterministic IDs.
Uses heading titles for headings, sequential counters for other elements."
  (let ((cache (plist-get info :internal-references)))
    (or (car (rassq datum cache))
        (let* ((crossrefs (plist-get info :crossrefs))
               (cells (org-export-search-cells datum))
               (new (or (cl-some
                         (lambda (cell)
                           (let ((stored (cdr (assoc cell crossrefs))))
                             (when stored
                               ;; TODO: THere is something suspicious here, AI first tried to call
                               ;; org-export-format-reference on stored value and then pass that to
                               ;; the assoc, but then later that appeared to error so now it skipped
                               ;; that as it is unneccesary, allegedly what we store is already in
                               ;; ok format. Maybe this is ok now, but look into why it was doing
                               ;; that in the first place, maybe problem is somewhere else.
                               (and (not (assoc stored cache)) stored))))
                         cells)
                        (when (org-element-property :raw-value datum)
                          (org-export-dtrm-refs--generate-heading-id datum cache))
                        (format "el-%d" (hash-table-count
                                         (or (plist-get info :org-export-dtrm-refs-element-counter)
                                             (let ((ht (make-hash-table)))
                                               (plist-put info :org-export-dtrm-refs-element-counter ht)
                                               ht))))))
               (reference-string new))
          ;; Track non-heading element count.
          (unless (org-element-property :raw-value datum)
            (let ((ht (plist-get info :org-export-dtrm-refs-element-counter)))
              (when ht (puthash (hash-table-count ht) t ht))))
          (dolist (cell cells) (push (cons cell new) cache))
          (push (cons reference-string datum) cache)
          (plist-put info :internal-references cache)
          reference-string))))

(defun org-export-dtrm-refs--generate-heading-id (datum ids-cache)
  "Generate an id for DATUM heading title, unique within IDS-CACHE.
DATUM is an org-element object.
We do so by turning title into a slug and using it as an id:
turn urls into text, take only alphanums, replace the rest with hyphens.
E.g. \"Test Title [[test.com][testpage]]!\" becomes test-title-testpage.
If this comes out empty, we just use \"heading\" as id.
And finally, if this id is not unique (per IDS-CACHE), we add counter
to it till it is."
  (let* ((title (substring-no-properties (org-element-property :raw-value datum)))
         (slug (org-export-dtrm-refs--slugify (org-export-dtrm-refs--links-to-text title)))
         (id (if (string-empty-p slug) "heading" slug)))
    (let ((unique-id id)
          (counter 2))
      (while (assoc unique-id ids-cache)
        (setq unique-id (format "%s-%d" id counter)
              counter (1+ counter))
      )
      unique-id
    )
  )
)

(defun org-export-dtrm-refs--links-to-text (str)
  "In given string, replace org links with their textual representation.
That means [[target][desc]] becomes desc, and [[target]] becomes target."
  (replace-regexp-in-string
   (rx "[[" (group (* (not "]"))) (opt "][" (group (* (not "]")))) "]]")
   (lambda (match) (or (match-string 2 match) (match-string 1 match)))
   str))


(defun org-export-dtrm-refs--slugify (str)
  "Turn given string into a \"slug\": a stripped version containing only alphanum
sequences separated with hyphens.
Example: \"HP Omen (2014): design + power!\" -> \"hp-omen-2014-design-power\""
  (replace-regexp-in-string (rx (or (seq bos "-") (seq "-" eos))) "" ; Strip leading/trailing hyphens.
   (replace-regexp-in-string "[^a-z0-9]+" "-" ; Replace any non-alphanum sequences with a hyphen.
    (downcase
     (string-trim
      str))))
)

(provide 'org-export-dtrm-refs)
