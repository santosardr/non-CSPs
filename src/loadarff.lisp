(defun string-empty-p (string)
  (zerop (length string)))
(defun split-sequence (separator sequence &optional remove-empty-subseqs)
  (let* ((result)
		(start 0)
		(end (position separator sequence :start start)))
	(loop while end do
		(push (subseq sequence start end) result)
		(setf start (1+ end))
		(setf end (position separator sequence :start start)))
	(push (subseq sequence start) result)
	(if remove-empty-subseqs
		(remove-if #'string-empty-p (reverse result))
	(reverse result))))

(defun read-arff-file (file-path)
  (with-open-file (file file-path :direction :input)
		(let* ((lines (loop for line = (read-line file nil)
					while line
					collect line))
			(data-start-index (position "@data" lines :test #'string=))
			(relation_csv (subseq (first lines) 1))
			(relation (cadr (split-sequence #\Space relation_csv)))
			(attributes_csv (subseq lines 1 data-start-index))
			
			(classes (reduce #'append  (mapcar (lambda (attribute)
								(let* ((start-index (position #\{ attribute))
									(end-index (position #\} attribute :from-end t))
									(values (subseq attribute (1+ start-index) end-index)))
								(split-sequence #\, values)))
								(last attributes_csv))))
			
                        (attributes (remove-if #'null (mapcar (lambda (att)
								(multiple-value-bind (text success)
										     (ignore-errors (read-from-string 
												     (cadr (split-sequence #\Space att))
												     );read
												    );ignore
										     (if success text 0)
										     );multiple
								);lambda
							      (butlast attributes_csv)
							      );mapcar
					       );remove
				    );attributes
			(data_csv (subseq lines (1+ data-start-index)))
			(data (mapcar (lambda (oneline)
					(butlast (mapcar (lambda (text) 
							(multiple-value-bind (number success) 
										(ignore-errors (read-from-string text)) 
										(if success number 0)))
							(split-sequence #\, oneline)))) 
				data_csv)
			)
			
			(states (reduce #'append  (mapcar (lambda (oneline)
							(last (mapcar (lambda (text) 
									(multiple-value-bind (number success) 
												(ignore-errors (read-from-string text)) 
												(if success number 0)))
									(split-sequence #\, oneline)))) 
							data_csv)
					)
				)
			);let*

			(list :relation relation
			:attributes attributes
			:data data
			:states states
			:classes classes))))

(defvar file-path "data/src/myids-filter5-89-93-90-a.arff")
(defvar arff-data (read-arff-file file-path))

;; Process the ARFF data
(format t "Relation: ~a~%" (getf arff-data :relation))
(format t "Attributes: ~a~%" (getf arff-data :attributes))
;(format t "Data: ~a~%" (getf arff-data :data))
(format t "States: ~a~%" (getf arff-data :states))
(format t "Classes: ~a~%" (getf arff-data :classes))
