;;; -*- no-byte-compile: t -*-

((compilation-mode
  . ((eval . (progn
               (font-lock-add-keywords
                nil
                '(("^\\(?:Skipping\\) .*$" 0 '(shadow) t)
                  ("^\\(Publishing\\) .*$" 1 '(bold success) t)
                  ("^.*\\b\\([Ee]rror\\|[Ww]arning\\|[Ff]ailed\\)\\b.*$"
                   1 '(bold error) t)))
               (when (fboundp 'font-lock-flush)
                 (font-lock-flush)))))))
