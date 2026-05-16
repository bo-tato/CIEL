
(in-package :ciel-user)

(defun install-quicklisp ()
  "Download Quicklisp's client source,
  run the quickstart,
  add the QL setup to the current user's init file (needs confirmation)."
  (load (make-string-input-stream ciel::*quicklisp.lisp*))
  (uiop:symbol-call 'quicklisp-quickstart 'install)
  (uiop:symbol-call 'ql 'add-to-init-file)
  )

(defun add-to-cielrc ()
  (uiop:symbol-call 'ql 'add-to-init-file "~/.cielrc"))

#+ciel
(progn
  (install-quicklisp)
  (add-to-cielrc)
  (uiop:quit))
