;;; description: turn a script file into a CIEL-based binary.
;;; usage: ciel -s embed script.lisp -o output

(in-package :ciel-user)

(defun embed (file &key output)
  (setf ciel::*entrypoint-script* (str:from-file file))
  (when (str:blankp output)
    (format *error-output* "~&Please give the output file with -o output.~&"))
  (format t "~&Building ~a as a CIEL binary to ~a…~&" file output)

  (let ((cmd (list
              'sb-ext:save-lisp-and-die
              output
              :executable t
              :toplevel #'ciel::main
              ;; :compression 9  ;; this runtime was not built with zstd support (?)
              )))
    (handler-case
        ;; (asdf:make :ciel/repl)  ;; we don't control the output file name.
        (eval cmd)
      (error (c)
        (format *error-output* "Error embedding script: ~s" c)))))


;; When calling
;;
;; ciel -s embed hello.lisp -o hello
;;
;; args are:
;;
;;("embed" "hello.lisp" "-o" "hello")

#+ciel
(embed (second ciel-user::*script-args*) :output (fourth ciel-user::*script-args*))
