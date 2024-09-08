(in-package :cl-user)
(defpackage lisp-cli
  (:use :cl)
  (:import-from :clingon)
  (:export :main))
(in-package :lisp-cli)

(defun greet/options ()
  "Returns the options for the 'greet' command"
  (list
   (clingon:make-option
    :string
    :description "Person to greet"
    :short-name #\u
    :long-name "user"
    :initial-value "haruki7049"
    :env-vars '("USER")
    :key :user)))

(defun greet/handler (cmd)
  "Handler for the 'greet' command"
  (let ((who (clingon:getopt cmd :user)))
    (format t "Hello, ~A!~%" who)))

(defun greet/command ()
  "A command to greet someone"
  (clingon:make-command
   :name "greet"
   :description "greets people"
   :version "0.1.0"
   :authors '("haruki7049 <tontonkirikiri@gmail.com>")
   :license "MIT"
   :options (greet/options)
   :handler #'greet/handler))

(defun main ()
  "CLI application's entrypoint"
  (let ((app (greet/command)))
    (clingon:run app)))
