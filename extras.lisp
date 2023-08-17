(in-package :ciel)

(named-readtables:defreadtable
    :syntax-sugar
  (:merge
   ;; some convenient reader macros for currying and composition
   ;; see: https://eschulte.github.io/curry-compose-reader-macros
   :curry-compose-reader-macros
   ;; string interpolation and regex literals
   ;; see: http://edicl.github.io/cl-interpol/
   :interpol-syntax))
(cl-reexport:reexport-from :curry-compose-reader-macros)

;; reexport common library functions
(cl-reexport:reexport-from :serapeum
                           :include
                           '(:drop-while
                             :take-while))

;; utility functions
(defun drop-until (pred-or-item seq)
  "When passed a function, drop from sequence until the PRED returns true.
When passed any other value, drop from sequence until finding something equal to ITEM"
  (let ((pred (if (functionp pred-or-val)
                  pred-or-val
                  (lambda (x) (equal x pred-or-val)))))
    (serapeum:drop-while (complement pred) seq)))

(defun take-until (pred-or-item seq)
  "When passed a function, take from sequence until the PRED returns true.
When passed any other value, take from sequence until finding something equal to ITEM"
  (let ((pred (if (functionp pred-or-val)
                  pred-or-val
                  (lambda (x) (equal x pred-or-val)))))
    (serapeum:take-while (complement pred) seq)))
