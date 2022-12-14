# Scripting

> Note: this is brand new! Expect limitations and changes.

Get the `ciel` binary and call it with a .lisp file:

```
$ ciel script.lisp
```

An example script:

```lisp
;; Start your script with this to access all CIEL goodies:
(in-package :ciel-user)

(defun hello (name)
  "Say hello."
  ;; format! prints on standard output and flushes the streams.
  (format! t "Hello ~a!~&" name))

;; Access CLI args:
(hello (second (uiop:command-line-arguments)))

;; We have access to the DICT notation for hash-tables:
(print "testing dict:")
(print (dict :a 1 :b 2))

;; We can run shell commands:
(cmd:cmd "ls")

;; Access environment variables:
(hello (os:getenv "USER"))  ;; os is a nickname for uiop/os

(format! t "Let's define an alias to run shell commands with '!'. This gives: ")
(defalias ! #'cmd:cmd)
(! "pwd")

;; In cas of an error, we can ask for a CIEL toplevel REPL:
(handler-case
    (error "oh no")
  (error (c)
    (format! t "An error occured: ~a" c)
    (format! t "Here's a CIEL top level REPL: ")
    (sbcli::repl :noinform t)))
```

Output:


```
$ ciel script.lisp you
=>

Hello you!
"testing dict:"

 (dict
  :A 1
  :B 2
 )
cmd? ABOUT.org	    ciel		     ciel-core
   bin  		    docs		     src
 […]
Hello vindarel!
Let's define an alias to run shell commands with '!'. This gives:
/home/vindarel/projets/ciel
ciel-user>
```

## Command line arguments

Access them with `(uiop:command-line-arguments)`.


## Executable file and shebang line

We can also make a CIEL file executable and run it directly:

```
$ chmod +x script.lisp
$ ./script.lisp
```

Add the following shebang at the beginning:

```sh
#!/bin/sh
#|-*- mode:lisp -*-|#
#|
exec /path/to/ciel `basename $0` "$@"
|#

(in-package :ciel-user)
;; lisp code follows.
```

How it works:

- it starts as a /bin/sh script
  - all lines starting by `#` are shell comments
- the exec calls the `ciel` binary with this file name as first argument,
  the rest of the file (lisp code) is not read by the shell.
  - before LOAD-ing this Lisp file, we remove the #!/bin/sh shebang line.
  - Lisp ignores comments between `#|` and `|#` and runs the following lisp code.

## Eval and one-liners

Use `--eval` or `-e` to eval some lisp code.

Example:

```sh
$ ciel -e "(uiop:file-exists-p \"README.org\")"
/home/vindarel/projets/ciel/README.org

$ ciel -e "(-> \"README.org\" (uiop:file-exists-p))"
/home/vindarel/projets/ciel/README.org

$ ciel -e "(-> (http:get \"https://fakestoreapi.com/products/1\") (json:read-json))"

 (dict
  "id" 1
  "title" "Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops"
  "price" 109.95
  "description" "Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday"
  "category" "men's clothing"
  "image" "https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg"
  "rating"
  (dict
   "rate" 3.9
   "count" 120
  )
 )
```

## Other scripts

### Simple HTTP server

see `src/scripts/simpleHTTPserver.lisp` in the CIEL repository.

~~~lisp
(in-package :ciel-user)

;; CLI args: the script name, an optional port number.
(defparameter *port* (or (parse-integer (second (uiop:command-line-arguments)))
                         8000))

(defvar *acceptor* (make-instance 'hunchentoot:easy-acceptor
                     :document-root "./"
                     :port *port*))
(hunchentoot:start *acceptor*)  ;; async, runs in its own thread.

(format! t "~&Serving files on port ~a…~&" *port*)
(handler-case
    ;; The server runs on another thread, don't quit instantly.
    ;; Catch a C-c and quit gracefully.
    (sleep most-positive-fixnum)
  (sb-sys:interactive-interrupt ()
    (format! t "Bye!")))
~~~

Given you have an `index.html` file:

```html
<html>
  <head>
    <title>Hello!</title>
  </head>
  <body>
    <h1>Hello CIEL!</h1>
    <p>
    We just served our own files.
    </p>
  </body>
</html>
```

If you want to serve static assets under a `static/` directory:

~~~lisp
;; Serve static assets under static/
(push (hunchentoot:create-folder-dispatcher-and-handler
       "/static/"  "static/"  ;; starts without a /
       )
      hunchentoot:*dispatch-table*)
~~~

Now load a .js file as usual in your template:

        <script src="/static/ciel.js"></script>

which can be:

~~~javascript
// ciel.js
alert("hello CIEL!");
~~~

Example output:

```
$ ciel src/scripts/simpleHTTPserver.lisp 4444
Serving files on port 4444…
127.0.0.1 - [2022-12-14 12:06:00] "GET / HTTP/1.1" 200 200 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:103.0) Gecko/20100101 Firefox/103.0"
```

---

Now, let us iron out the details ;)