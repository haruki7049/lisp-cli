(in-package :cl-user)
(defpackage lisp-cli
  (:use :cl
        :clingon)
  (:export :main))
(in-package :lisp-cli)

(defun main ()
  (write-line "Hell, CommonLisp..."))
