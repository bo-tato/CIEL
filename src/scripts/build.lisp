;;; description: build an executable for the current project.
;;; usage: ciel -s build system package::main
;;;
;;; next: we could make the 2 CLI args optional, if we ensure the project follows our convention:
;;; - system name = project name
;;; - system name = names a package
;;; - there is a "main" function in the package.
;;;
;;; How to ensure?
;;; - create project skeletons with a marker.
;;; - or be clever and parse lisp forms.

(defun find-asds ()
  "return: list of strings, full pathnames."
  (mapcar #'uiop:native-namestring
          (directory #P"*.asd")))

(defun sort-asds (asds)
  "Hopefully put the real .asd first, the -test.asd last."
  (sort (copy-seq asds) #'string>=))

(defun load-asds (asds)
  "Load this list of asd files in the current image, with asdf:load-asd."
  (loop for asd in asds
        do (asdf:load-asd asd)))

(defun quickload-project (system)
  (ql:quickload system))

(defun symbolicate-entry-point (s)
  "From pack::main, create a symbol MAIN in package PACK, so we can reference that function in the save-lisp-and-die form."
  (destructuring-bind (package fn)
      (str:split ":" s :omit-nulls t)
    (intern
     (str:upcase fn)
     (find-package (make-symbol (str:upcase package))))))

(defun save-lisp (target entry-point)
  (let ((cmd `(sb-ext:save-lisp-and-die
               ,target
               :executable t
               :toplevel (symbolicate-entry-point ,entry-point)
               ;; :compression 9  ;; this runtime was not built with zstd support (?)
               )))
    (format t "~&Building executable to ~a with entry point ~a…~&" target entry-point)
    (uiop:format! t "~s" cmd)
    (handler-case
        (eval cmd)
      (error (c)
        (format *error-output* "error building project:~& ~s" c)))))

(defun build (target entry-point &aux asds)
  "target: both the system name (as per the .asd defsystem) and the executable name to be created."
  (format t "~&Looking for .asd file(s)…")
  (setf asds (sort-asds (find-asds)))
  (format t "~&Found: ~a~&" asds)
  (unless asds
    (format t "~&Nothing found. Nothing to do.~&")
    (return-from build))

  (format t "~&Loading the .asd files…~&")
  (load-asds asds)

  (format t "~&Loading the projet…~&")
  (quickload-project target)

  (format t "~&Saving the core executable…~&")
  (save-lisp target entry-point)

  (format t "~&All done ✓~&")
  )


#+ciel
(build (second ciel-user::*script-args*) (third ciel-user::*script-args*))
