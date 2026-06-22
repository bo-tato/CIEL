;;; description: install Quicklisp with HTTPS via curl.

(in-package :ciel-user)

(defparameter *setup-for-init-file* ";;; The following lines were added when you installed Quicklisp with ciel -s install-quicklisp.
;;; This loads Quicklisp when you start CIEL, so you can use Quicklip straight away.
#-quicklisp
(let ((quicklisp-init (merge-pathnames \"quicklisp/setup.lisp\"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))
")

(defun install-ql-with-https ()
  "Call out to cURL to install Quicklisp."
  (uiop:run-program ciel::*ql-https-install.sh*
                    :output t
                    :error-output t))

(defun add-to-init-file (file &key (snippet *setup-for-init-file*))
  (with-open-file (stream (uiop:native-namestring file)
                        :direction :output
                        :if-exists :append)
    (format stream "~%~a~%" snippet)))

(defun add-to-cielrc ()
  ;; (load (make-string-input-stream ciel::*quicklisp.lisp*))
  (handler-case
      (add-to-init-file "~/.cielrc")
    (error (c)
      (format *error-output* "~&Error while adding Quicklisp setup to ~~/.cielrc: ~a~&" c))))


#+(and ciel unix)
(progn

  ;; Install.
  (ignore-errors
   ;; We get the script's error output,
   ;; and run-program would print the whole script content to say it exited with an error code.
   (install-ql-with-https)

   ;; Configure.
   (add-to-cielrc)))

#+(and ciel windows)
(error "We currently use a shell script to install ql-https. Feel free to open an issue.")
