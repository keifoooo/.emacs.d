;;auto-installによってインストールされるEmacs Lispをロードパスに加える
;;デフォルトは ~/.emacs.d/auto-install/
(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(require `auto-install)
;;起動時にEmacsWiKiのページ名を補完候補に加える
(auto-install-update-emacswiki-package-name t)
;;install-elisp.el互換モードにする
(auto-install-compatibility-setup)
;;ediff関連のバッファを１つのフレームにまとめる
(setq ediff-window-setup-function `ediff-setup-window-plain)

(require `auto-async-byte-compile)
;;自動でバイトコンパイルを無効にするファイル名の正規表現
(setq auto-async-byte-compile-exclude-files-regexp "/junk/")
(add-hook `emacs-lisp-mode-hock `enable-auto-async-byte-compile-mode)


;;; js2-mode
(autoload 'js2-mode "js2" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

; fixing indentation
; refer to http://mihai.bazon.net/projects/editing-javascript-with-emacs-js2-mode
(autoload 'espresso-mode "espresso")

(defun my-js2-indent-function ()
  (interactive)
  (save-restriction
    (widen)
    (let* ((inhibit-point-motion-hooks t)
           (parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (espresso--proper-indentation parse-status))
           node)

      (save-excursion

        ;; I like to indent case and labels to half of the tab width
        (back-to-indentation)
        (if (looking-at "case\\s-")
            (setq indentation (+ indentation (/ espresso-indent-level 2))))

        ;; consecutive declarations in a var statement are nice if
        ;; properly aligned, i.e:
        ;;
        ;; var foo = "bar",
        ;;     bar = "foo";
        (setq node (js2-node-at-point))
        (when (and node
                   (= js2-NAME (js2-node-type node))
                   (= js2-VAR (js2-node-type (js2-node-parent node))))
          (setq indentation (+ 4 indentation))))

      (indent-line-to indentation)
      (when (> offset 0) (forward-char offset)))))

(defun my-indent-sexp ()
  (interactive)
  (save-restriction
    (save-excursion
      (widen)
      (let* ((inhibit-point-motion-hooks t)
             (parse-status (syntax-ppss (point)))
             (beg (nth 1 parse-status))
             (end-marker (make-marker))
             (end (progn (goto-char beg) (forward-list) (point)))
             (ovl (make-overlay beg end)))
        (set-marker end-marker end)
        (overlay-put ovl 'face 'highlight)
        (goto-char beg)
        (while (< (point) (marker-position end-marker))
          ;; don't reindent blank lines so we don't set the "buffer
          ;; modified" property for nothing
          (beginning-of-line)
          (unless (looking-at "\\s-*$")
            (indent-according-to-mode))
          (forward-line))
        (run-with-timer 0.5 nil '(lambda(ovl)
                                   (delete-overlay ovl)) ovl)))))

(defun my-js2-mode-hook ()
  (require 'espresso)
  (setq espresso-indent-level 4
        indent-tabs-mode nil
        c-basic-offset 4)
  (c-toggle-auto-state 0)
  (c-toggle-hungry-state 1)
  (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
  ; (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
  (define-key js2-mode-map "\C-\M-\\"
    '(lambda()
       (interactive)
       (insert "/* -----[ ")
       (save-excursion
         (insert " ]----- */"))
       ))
  (define-key js2-mode-map "\C-m" 'newline-and-indent)
  ; (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
  ; (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
  (define-key js2-mode-map "\C-\M-q" 'my-indent-sexp)
  (if (featurep 'js2-highlight-vars)
      (js2-highlight-vars-mode))
  (message "My JS2 hook"))


;;; ウィンドウの色
(set-background-color "Black")
(set-foreground-color "White")
(set-cursor-color "Gray")
(add-to-list 'default-frame-alist '(alpha . 92))

; 言語を日本語にする
(set-language-environment 'Japanese)
; 極力UTF-8とする
(prefer-coding-system 'utf-8)
;;;現在行に色を付ける
(global-hl-line-mode 1)
;;色
(set-face-background 'hl-line "darkolivegreen")
;;;履歴を次回emacs起動時にも保存する
(savehist-mode 1)
;;;ファイル内カーソル位置を記憶する
(setq-default save-place t)
(require 'saveplace)
;;;対応する括弧を表示させる
(show-paren-mode 1)
;;;シェルに合わせる為にC-hは後退に割り当てる
;;;ヘルプは<f1>も使えるので本書では、<f1>と書いている
(global-set-key (kbd "C-h") 'delete-backward-char)
;;;モードラインに時刻を表示させる
(display-time)
;;;行番号、桁番号を表示させる
(line-number-mode 1)
(column-number-mode 1)
;;;GCを減らして軽くする(デフォルトの10倍)
;;;現在のマシンパワーではもっと大きくしたい
(setq gc-cons-threshold (* 10 gc-cons-threshold))
;;;ログの行数を増やす
(setq message-log-max 10000)
;;;ミニバッファを再起的に呼び出せるようにする
(setq enable-recursive-minibuffers t)
;;;ダイアログボックスを使わないようにする
(setq use-dialog-box nil)
(defalias 'message-box 'message)
;;;履歴をたくさん保存する
(setq history-length 1000)
;;;キーストロークをエコーエリアに早く表示する
(setq echo-keystrokes 0.1)
;;;大きいファイルを開こうとしたときに警告を発生させる
;;;デフォルトは10Mなので25Mに拡張する
(setq large-file-warning-threshold (* 25 1024 1024))
;;;ミニバッファで入力を取り消ししても履歴にのこす
;;;誤って取り消し入力が失われるのを防ぐ為
(defadvice abort-recursive-edit (before minibuffer-save activate)
  (when (eq (selected-window) (active-minibuffer-window))
    (add-to-history minibuffer-history-variable (minibuffer-contents))))
;;;yes と入力するのは面倒なのでyで十分
(defalias 'yes-or-no-p 'y-or-n-p)
;;;ツールバーとスクーロルバーを消す
;(tool-bar-mode 0)
;(set-scroll-bar-mode nil)
;;; カーソルの点滅
(blink-cursor-mode t)
;;フォント
;(create-fontset-from-ascii-font "Menlo-14:weight=normal:slant=normal" nil "menlokakugo")
;(set-fontset-font "fontset-menlokakugo"
;                  'unicode
;                  (font-spec :family "Hiragino Kaku Gothic ProN" :size 16)
;                  nil
;                  'append)
;(add-to-list 'default-frame-alist '(font . "fontset-menlokakugo"))
