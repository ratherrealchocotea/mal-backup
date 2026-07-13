#!/usr/bin/sbcl --script

(load "~/.quicklisp/setup.lisp")
(ql:quickload :dexador)
(ql:quickload :cl-json)

(defpackage :mal-backup (:use :cl))
(in-package #:mal-backup)

(defun download-list (username client-id filename)
  (let ((saved '()))
    (let ((response (dex:get
                     (concatenate 'string
                                  "https://api.myanimelist.net/v2/users/"
                                  username
                                  ;; MAL only allows for 1000 anime per request
                                  ;; ...not that that would be a problem for
                                  ;; my purposes. Whatever...
                                  "/animelist?fields=list_status&limit=1000")
                     :headers `(("X-MAL-CLIENT-ID" . ,client-id)))))
      (let ((data (json:decode-json-from-string response)))
        (dolist (entry (cdr (assoc :data data)))
          (let ((status (cdr (assoc :status 
                                    (cdr (assoc :list--status entry))))))
            (when (string= "completed" status)
              (push (cdr (assoc :title (cdr (assoc :node entry)))) saved))))))
    (with-open-file (out filename :direction :output :if-exists :supersede)
      (dolist (title (nreverse saved))
        (format out "~a~%" title)))))

(let* ((args (cdr sb-ext:*posix-argv*))
       (username (first args))
       (client-id (second args))
       (filename (third args)))
       (if (and username client-id filename)
           (format t "Downloading list for ~a ~%" username)
           (download-list username client-id filename)))
