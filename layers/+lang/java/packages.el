;;; packages.el --- Java Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Lukasz Klich <klich.lukasz@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq java-packages
      '(
        company
        (company-emacs-eclim :toggle
                             (configuration-layer/package-usedp 'company))
        eclim
        eldoc
        ensime
        flycheck
        flyspell
        ggtags
        gradle-mode
        groovy-imports
        groovy-mode
        helm-gtags
        (java-mode :location built-in)
        (meghanada :toggle (not (version< emacs-version "25.1")))
        ))

(defun java/post-init-company ()
  (add-hook 'java-mode-local-vars-hook #'spacemacs//java-setup-auto-completion))

(defun java/init-company-emacs-eclim ()
  (use-package company-emacs-eclim
    :defer t
    :init
    (spacemacs|add-company-backends
      :backends company-emacs-eclim
      :modes java-mode)))

(defun java/init-eclim ()
  (use-package eclim
    :defer t
    :config
    (progn
      (require 'eclimd)
      (setq help-at-pt-display-when-idle t
            help-at-pt-timer-delay 0.1)
      (help-at-pt-set-timer)
      (add-to-list 'minor-mode-alist
                   '(eclim-mode (:eval (eclim-modeline-string))))
      ;; key bindings
      (evil-define-key 'insert java-mode-map
        (kbd ".") 'spacemacs/java-eclim-completing-dot
        (kbd ":") 'spacemacs/java-eclim-completing-double-colon
        (kbd "M-.") 'eclim-java-find-declaration
        (kbd "M-,") 'pop-tag-mark
        (kbd "M-<mouse-3>") 'eclim-java-find-declaration
        (kbd "<mouse-8>") 'pop-tag-mark)
      (evil-define-key 'normal java-mode-map
        (kbd "M-.") 'eclim-java-find-declaration
        (kbd "M-,") 'pop-tag-mark
        (kbd "M-<mouse-3>") 'eclim-java-find-declaration
        (kbd "<mouse-8>") 'pop-tag-mark)
      (evil-define-key 'normal eclim-problems-mode-map
        (kbd "a") 'eclim-problems-show-all
        (kbd "e") 'eclim-problems-show-errors
        (kbd "g") 'eclim-problems-buffer-refresh
        (kbd "q") 'eclim-quit-window
        (kbd "w") 'eclim-problems-show-warnings
        (kbd "f") 'eclim-problems-toggle-filefilter
        (kbd "c") 'eclim-problems-correct
        (kbd "RET") 'eclim-problems-open-current)
      (evil-define-key 'normal eclim-project-mode-map
        (kbd "N") 'eclim-project-create
        (kbd "m") 'eclim-project-mark-current
        (kbd "M") 'eclim-project-mark-all
        (kbd "u") 'eclim-project-unmark-current
        (kbd "U") 'eclim-project-unmark-all
        (kbd "o") 'eclim-project-open
        (kbd "c") 'eclim-project-close
        (kbd "i") 'eclim-project-info-mode
        (kbd "I") 'eclim-project-import
        (kbd "RET") 'eclim-project-goto
        (kbd "D") 'eclim-project-delete
        (kbd "p") 'eclim-project-update
        (kbd "g") 'eclim-project-mode-refresh
        (kbd "R") 'eclim-project-rename
        (kbd "q") 'eclim-quit-window)
      (spacemacs/set-leader-keys-for-major-mode 'java-mode
        "ea" 'eclim-problems-show-all
        "eb" 'eclim-problems
        "ec" 'eclim-problems-correct
        "ee" 'eclim-problems-show-errors
        "ef" 'eclim-problems-toggle-filefilter
        "en" 'eclim-problems-next-same-window
        "eo" 'eclim-problems-open
        "ep" 'eclim-problems-previous-same-window
        "ew" 'eclim-problems-show-warnings

        "ds" 'start-eclimd
        "dk" 'stop-eclimd

        "ff" 'eclim-java-find-generic

        "gt" 'eclim-java-find-type

        "rc" 'eclim-java-constructor
        "rg" 'eclim-java-generate-getter-and-setter
        "rf" 'eclim-java-format
        "ri" 'eclim-java-import-organize
        "rj" 'eclim-java-implement
        "rr" 'eclim-java-refactor-rename-symbol-at-point

        "hc" 'eclim-java-call-hierarchy
        "hh" 'eclim-java-show-documentation-for-current-element
        "hi" 'eclim-java-hierarchy
        "hu" 'eclim-java-find-references

        "mi" 'spacemacs/java-maven-clean-install
        "mI" 'spacemacs/java-maven-install
        "mp" 'eclim-maven-lifecycle-phases
        "mr" 'eclim-maven-run
        "mR" 'eclim-maven-lifecycle-phase-run
        "mt" 'spacemacs/java-maven-test

        "aa" 'eclim-ant-run
        "ac" 'eclim-ant-clear-cache
        "ar" 'eclim-ant-run
        "av" 'eclim-ant-validate

        "pb" 'eclim-project-build
        "pc" 'eclim-project-create
        "pd" 'eclim-project-delete
        "pg" 'eclim-project-goto
        "pi" 'eclim-project-import
        "pj" 'eclim-project-info-mode
        "pk" 'eclim-project-close
        "po" 'eclim-project-open
        "pp" 'eclim-project-mode
        "pu" 'eclim-project-update

        "tt" 'eclim-run-junit))))

(defun java/post-init-eldoc ()
  (add-hook 'java-mode-local-vars-hook #'spacemacs//java-setup-eldoc))

(defun java/init-ensime ()
  (use-package ensime
    :defer t
    :commands ensime-mode
    :init
    (progn
      (setq ensime-startup-dirname (concat spacemacs-cache-directory "ensime/"))
      (spacemacs/register-repl 'ensime 'ensime-inf-switch "ensime"))
    :config
    (progn
      ;; key bindings
      (spacemacs/ensime-configure-keybindings 'java-mode)
      (evil-define-key 'insert ensime-mode-map
        (kbd ".") 'spacemacs/ensime-completing-dot
        (kbd "M-.") 'ensime-edit-definition
        (kbd "M-,") 'ensime-pop-find-definition-stack)
      (evil-define-key 'normal ensime-mode-map
        (kbd "M-.") 'ensime-edit-definition
        (kbd "M-,") 'ensime-pop-find-definition-stack)
      (evil-define-key 'normal ensime-popup-buffer-map
        (kbd "q") 'ensime-popup-buffer-quit-function)
      (evil-define-key 'normal ensime-inspector-mode-map
        (kbd "q") 'ensime-popup-buffer-quit-function)
      (evil-define-key 'normal ensime-refactor-info-map
        (kbd "q") 'spacemacs/ensime-refactor-cancel
        (kbd "c") 'spacemacs/ensime-refactor-accept
        (kbd "RET") 'spacemacs/ensime-refactor-accept)
      (evil-define-key 'normal ensime-compile-result-map
        (kbd "g") 'ensime-show-all-errors-and-warnings
        (kbd "TAB") 'forward-button
        (kbd "<backtab>") 'backward-button
        (kbd "M-n") 'forward-button
        (kbd "M-p") 'backward-button
        (kbd "n") 'forward-button
        (kbd "N") 'backward-button))))

;; (defun java/post-init-ensime ()
;;   (when (eq 'ensime java-backend)
;;     (use-package ensime
;;       :defer t
;;       :init
;;       (progn
;;         (spacemacs//ensime-init 'java-mode t nil)
;;         (when (configuration-layer/package-usedp 'company)
;;           (push 'ensime-company company-backends-java-mode)))
;;       :config
;;       (progn
;;         (spacemacs/ensime-configure-keybindings 'java-mode)))))

(defun java/post-init-flycheck ()
  (spacemacs/add-flycheck-hook 'java-mode)
  (add-hook 'java-mode-local-vars-hook #'spacemacs//java-setup-syntax-checking))

(defun java/post-init-flyspell ()
  (spell-checking/add-flyspell-hook 'java-mode)
  (add-hook 'java-mode-local-vars-hook #'spacemacs//java-setup-spell-checking))

(defun java/post-init-ggtags ()
  (add-hook 'java-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun java/init-gradle-mode ()
  (use-package gradle-mode
    :defer t
    ))

(defun java/init-groovy-imports ()
  (use-package groovy-imports
    :defer t
    ))

(defun java/init-groovy-mode ()
  (use-package groovy-mode
    :defer t
    ))

(defun java/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'java-mode))

(defun java/init-java-mode ()
  (use-package java-mode
    :defer t
    :init
    (progn
      (add-hook 'java-mode-local-vars-hook #'spacemacs//java-setup-backend)
      (spacemacs//java-define-command-prefixes))))

(defun java/init-meghanada ()
  (use-package meghanada
    :defer t
    :init
    (progn
      (setq meghanada-server-install-dir (concat spacemacs-cache-directory
                                                 "meghanada/")
            ;; let spacemacs handle company and flycheck itself
            company-meghanada-prefix-length 1
            meghanada-use-company nil
            meghanada-use-flycheck nil))))
