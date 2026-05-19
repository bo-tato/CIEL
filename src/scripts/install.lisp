
(in-package :ciel-user)

(defun quickload (s)
  (ql:quickload s))

#+ciel
(let ((system (second ciel-user::*script-args*)))
  (and
   (quickload system)
   (format t "~&System ~a installed in ~a ✓

Next, load it in the REPL with (ql:quickload \"~a\")~&"
           system
           (first ql:*local-project-directories*)
           system)))
