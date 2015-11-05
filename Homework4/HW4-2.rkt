;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname HW4-2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Balanced 2-3 tree

;; A [Bal23Node X] is one of:
;; - 'null
;; - (make-two-node X [Bal23Node X] [Bal23Node X])
;; - (make-three-node X X [Bal23Node X] [Bal23Node X] [Bal23Node X])
(define-struct two-node [key left right])
(define-struct three-node [s-key l-key left middle right])

;; Interpretation:
;; - 'null is the empty leaf node
;; - (make-two-node key left right) is a balanced 2-3 tree node
;;    with key to be value and children left and right
;; - (make-three-node s-key l-key left middle right) is a balanced 2-3 tree 
;;    node with s-key and l-key to be the smaller and larger value
;;    as well as children left, middle and right
;; Invarient:
;; 1 for a 2-node, all elements in its left child are less than the element it
;;   contains, and all elements in the right child are greater
;; 2 for a 3-node, all elements in its left child are less than both elements 
;;   it contains, all elements in its middle child are between the elements it 
;;   contains, and all elements in the right child are greater than both
;; 3 all empty leaf nodes have the same distance from the root 
(define ALPHA (make-two-node "a" 'null 'null))
(define BRAVO (make-three-node "a" "e" 'null 'null 'null))
(define CHARLIE (make-two-node "m"
                               (make-three-node "e" "j"
                                                (make-three-node "a" "c"
                                                                 'null
                                                                 'null
                                                                 'null)
                                                (make-two-node "h" 'null 'null)
                                                (make-two-node "l" 'null 'null))
                               (make-two-node "r"
                                              (make-two-node "p" 'null 'null)
                                              (make-three-node "s" "x"
                                                               'null
                                                               'null
                                                               'null))))
;; insert "z" into CHARLIE 
(define DELTA (make-two-node "m"
                             (make-three-node "e" "j"
                                              (make-three-node "a" "c"
                                                               'null
                                                               'null
                                                               'null)
                                              (make-two-node "h" 'null 'null)
                                              (make-two-node "l" 'null 'null))
                             (make-three-node "r" "x"
                                              (make-two-node "p" 'null 'null)
                                              (make-two-node "s" 'null 'null)
                                              (make-two-node "z" 'null 'null))))
;; insert "d" into CHARLIE
(define ECHO (make-three-node "e" "m"
                              (make-two-node "c"
                                             (make-two-node "a" 'null 'null)
                                             (make-two-node "d" 'null 'null))
                              (make-two-node "j"                 
                                             (make-two-node "h" 'null 'null)
                                             (make-two-node "l" 'null 'null))
                              (make-two-node "r"
                                             (make-two-node "p" 'null 'null)
                                             (make-three-node "s" "x"
                                                              'null
                                                              'null
                                                              'null))))
(define FOX (make-three-node "e" "j"
                             (make-three-node "a" "c" 'null 'null 'null)
                             (make-two-node "h" 'null 'null)
                             (make-two-node "l" 'null 'null)))
;; insert "d" into FOX
(define GOLF (make-two-node "e"
                           (make-two-node "c"
                                          (make-two-node "a" 'null 'null)
                                          (make-two-node "d" 'null 'null))
                           (make-two-node "j"
                                          (make-two-node "h" 'null 'null)
                                          (make-two-node "l" 'null 'null))))
;; a BAD 2-3 tree of a single two-node 
(define HOTEL (make-two-node "c"
                             (make-two-node "f" 'null 'null)
                             (make-two-node "e" 'null 'null)))
;; a BAD 2-3 tree of a single three-node
(define INDIA (make-three-node "c" "g"
                               (make-two-node "b" 'null 'null)
                               (make-two-node "h" 'null 'null)
                               (make-two-node "l" 'null 'null)))
;; a BAD 2-3 tree with different height of each child of the root
(define JULIETT (make-three-node "c" "g"
                                 (make-two-node "b" 'null 'null)
                                 (make-two-node "d" 'null 'null)
                                 (make-three-node "h" "m"
                                                  'null
                                                  (make-two-node "j"
                                                                 'null 'null)
                                                  'null)))
;; insert "g" into CHARLIE
(define KILO (make-two-node "m"
                            (make-three-node "e" "j"
                                             (make-three-node "a" "c"
                                                              'null
                                                              'null
                                                              'null)
                                             (make-three-node "g" "h"
                                                              'null 'null 'null)
                                             (make-two-node "l" 'null 'null))
                            (make-two-node "r"
                                           (make-two-node "p" 'null 'null)
                                           (make-three-node "s" "x"
                                                            'null
                                                            'null
                                                            'null))))
;; insert "i" into CHARLIE
(define LIMA (make-two-node "m"
                            (make-three-node "e" "j"
                                             (make-three-node "a" "c"
                                                              'null
                                                              'null
                                                              'null)
                                             (make-three-node "h" "i"
                                                              'null 'null 'null)
                                             (make-two-node "l" 'null 'null))
                            (make-two-node "r"
                                           (make-two-node "p" 'null 'null)
                                           (make-three-node "s" "x"
                                                            'null
                                                            'null
                                                            'null))))
;; insert "b" into CHARLIE
(define MIKE (make-three-node "e" "m"
                               (make-two-node "b"
                                              (make-two-node "a" 'null 'null)
                                              (make-two-node "c" 'null 'null))
                               (make-two-node "j"
                                              (make-two-node "h" 'null 'null)
                                              (make-two-node "l" 'null 'null))
                               (make-two-node "r"
                                              (make-two-node "p" 'null 'null)
                                              (make-three-node "s" "x"
                                                               'null
                                                               'null
                                                               'null))))

;; [Bal23Node X] [X X -> Boolean] -> Boolean
;; predicates whether the given tree is a well formed balanced 2-3 tree
;;
;; Examples:
;;  - ALPHA, BRAVO, ... , GOLF are well formed balanced 2-3 trees
;;  - HOTEL, INDIA, JULIETT are not well formed balanced 2-3 trees
;;
;; Strategy: functional composition
(define (2-3-tree? tree le?)
  (tree-check-success?
   (2-3-tree-checker tree le?)))

(check-expect (2-3-tree? ALPHA string<=?) #t)
(check-expect (2-3-tree? CHARLIE string<=?) #t)
(check-expect (2-3-tree? GOLF string<=?) #t)
(check-expect (2-3-tree? INDIA string<=?) #f)

;; A [TreeCheckReport X] is one of:
;; - (make-tree-check-success h [Listof X])
;; - 'failure
(define-struct tree-check-success (height key-list))
;; Interpretation:
;; - the tree-check-success means the given 2-3 tree is well formed
;; - 'failure means the given tree violates one or more invariants

;; [Bal23Node X] [X X -> Boolean] -> [TreeCheckReport X]
;; Recognizes valid 2-3 tree nodes and return a check report
;;
;; Examples:
;; - given CHARLIE returns(3 (list "a" "c" "e" "h" "j" "l" "m" "p" "r" "s" "x"))
;; - given HOTEL returns 'failure
(define (2-3-tree-checker tree le?)
  (cond
    [(two-node? tree)
     (two-node-local-checker (two-node-key tree)
                             (2-3-tree-checker (two-node-left tree) le?)
                             (2-3-tree-checker (two-node-right tree) le?)
                             le?)]
    [(three-node? tree)
     (three-node-local-checker (three-node-s-key tree)
                               (three-node-l-key tree)
                               (2-3-tree-checker (three-node-left tree) le?)
                               (2-3-tree-checker (three-node-middle tree) le?)
                               (2-3-tree-checker (three-node-right tree) le?)
                               le?)]
    [(symbol=? tree 'null)
     (make-tree-check-success 0 '())]))

;; X [TreeCheckReport X] [TreeCheckReport X] [X X -> Boolean]
;; -> [TreeCheckReport X]
;; Checks whether a 2-node meets the balanced 2-3 tree invariants
;; and returns the corresponding check report
(define (two-node-local-checker key l-report r-report le?)
  (if (two-node-check-success? key l-report r-report le?)
      (construct-2-node-check-success key l-report r-report)
      'failure))

  
;; X X [TreeCheckReport X] [TreeCheckReport X] [TreeCheckReport X]
;; [X X -> Boolean] -> [TreeCheckReport X]
;; Checks whether a 3-node meets the balanced 2-3 tree invariants
;; and returns the corresponding check report
(define (three-node-local-checker s-key l-key l-report m-report r-report le?)
  (if (three-node-check-success? s-key l-key l-report m-report r-report le?)
      (construct-3-node-check-success s-key l-key l-report m-report r-report)
      'failure))

;; X [TreeCheckReport X] [TreeCheckReport X] [X X -> Boolean] -> Boolean
;; Predicates whether a 2-node meets the balanced 2-3 tree invariants
(define (two-node-check-success? key l-report r-report le?)
  (and (tree-check-success? l-report)
       (tree-check-success? r-report)
       ;; check invariant 3
       (= (tree-check-success-height l-report)
          (tree-check-success-height r-report))
       ;; chekc invariant 1
       (andmap (lambda (v) (not (le? key v)))
               (tree-check-success-key-list l-report))
       (andmap (lambda (v) (not (le? v key)))
               (tree-check-success-key-list r-report))))

;; X X [TreeCheckReport X] [TreeCheckReport X] [TreeCheckReport X]
;; [X X -> Boolean] -> boolean
;; Predicates whether a 3-node meets the balanced 2-3 tree invariants
(define (three-node-check-success? s-key l-key l-report m-report r-report le?)
  (and (tree-check-success? l-report)
       (tree-check-success? m-report)
       (tree-check-success? r-report)
       ;; check invariant 3
       (= (tree-check-success-height l-report)
          (tree-check-success-height m-report)
          (tree-check-success-height r-report))
       ;; chekc invariant 1
       (andmap (lambda (v) (not (le? s-key v)))
               (tree-check-success-key-list l-report))
       (andmap (lambda (v) (and (not (le? v s-key))
                                (not (le? l-key v))))
               (tree-check-success-key-list m-report))
       (andmap (lambda (v) (not (le? v l-key)))
               (tree-check-success-key-list r-report))))

;; X [TreeCheckReport X] [TreeCheckReport X] -> [TreeCheckReport X]
;; construct a [TreeCheckReport X] based on the given 2-node info 
(define (construct-2-node-check-success key l-report r-report)
  (make-tree-check-success (add1 (tree-check-success-height l-report))
                           (append (tree-check-success-key-list l-report)
                                   (list key)
                                   (tree-check-success-key-list r-report))))

;; X X [TreeCheckReport X] [TreeCheckReport X] [TreeCheckReport X]
;; -> [TreeCheckReport X]
;; construct a [TreeCheckReport X] based on the given 3-node info
(define (construct-3-node-check-success s-key l-key l-report m-report r-report)
  (make-tree-check-success (add1 (tree-check-success-height l-report))
                           (append (tree-check-success-key-list l-report)
                                   (list s-key)
                                   (tree-check-success-key-list m-report)
                                   (list l-key)
                                   (tree-check-success-key-list r-report))))

;; A Split is (make-split [left v right])
;; left is a two-node whose key is smaller than v, v is an element/key
;; right is a two-node whose key is larger than v.
(define-struct split [lchild v rchild])

;; An [InsertResult X] is one of:
;;  - (make-two-node X [Bal23Node X] [Bal23Node X])
;;  - (make-three-node X X [Bal23Node X] [Bal23Node X] [Bal23Node X])
;;  - (make-split (make-two-node X [Bal23Node X] [Bal23Node X])
;;                X
;;                (make-two-node X [Bal23Node X] [Bal23Node X]))

;; [Bal23Node X] [X X -> Boolean] X -> [Bal23Node]
;; insert an element into a 2-3 tree
;;
;; Examples:
;;  - insert "z" into CHARLIE => DELTA
;;  - insert "d" into FOX => GOLF
;;
;; Strategy: functional composition
(define (insert tree le? el)
  (local [(define result (insert-helper tree le? el))]
    (if (split? result)
        (make-two-node (split-v result)
                       (split-lchild result)
                       (split-rchild result))
        result)))

(check-expect (insert 'null string<=? "a") ALPHA)
(check-expect (insert CHARLIE string<=? "z") DELTA)
(check-expect (insert FOX string<=? "d") GOLF)
(check-expect (insert ALPHA string<=? "a") ALPHA)
(check-expect (insert CHARLIE string<=? "d") ECHO)
(check-expect (insert CHARLIE string<=? "g") KILO)
(check-expect (insert CHARLIE string<=? "c") CHARLIE)
(check-expect (insert CHARLIE string<=? "i") LIMA)
(check-expect (insert CHARLIE string<=? "b") MIKE)


;; [Bal23Node X] [X X -> Boolean] X -> [InsertResult X]
;; insert an element into a 2-3 tree
(define (insert-helper tree le? el)
  (cond
    [(two-node? tree)
     (insert-2-node tree le? el)]
    [(three-node? tree)
     (insert-3-node tree le? el)]
    [(symbol=? tree 'null)
     (make-two-node el 'null 'null)]))

;; [Bal23Node X] [X X -> Boolean] X -> [InsertResult X]
;; insert an element into a two-node
(define (insert-2-node tree le? el)
  (cond
    [(my-equal? le? el (two-node-key tree)) tree]
    [(and (node? (two-node-left tree))
          (node? (two-node-right tree)))
     (cond
       [(le? (two-node-key tree) el)
        (two-node-process-result tree
                                 (insert-helper (two-node-right tree) le? el)
                                 'right)]
       [else
        (two-node-process-result tree
                                 (insert-helper (two-node-left tree) le? el)
                                 'left)])]
    [(and (symbol=? 'null (two-node-left tree))
          (symbol=? 'null (two-node-right tree)))
     (make-three-node (if (le? (two-node-key tree) el)
                          (two-node-key tree)
                          el)
                      (if (not (le? (two-node-key tree) el))
                          (two-node-key tree)
                          el)
                      'null 'null 'null)]))

;; [Bal23Node X] [InsertResult X] Symbol -> [InsertResult X]
;; handle the InsertResult after inserted a element into a two node
(define (two-node-process-result tree result dir)
  (cond
    [(symbol=? dir 'left)
     (if (split? result)
         (make-three-node (split-v result)
                          (two-node-key tree)
                          (split-lchild result)
                          (split-rchild result)
                          (two-node-right tree))
         (make-two-node (two-node-key tree)
                        result
                        (two-node-right tree)))]
    [(symbol=? dir 'right)
     (if (split? result)
         (make-three-node (two-node-key tree)
                          (split-v result)
                          (two-node-left tree)
                          (split-lchild result)
                          (split-rchild result))
         (make-two-node (two-node-key tree)
                        (two-node-left tree)
                        result))]))

;; [Bal23Node X] [X X -> Boolean] X -> [InsertResult X]
;; insert an element into a three-node
(define (insert-3-node tree le? el)
  (cond
    [(or (my-equal? le? el (three-node-s-key tree))
         (my-equal? le? el (three-node-l-key tree)))
     tree]
    [(and (node? (three-node-left tree))
          (node? (three-node-middle tree))
          (node? (three-node-right tree)))
     (cond
       [(le? el (three-node-s-key tree))
        (three-node-process-result
         tree
         (insert-helper (three-node-left tree) le? el)
         'left)]
       [(le? (three-node-l-key tree) el)
        (three-node-process-result
         tree
         (insert-helper (three-node-right tree) le? el)
         'right)]
       [else
           (three-node-process-result
            tree (insert-helper
                  (three-node-middle tree) le? el) 'middle)])]
    [(and (symbol=? (three-node-left tree) 'null)
          (symbol=? (three-node-middle tree) 'null)
          (symbol=? (three-node-right tree) 'null))
     (local [(define sorted-key
               (my-sort le? (list el
                                  (three-node-s-key tree)
                                  (three-node-l-key tree))))]
       (make-split (make-two-node (first sorted-key) 'null 'null)
                   (second sorted-key)
                   (make-two-node (third sorted-key) 'null 'null)))]))

;; [Bal23Node X] [InsertResult X] Symbol -> [InsertResult X]
;; handle the InsertResult after inserted a element into a three node
(define (three-node-process-result tree result dir)
  (cond
    [(symbol=? dir 'left)
     (if (split? result)
         (make-split (make-two-node (split-v result)
                                    (split-lchild result)
                                    (split-rchild result))
                     (three-node-s-key tree)
                     (make-two-node (three-node-l-key tree)
                                    (three-node-middle tree)
                                    (three-node-right tree)))
         (make-three-node (three-node-s-key tree)
                          (three-node-l-key tree)
                          result
                          (three-node-middle tree)
                          (three-node-right tree)))]
    [(symbol=? dir 'right)
     (if (split? result)
         (make-split (make-two-node (three-node-s-key tree)
                                    (three-node-left tree)
                                    (three-node-middle tree))
                     (three-node-l-key tree)
                     (make-two-node (split-v result)
                                    (split-lchild result)
                                    (split-rchild result)))
         (make-three-node (three-node-s-key tree)
                          (three-node-l-key tree)
                          (three-node-left tree)
                          (three-node-middle tree)
                          result))]
    [(symbol=? dir 'middle)
     (if (split? result)
         (make-split (make-two-node (three-node-s-key tree)
                                    (three-node-left tree)
                                    (split-lchild result))
                     (split-v result)
                     (make-two-node (three-node-l-key tree)
                                    (split-rchild result)
                                    (three-node-right tree)))
         (make-three-node (three-node-s-key tree)
                          (three-node-l-key tree)
                          (three-node-left tree)                  
                          result
                          (three-node-right tree)))]))

;; [X X -> Boolean] [Listof X] -> [Listof X]
;; insertion sort
(define (my-sort le? loe)
  (cond
    [(empty? loe) '()]
    [(= (length loe) 1) loe]
    [else (sort-helper le? (first loe) (my-sort le? (rest loe)))]))

;; [X X -> Boolean] X [Listof X] -> [Listof X]
;; helper function of insertion sort
(define (sort-helper le? el loe)
  (cond
    [(empty? loe) (list el)]
    [else
     (if (le? el (first loe))
         (cons el loe)
         (cons (first loe) (sort-helper le? el (rest loe))))]))

(check-expect (my-sort string<=? (list "f" "e" "d" "c" "b" "a"))
              (list "a" "b" "c" "d" "e" "f"))

;; [Bal23Node X] -> Boolean
;; predicates a node
(define (node? tree)
  (or (two-node? tree)
      (three-node? tree)))

;; [X X -> Boolean] X X -> Boolean
;; whether two elements are equal
(define (my-equal? le? key1 key2)
  (and (le? key1 key2) (le? key2 key1)))

;; random test
(define TestList (map (lambda (num) (random num)) (make-list 1000 50000)))

(check-expect (2-3-tree?
               (foldl (lambda (x y) (insert y <= x)) 'null TestList) <=)
              #t)

#;
(foldl (lambda (num tree)
         (local ((define result (insert tree <= num)))
           (if (2-3-tree? result <=)
               result
               (error "Invalid Balance 2-3 Tree Detected!"))))
       'null
       TestList)

;; [Bal23Node] X [X X -> boolean] -> [Maybe X]
;; a [Maybe X] is either
;;  - X
;;  - 'NotFound
;; lookup for an element in a 2-3 tree.
;;
;; Examples:
;;  - search CHARLIE for "a" => "a"
;;  - search CHARLIE for "b" => 'NotFound
;;
;; Strategy: struct decomp
(define (lookup tree el le?)
  (cond
    [(two-node? tree)
     (two-node-search-helper tree el le?)]
    [(three-node? tree)
     (three-node-search-helper tree el le?)]
    [(symbol=? tree 'null) 'NotFound]))

(check-expect (lookup CHARLIE "a" string<=?) "a")
(check-expect (lookup CHARLIE "b" string<=?) 'NotFound)
(check-expect (lookup CHARLIE "r" string<=?) "r")
(check-expect (lookup CHARLIE "h" string<=?) "h")
(check-expect (lookup CHARLIE "l" string<=?) "l")

;; [Bal23Node] X [X X -> Boolean] -> [Maybe X]
;; process the situation when searching a two-node
(define (two-node-search-helper tree el le?)
  (cond
    [(my-equal? le? el (two-node-key tree))
     (two-node-key tree)]
    [(le? el (two-node-key tree))
     (lookup (two-node-left tree) el le?)]
    [else (lookup (two-node-right tree) el le?)]))

;; [Bal23Node] X [X X -> Boolean] -> [Maybe X]
;; process the situation when searching a three-node
(define (three-node-search-helper tree el le?)
  (cond
    [(my-equal? le? el (three-node-l-key tree))
     (three-node-l-key tree)]
    [(my-equal? le? el (three-node-s-key tree))
     (three-node-s-key tree)]
    [(le? el (three-node-s-key tree))
     (lookup (three-node-left tree) el le?)]
    [(le? (three-node-l-key tree) el)
     (lookup (three-node-right tree) el le?)]
    [else (lookup (three-node-middle tree) el le?)]))

;; [Bal23Node] X [X X -> Boolean] -> Boolean
;; search a 2-3 tree, return a Boolean
;;
;; Examples:
;;  - search CHARLIE for "a" => #t
;;  - search CHARLIE for "b" => #f
;;
;; Strategy: functional composition
(define (set-lookup tree el le?)
  (local [(define result (lookup tree el le?))]
    (if (and (symbol? result)
             (symbol=? result 'NotFound))
        #f
        #t)))

(check-expect (set-lookup CHARLIE "a" string<=?) #t)
(check-expect (set-lookup CHARLIE "b" string<=?) #f)
(check-expect (set-lookup CHARLIE "r" string<=?) #t)
(check-expect (set-lookup CHARLIE "h" string<=?) #t)
(check-expect (set-lookup CHARLIE "l" string<=?) #t)


;; A [KVPair X Y] is
(define-struct k/v [key value])

;; a [Maybe Y] is either
;;  - Y
;;  - 'NotFound

;; [Bal23Node] X [X X -> Boolean] -> [Maybe Y]
;; search a 2-3 tree of key-value pairs
;;
;; Examples:
;;  - given November and "b", returns 2
;;  - given November and "c", return 'NotFound
;;
;; Strategy: functional composition
(define (map-lookup tree key le?)
  (local [(define result
            (lookup tree (make-k/v key 0) (k/v-le? le?)))]
    (if (and (symbol? result)
             (symbol=? result 'NotFound))
        result
        (k/v-value result))))

;; [X X -> Boolean] -> [[KVPair X Y] [KVPair X Y] -> Boolean]
;; returns a predicate for KVPairs based on the given predicate for Xs
(define (k/v-le? le?)
  (lambda (x y)
    (le? (k/v-key x) (k/v-key y))))


(define NOVEMBER (insert (insert 'null (k/v-le? string<=?) (make-k/v "a" 1))
                         (k/v-le? string<=?) (make-k/v "b" 2)))

(check-expect (map-lookup NOVEMBER "b" string<=?) 2)
(check-expect (map-lookup NOVEMBER "c" string<=?) 'NotFound)