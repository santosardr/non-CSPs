;; Define rótulos para cada elemento da matriz de dados
(defparameter *target* (make-array 11 :element-type 'fixnum :initial-contents '(0 0 1 1 1 1 1 3 3 3 3)))

;; Define a matriz de dados como um vetor de duas dimensões
(defparameter *datamatrix* (make-array '(11 2) :element-type 'single-float :initial-contents '((-1.0 -2.0) (-2.0 -1.5) (1.0 -2.0) (3.0 -1.5) (-2.0 2.0) (-3.0 1.0) (-2.0 1.0) (3.0 2.0) (2.0 2.0) (1.0 2.0) (1.0 1.0))))

(defparameter *otherdatamatrix* (make-array '(4 2) :element-type 'single-float :initial-contents '((-0.5 0.0) (2.0 -1.5) (-1.0 -4.0) (4.0 5.0))))

;; Define o número de classes
(defparameter *n-class* 4)

;; Construi uma árvore de decisão utilizando a matriz de dados e os rótulos (aprendizado supervisionado)
(defparameter *dtree* (CL-RANDOM-FOREST::make-dtree *n-class* *datamatrix* *target* :max-depth 5 :min-region-samples 1 :n-trial 10))

;; Testa a posição zero da matriz de dados de acordo com a árvore treinada. Não há como errar!
(CL-RANDOM-FOREST::predict-dtree *dtree* *datamatrix* 0)

;; Testa toda a matriz de dados de acordo com a árvore treinada. Não há como errar também!
(CL-RANDOM-FOREST::test-dtree *dtree* *datamatrix* *target*)

;; Constroi uma floresta randômica usando a matriz de dados e os rótulos como dados de treinamento
(defparameter *forest* (CL-RANDOM-FOREST::make-forest *n-class* *datamatrix* *target* :n-tree 10 :bagging-ratio 1.0 :max-depth 5 :min-region-samples 1 :n-trial 10))

;; Testa a posição zero da matriz de dados de acordo com a floresta treinada. Não há como errar!
(CL-RANDOM-FOREST::predict-forest *forest* *datamatrix* 0)

;; Testa toda a matriz de dados de acordo com a floresta treinada. Não há como errar também!
(CL-RANDOM-FOREST::test-forest *forest* *datamatrix* *target*)

;; Criei outra matriz de dados incluindo uma terceira dimensão.
(defparameter *datamatrix3* (make-array '(11 3) :element-type 'single-float :initial-contents '((-1.0 -2.0 0.0) (-2.0 -1.5 2.1) (1.0 -2.0 1.4) (3.0 -1.5 4.3) (-2.0 2.0 3.0) (-3.0 1.0 5.9) (-2.0 1.0 10.1) (3.0 2.0 -2.3) (2.0 2.0 3.3) (1.0 2.0 1.9) (1.0 1.0 4.5))))

;; Cria outra árvore para 3d
(defparameter *dtree* (CL-RANDOM-FOREST::make-dtree *n-class* *datamatrix3* *target* :max-depth 5 :min-region-samples 1 :n-trial 10))

;; Cria outra floresta para 3d
(defparameter *forest* (CL-RANDOM-FOREST::make-forest *n-class* *datamatrix3* *target* :n-tree 10 :bagging-ratio 1.0 :max-depth 5 :min-region-samples 1 :n-trial 10))

;; Novos testes com esta árvore e floresta também não erram porque basta as coordenadas x e y para identificar corretamente cada ponto.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;        Agora com meus dados
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rlwrap sbcl --load loadarff.lisp
(require :cl-random-forest)
(defvar arff-data (read-arff-file file-path))

;; Rotulos dos dados de treinamento
(defparameter *target* (make-array (length (getf arff-data :states_num)) 
	:element-type 'fixnum :initial-contents (getf arff-data :states_num)))

;; Define a matriz de dados como uma matriz de 140 dimensões e milhares de dados
(defparameter *datamatrix* (make-array (list (length (getf arff-data :states_num))  (length (getf arff-data :attributes)) ) 
	:element-type 'single-float :initial-contents (getf arff-data :data) ))

;; Define o número de classes: (SECRETED NON-SECRETED)
(defparameter *n-class* 2)

;; Construi uma árvore de decisão utilizando a matriz de dados e os rótulos (aprendizado supervisionado)
(defparameter *dtree* (CL-RANDOM-FOREST::make-dtree *n-class* *datamatrix* *target* :max-depth 5 :min-region-samples 1 :n-trial 10))
;; Testa toda a matriz de dados de acordo com a árvore treinada. Não há como errar também!
(CL-RANDOM-FOREST::test-dtree *dtree* *datamatrix* *target*)

;; Constroi uma floresta randômica usando a matriz de dados e os rótulos como dados de treinamento
(defparameter *forest* (CL-RANDOM-FOREST::make-forest *n-class* *datamatrix* *target* :n-tree 10 :bagging-ratio 1.0 :max-depth 5 :min-region-samples 1 :n-trial 10))
;; Testa toda a matriz de dados de acordo com a floresta treinada. Não há como errar também!
(CL-RANDOM-FOREST::test-forest *forest* *datamatrix* *target*)

;; Ler um arquivo de testes:
(defvar arff-test (read-arff-file "data/validation1.arff"))

;; Este arquivo não possui rótulos porque foi feito para testes. Rótulo será informado manualmente
;; considerando a posição de cada dado: 1-92:1=NON-SECRETED e 93-106:0=SECRETED
(defparameter *testtarget* (make-array 106 :element-type 'fixnum 
	:initial-contents (append (make-list 92 :initial-element 1) (make-list (- 106 92) :initial-element 0))))
	
;; Define a matriz de dados como uma matriz de 140 dimensões e 106 casos de testes
(defparameter *testmatrix* (make-array (list (length (getf arff-test :states_num))  (length (getf arff-test :attributes)) ) 
	:element-type 'single-float :initial-contents (getf arff-test :data) ))	

;; Testa toda a matriz de testes de acordo com a floresta treinada.
(CL-RANDOM-FOREST::test-forest *forest* *testmatrix* *testtarget*)


;; Ler outro arquivo de testes:
(defvar arff-test (read-arff-file "data/validation2.arff"))

;; Este arquivo não possui rótulos porque foi feito para testes. Rótulo será informado manualmente
;; considerando a posição de cada dado: 1-34:1=NON-SECRETED e 35-68:0=SECRETED
(defparameter *testtarget* (make-array 68 :element-type 'fixnum 
	:initial-contents (append (make-list 34 :initial-element 1) (make-list 34 :initial-element 0))))
	
;; Define a matriz de dados como uma matriz de 140 dimensões e 68 casos de testes
(defparameter *testmatrix* (make-array (list (length (getf arff-test :states_num))  (length (getf arff-test :attributes)) ) 
	:element-type 'single-float :initial-contents (getf arff-test :data) ))	

;; Testa toda a matriz de testes de acordo com a floresta treinada.
(CL-RANDOM-FOREST::test-forest *forest* *testmatrix* *testtarget*)

