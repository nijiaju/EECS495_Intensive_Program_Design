;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW3-1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Exercise 309

(define-struct no-info [])
(define NONE (make-no-info))
(define-struct node [ssn name left right])

;; A BinaryTree (BT) is one of:
;; - NONE
;; - (make-node Number Symbol BT BT)
(define BT1 (make-node 15 'd NONE (make-node 24 'i NONE NONE)))
(define BT2 (make-node 15 'd (make-node 87 'h NONE NONE) NONE))

;; A SearchResult is either:
;; - Symbol
;; - #false

;; Number BT -> SearchResult
;; If the tree contains a node structure whose ssn field is n,
;; the function returns the value of the name field in that node.
;; Otherwise, the function produces #false.
;; 
;; Examples:
;;  - given: 15 BT1, returns: 'd
;;  - given: 16 BT1, returns: #f
;;
;; Stragety: template for BT (structural decomposition)
;; Template:
#;
(define (process-bt a-bt ...)
  (cond
    [(no-info? a-bt) ...]
    [(node? a-bt)
     ... (node-ssn a-bt) ...
     ... (node-name a-bt) ...
     ... (process-bt (node-left a-bt) ...) ...
     ... (process-bt (node-right a-bt) ...) ...]))

(define (search-bt n a-bt)
  (cond
    [(no-info? a-bt) #f]
    [(node? a-bt)
     (cond
       [(= n (node-ssn a-bt)) (node-name a-bt)]
       [(symbol? (search-bt n (node-left a-bt)))
        (search-bt n (node-left a-bt))]
       [(symbol? (search-bt n (node-right a-bt)))
        (search-bt n (node-right a-bt))]
       [else #f])]))

(check-expect (search-bt 15 BT1) 'd)
(check-expect (search-bt 16 BT1) #f)
(check-expect (search-bt 87 BT2) 'h)
(check-expect (search-bt 24 BT1) 'i)

;; Exercise 310

(define BT3 (make-node 63 'node1
                        (make-node 29 'node2
                                   (make-node 15 'node3
                                              (make-node 10 'node4 NONE NONE)
                                              (make-node 24 'node5 NONE NONE))
                                   NONE)
                        (make-node 89 'node6
                                   (make-node 77 'node7 NONE NONE)
                                   (make-node 95 'node8
                                              NONE
                                              (make-node 99 'node9 NONE NONE)))))
;; BT -> ListOfNumber
;; Interpretation: a ListOfNumber is one of
;;  - '()
;;  - (cons Number ListOfNumber)
;; inorder traverse of a BT and prints all the ssn numbers
;;
;; Examples:
;; - given BST1, returns (list 10 15 24 29 63 77 89 95 99)
;;
;; Strategy: template for BT
(define (inorder a-bt)
  (cond
    [(no-info? a-bt) '()]
    [(node? a-bt) (append (inorder (node-left a-bt))
                          (list (node-ssn a-bt))
                          (inorder (node-right a-bt)))]))

(check-expect (inorder BT3) (list 10 15 24 29 63 77 89 95 99))

;; Exercise 311

;; A BinarySearchTree (BST) is one of:
;; - NONE
;; - (make-node ssn Symbol left right)
;; ssn is a Number, left and right are BSTs
;; all ssn fields in left contain numbers that are smaller than ssn
;; all ssn fields in right contain numbers that are bigger than ssn
(define BST1 (make-node 63 'node1
                        (make-node 29 'node2
                                   (make-node 15 'node3
                                              (make-node 10 'node4 NONE NONE)
                                              (make-node 24 'node5 NONE NONE))
                                   NONE)
                        (make-node 89 'node6
                                   (make-node 77 'node7 NONE NONE)
                                   (make-node 95 'node8
                                              NONE
                                              (make-node 99 'node9 NONE NONE)))))

;; A BSTSearchResult is either:
;; - NONE
;; - Symbol
;; Number BST -> BSTSearchResult
;; If the BST contains a node structure whose ssn field is n,
;; the function produces the value of the name field in that node.
;; Otherwise, the function produces NONE.
;;
;; Example:
;; - given: BST1 15, returns: 'node3
;; - given: BST1 100, returns: NONE
;;
;; Stragety: Template for BST
#;
(define (process-bst a-bst ...)
  (cond
    [(no-infor? a-bst) ...]
    [(node? a-bst)
    ... (node-name a-bst) ...
    ... (node-ssn a-bst) ...
    ... (procecss-bst (node-left a-bst) ...) ...
    ... (procecss-bst (node-right a-bst) ...) ...]))
         
(define (search-bst n a-bst)
  (cond
    [(no-info? a-bst) a-bst]
    [(node? a-bst)
     (cond
       [(= n (node-ssn a-bst)) (node-name a-bst)]
       [(< n (node-ssn a-bst)) (search-bst n (node-left a-bst))]
       [(> n (node-ssn a-bst)) (search-bst n (node-right a-bst))])]))

(check-expect (search-bst 15 BST1) 'node3)
(check-expect (search-bst 99 BST1) 'node9)
(check-expect (search-bst 100 BST1) NONE)

;; Exercise 312

(define BST2 (make-node 63 'node1
                        (make-node 29 'node2
                                   (make-node 15 'node3
                                              (make-node 10 'node4 NONE NONE)
                                              (make-node 24 'node5 NONE NONE))
                                   (make-node 30 'node10 NONE NONE))
                        (make-node 89 'node6
                                   (make-node 77 'node7 NONE NONE)
                                   (make-node 95 'node8
                                              NONE
                                              (make-node 99 'node9 NONE NONE)))))

;; BST Number Symbol -> BST
;; insert a node into the BST hence create a new BST
;;
;; Examples:
;; - given: (create-bst NONE 63 'node1)
;;   returns: (make-node 63 'node1 NONE NONE)
;; - given: (create-bst (create-bst NONE 63 'node1) 29 'node2)
;;   returns: (make-node 63 'node1 (make-node 29 'node2 NONE NONE) NONE)
;;
;; Strategy: template for BST
(define (create-bst a-bst a-ssn a-name)
  (cond
    [(no-info? a-bst) (make-node a-ssn a-name NONE NONE)]
    [(> (node-ssn a-bst) a-ssn)
     (update-node a-bst a-ssn a-name #t)]
    [(< (node-ssn a-bst) a-ssn)
     (update-node a-bst a-ssn a-name #f)]
    [(and (= (node-ssn a-bst) a-ssn)
          (symbol=? (node-name a-bst) a-name))
     a-bst]
    [else (error "invalid insert")]))

;; BST Number Symbol Boolean -> BST
;; updates a node structure
;; Stragety: Domain knowledge (BST)
(define (update-node a-node a-ssn a-name left?)
  (make-node
   (node-ssn a-node)
   (node-name a-node)
   (if (boolean=? left? #t)
       (create-bst (node-left a-node) a-ssn a-name)
       (node-left a-node))
   (if (boolean=? left? #t)
       (node-right a-node)
       (create-bst (node-right a-node) a-ssn a-name))))

(check-expect (create-bst NONE 63 'node1) (make-node 63 'node1 NONE NONE))
(check-expect (create-bst BST1 30 'node10) BST2)
(check-expect (create-bst BST1 29 'node2) BST1)
(check-error (create-bst BST1 29 'node3) "invalid insert")

;; Exercise 313

;; [Listof list] -> BST
;; consumes a list of numbers and names and produces a binary search tree
;;
;; Example:
;;  - given: '()
;;  - returns: NONE
;;  - given: '((99 'node1) (77 'node2))
;;  - returns: (make-node 99 'node1 (make-node 77 'node2 NONE NONE) NONE)
;;
;; Stragety: function composotion
(define (create-bst-from-list lol)
  (cond
    [(empty? lol) NONE]
    [else (create-bst (create-bst-from-list (rest lol))
                      (first (first lol))
                      (second (first lol)))]))

(check-expect (create-bst-from-list '()) NONE)
(check-expect (create-bst-from-list(list (list 99 'node9)
                                         (list 77 'node7)
                                         (list 24 'node5)
                                         (list 10 'node4)
                                         (list 95 'node8)
                                         (list 15 'node3)
                                         (list 89 'node6)
                                         (list 29 'node2)
                                         (list 63 'node1)))
              BST1)