(defsystem "lisp-cli"
    :description "My test code for Nix package manager and SBCL, to create CLI App"
    :version "0.1.0"
    :author "haruki7049"
    :license "MIT"
    :depends-on ("clingon")
    :components ((:module "src"
                          :components
                          ((:file "lisp-cli")))))
