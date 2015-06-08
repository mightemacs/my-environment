;; it's always nice to have a dedicated subfolder of customizations
(add-to-list 'load-path "~/.emacs.d/")

;; color themes
(set-foreground-color "gray")
(set-background-color "black")
(load-theme 'tsdh-dark t)

;; show line numbers
(setq-default linum-mode 1)

;; tabs are the bane of my existence
(setq-default indent-tabs-mode nil)

;; buffer cycling w/ C-tab and C-shift-tab (defined as chords so they can be held down)
(when (> emacs-major-version 21)
  (global-set-key [C-tab] 'next-buffer)
  (global-set-key [S-C-tab] 'previous-buffer)
)

