;; Load necessary libraries
(require :cl-random-forest)
(load "./loadarff.lisp")

(defun main()
  (let ( (DATAMATRIX) (FOREST) (N-CLASS) (TARGET) (TESTMATRIX) (ACCURACY) (CONFUSION) (FN) (FP) (NEGATIVE-LIMIT) (SENSITIVITY)
	 (SPECIFICITY) (TEST-DATA) (TEST-FILE) (TN) (TP) (TRAIN-DATA) (TRAIN-FILE) (Y-PRED) )
  ;; Read the training ARFF file
  (setf train-file (nth 1 sb-ext:*posix-argv*))
  (setf train-data (read-arff-file train-file ))
  ;; Separate the features (attributes) and the labels

  (setf target (make-array (length
				      (getf train-data :states_num))
				     :element-type 'fixnum
				     :initial-contents (getf train-data :states_num)))

  (setf datamatrix (make-array (list
					  (length (getf train-data :states_num));lines
					  (length (getf train-data :attributes));columns
					  ) 
					 :element-type 'single-float
					 :initial-contents (getf train-data :data) ))

  (setf n-class (length (getf train-data :classes)))

  (setf forest (CL-RANDOM-FOREST::make-forest
			  n-class
			  datamatrix
			  target
			  :n-tree 500
			  :bagging-ratio 1.0
			  :max-depth (truncate (/ (+ 1 (length (getf train-data :attributes))) 2))
			  :min-region-samples 1
			  :n-trial 10))

  ;; Read the limits for NEGATIVE and POSITIVE
  (setf negative-limit (parse-integer (nth 3 sb-ext:*posix-argv*)))

  ;; Read the testing ARFF file
  (setf test-file (nth 2 sb-ext:*posix-argv*))
  (setf test-data (read-arff-file test-file ))

  (setf testmatrix (make-array
			      (list (length (getf test-data :states_num))
				    (length (getf test-data :attributes))
				    )
			      :element-type 'single-float
			      :initial-contents (getf test-data :data) ))

  ;; Predict the labels for the testing data
  (setf y-pred (loop for i from 0 to (- (length (getf test-data :states_num)) 1)
		       collect (CL-RANDOM-FOREST::predict-forest forest testmatrix i)))

  ;; Initialize the confusion matrix
  (setf confusion (list (list 0 0) (list 0 0)))

  ;; Compare the predicted labels with the actual labels and increment the confusion matrix accordingly
  (loop for i below (length y-pred) do
	(if (< i negative-limit)
	    (if (= (nth i y-pred) (position 'NON-SECRETED (getf test-data :classes)) )
		(incf (first (first confusion))) ; True Negative (NEGATIVE predicted correctly)
	      (incf (second (first confusion)))) ; False Positive (POSITIVE predicted incorrectly)
	  (if (= (nth i y-pred) (position 'SECRETED (getf test-data :classes)))
	      (incf (second (second confusion))) ; True Positive (POSITIVE predicted correctly)
	    (incf (first (second confusion)))))) ; False Negative (NEGATIVE predicted incorrectly)

  ;; Extract the true positives (TP), false negatives (FN), true negatives (TN), and false positives (FP) from the confusion matrix
  (setf tp (second (second confusion)))
  (setf fn (second (first confusion)))
  (setf tn (first (first confusion)))
  (setf fp (first (second confusion)))

  ;; Calculate the sensitivity and specificity
  (setf sensitivity (if (= (+ tp fn) 0) 0 (/ tp (+ tp fp))))
  (setf specificity (/ tn (+ tn fn)))

  ;; Calculate the accuracy
  (setf accuracy (/ (+ tp tn) (+ tp tn fp fn)))

  ;; Print the confusion matrix
  (format t "~%Confusion Matrix:~%")
  (format t "  a b      classified as~%")
  (format t " ~a ~a a = NEGATIVE~%" (first (first confusion)) (second (first confusion)))
  (format t " ~a ~a b = POSITIVE~%~%" (first (second confusion)) (second (second confusion)))

  ;; Print the variables involved for debugging
  (format t "True Positives:~t~a~%" tp)
  (format t "False Positives:~t~a~%" fp)
  (format t "True Negatives:~t~a~%" tn)  
  (format t "False Negatives:~t~a~%~%" fn)



  ;; Print the sensitivity, specificity, and accuracy
  (format t "Sensitivity: ~a~%" (float sensitivity))
  (format t "Specificity: ~a~%" (float specificity))
  (format t "Accuracy: ~a~%" (float accuracy))
  )
)
