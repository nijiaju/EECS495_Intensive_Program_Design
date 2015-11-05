;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname HW5) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; ================ QUESTION 1 ================
;; A Rank is an exact non-negative integer
;; Interpretation:
;; Rank is the length of right spine of a node
;;
;; A [LeftistHeapNode X] is one of:
;; -- (make-none)
;; -- (make-heap-node X Rank [LeftistHeapNode X] [LeftistHeapNode X])
;; with invariant:
;; 1- the element in each node is no larger than the elements in its children
;; 2- the rank of left child is at large or euaql than the rank of right child
(define-struct none ())
(define-struct heap-node (value rank left right))
(define LEAF (make-none))
;; Examples:
(define LEAF-ONLY LEAF)
(define ONE-NODE (make-heap-node 3 1 LEAF LEAF))
(define BEFORE-MERGE-1
  (make-heap-node 1 2
                  (make-heap-node 2 1 LEAF LEAF)
                  (make-heap-node 3 1 LEAF LEAF)))
(define BEFORE-MERGE-2
  (make-heap-node 4 1
                  (make-heap-node 5 1 LEAF LEAF)
                  LEAF))
(define AFTER-MERGE-1-2
  (make-heap-node 1 2
                  (make-heap-node 2 1 LEAF LEAF)
                  (make-heap-node 3 1
                                  (make-heap-node 4 1
                                                  (make-heap-node 5 1 LEAF LEAF)
                                                  LEAF)
                                  LEAF)))
(define BAD-HEAP-1
    (make-heap-node 1 2
                  (make-heap-node 2 1 LEAF LEAF)
                  (make-heap-node 6 1
                                  (make-heap-node 4 1
                                                  (make-heap-node 5 1 LEAF LEAF)
                                                  LEAF)
                                  LEAF)))
(define BAD-HEAP-2
    (make-heap-node 1 3
                  (make-heap-node 2 1 LEAF LEAF)
                  (make-heap-node 3 2
                                  LEAF
                                  (make-heap-node 4 1
                                                  (make-heap-node 5 1 LEAF LEAF)
                                                  LEAF))))
(define BAD-HEAP-3
  (make-heap-node 1 2
                  (make-heap-node 2 2 LEAF LEAF)
                  (make-heap-node 3 1
                                  (make-heap-node 4 1
                                                  (make-heap-node 5 1 LEAF LEAF)
                                                  LEAF)
                                  LEAF)))
(define BAD-HEAP-4
  (make-heap-node 1 3
                  (make-heap-node 2 2 LEAF LEAF)
                  (make-heap-node 3 1
                                  (make-heap-node 4 1
                                                  (make-heap-node 5 1 LEAF LEAF)
                                                  LEAF)
                                  LEAF)))

;; [LeftistHeapNode X] -> boolean
;; predicates whether a given heap is empty
;; Strategy: structural decomposition
(define (isEmpty? heap)
  (cond
    [(none? heap) #t]
    [(heap-node? heap) #f]))

;; X [LeftistHeapNode X] [X X -> boolean] -> [LeftistHeapNode X]
;; inserts a new value into the leftist heap
;; Strategy: functional composition
(define (insert value heap <=?)
  (merge (make-heap-node value 1 LEAF LEAF) heap <=?))

;; [LeftistHeapNode X] -> X
;; returns the minmum value in the heap
;; Strategy: structural decomposition
(define (find-min heap)
  (cond
    [(isEmpty? heap) (error "empty heap")]
    [(heap-node? heap) (heap-node-value heap)]))

;; [LeftistHeapNode X] [X X -> boolean] -> [LeftistHeapNode X]
;; removes the minmum value in the heap
;; Strategy: structural decomposition
(define (remove-min heap <=?)
  (cond
    [(isEmpty? heap) (error "empty heap")]
    [(heap-node? heap) (merge (heap-node-left heap)
                              (heap-node-right heap) <=?)]))

;; [LeftistHeapNode X] [LeftistHeapNode X] -> [LeftistHeapNode X]
;; merge two leftist heaps and turns a new heap
;; Strategy: template for simultaneous processing
(define (merge heap1 heap2 <=?)
  (cond
    [(isEmpty? heap1) heap2]
    [(isEmpty? heap2) heap1]
    [else
     (if (<=? (heap-node-value heap1) (heap-node-value heap2))
           (new-heap-node (heap-node-value heap1)
                          (heap-node-left heap1)
                          (merge (heap-node-right heap1) heap2 <=?))
           (new-heap-node (heap-node-value heap2)
                          (heap-node-left heap2)
                          (merge heap1 (heap-node-right heap2) <=?)))]))

;; X [LeftistHeapNode X] [LeftistHeapNode X] -> [LeftistHeapNode X]
;; Creates a new node that meets the invariant requirments of leftist heap
;; Strategy: structural decomposition
(define (new-heap-node value left right)
  (cond
    [(isEmpty? left) (make-heap-node value 1 right left)]
;    [(isEmpty? right) (make-heap-node value 1 left right)]
    [else
     (if (< (heap-node-rank left) (heap-node-rank right))
         (make-heap-node value (add1 (heap-node-rank left)) right left)
         (make-heap-node value (add1 (heap-node-rank right)) left right))]))


(check-expect (merge BEFORE-MERGE-1 BEFORE-MERGE-2 <=) AFTER-MERGE-1-2)

;; Random Test Helper Functions

;;A report is one of:
;; -- 'failure
;; -- 'leaf
;; -- (make-success X Rank)
(define-struct success (min-value rank))

;; [LeftistHeapNode X] [X X -> boolean] -> boolean
;; Predicates whether the given heap is a well formed leftist heap
;; Strategy: functional composition
(define (is-leftist-heap? heap <=?)
  (local
    [(define result (check-leftist-heap heap <=?))]
    (cond
      [(and (symbol? result) (symbol=? 'failure result)) #f]
      [else #t])))

;; [LeftistHeapNode X] [X X -> boolean] -> report
;; Returns a report about whether the given heap is a well formed leftist heap
;; Strategy: structural decomposition
(define (check-leftist-heap heap <=?)
  (cond
    [(none? heap) 'leaf]
    [(heap-node? heap)
     (local
       [(define left-report (check-leftist-heap (heap-node-left heap) <=?))
        (define right-report (check-leftist-heap (heap-node-right heap) <=?))]
       (check-invariant heap left-report right-report <=?))]))

;; [LeftistHeapNode X] report report [X X -> boolean] -> report
;; checks whethre the invariants are violated
;; Strategy: template for simultaneous processing
(define (check-invariant heap left-report right-report <=?)
  (cond
    [(or (and (symbol? left-report) (symbol=? 'failure left-report))
         (and (symbol? right-report) (symbol=? 'failure right-report)))
     'failure]
    [(and (and (symbol? left-report) (symbol=? 'leaf left-report))
          (and (symbol? right-report) (symbol=? 'leaf right-report)))
     (if (= (heap-node-rank heap) 1)
         (make-success (heap-node-value heap) 1)
         'failure)]
    [(and (and (symbol? left-report) (symbol=? 'leaf left-report))
          (success? right-report))
     'failure]
    [(and (success? left-report)
          (and (symbol? right-report) (symbol=? 'leaf right-report)))
     (if (and (<=? (heap-node-value heap) (success-min-value left-report))
              (= (heap-node-rank heap) 1))
         (make-success (heap-node-value heap) 1)
         'failure)]
    [else
     (if (and (<=? (heap-node-value heap) (success-min-value left-report))
              (<=? (heap-node-value heap) (success-min-value right-report))
              (>= (success-rank left-report) (success-rank right-report))
              (= (heap-node-rank heap) (add1 (success-rank right-report))))
         (make-success (heap-node-value heap)
                       (add1 (success-rank right-report)))
         'failure)]))

(check-expect (is-leftist-heap? LEAF-ONLY <=) #t)
(check-expect (is-leftist-heap? ONE-NODE <=) #t)
(check-expect (is-leftist-heap? BEFORE-MERGE-1 <=) #t)
(check-expect (is-leftist-heap? BEFORE-MERGE-2 <=) #t)
(check-expect (is-leftist-heap? AFTER-MERGE-1-2 <=) #t)
(check-expect (is-leftist-heap? BAD-HEAP-1 <=) #f)
(check-expect (is-leftist-heap? BAD-HEAP-2 <=) #f)
(check-expect (is-leftist-heap? BAD-HEAP-3 <=) #f)
(check-expect (is-leftist-heap? BAD-HEAP-4 <=) #f)

(define TEST-CASE-1 (build-list 1000 (λ (x) (random 10000))))
(define SORTED-TEST-CASE-1 (sort TEST-CASE-1 <))
(define RESULT-TREE-1 (foldl (λ (value node)
                            (local ((define result (insert value node <=)))
                              (if (is-leftist-heap? result <=)
                                  result
                                  (error "Invalid Leftist Heap Detected!"))))
                          LEAF
                          TEST-CASE-1))
(define TEST-CASE-2 (build-list 10 (λ (x) (int->string (random 55295)))))
(define SORTED-TEST-CASE-2 (sort TEST-CASE-2 string<?))
(define RESULT-TREE-2 (foldl (λ (value node)
                            (local ((define result (insert value node string<=?)))
                              (if (is-leftist-heap? result string<=?)
                                  result
                                  (error "Invalid Leftist Heap Detected!"))))
                          LEAF
                          TEST-CASE-2))

(define (rem-tst lst heap <=? =?)
  (if (> (length lst) 0)
      (if (=? (find-min heap) (first lst))
          (local [(define result (remove-min heap <=?))]
            (if (is-leftist-heap? result <=?)
                (rem-tst (rest lst) result <=? =?)
                (error "Invalid Leftist Heap Detected!")))
          (error "Wrong Minmun Value Detected"))
      #t))
(check-expect (rem-tst SORTED-TEST-CASE-1 RESULT-TREE-1 <= =) #t)
(check-expect (rem-tst SORTED-TEST-CASE-2 RESULT-TREE-2 string<=? string=?) #t)



;; ================ QUESTION 2 ================
;; A HM-Leaf is (make-hm-leaf 1String Integer)
;; Interpretation:
;; A leaf contains a single character from the string
;; and a count of the number of times the character appears in the string
(define-struct hm-leaf (char number))
;; A HM-Node is (make-hm-node Integer Huffmantree Huffmantree)
;; Interpretation:
;; an internal node is the node has a count and two children
(define-struct hm-node (number left right))
;; A Huffmantree is one of:
;; -- NONE
;; -- HM-Leaf
;; -- HM-Node
(define-struct hm-none ())
(define NONE (make-hm-none))
;;
;; A ListOfLeaves is one of:
;; -- '()
;; -- (cons HM-Leaf ListOfLeaves)

;; 1String ListOfLeaves -> ListOfLeaves
;; if the given character is in the list, increase the int field by 1
;; else create a new HM-Leaf structure
;; examples:
;; "a" '() -> (list (make-hm-leaf "a" 1))
;; "a" (list (make-hm-leaf "a" 1)) -> (list (make-hm-leaf "a" 2))
;; "b" (list (make-hm-leaf "a" 1) (make-hm-leaf "b" 2)) ->
;;                     (list (make-hm-leaf "a" 1) (make-hm-leaf "b" 3))
;; Strategy: Accumulator
;; Interpretation:
;; count-list records what chars appeared and the frequency 

(define (character-counter s count-list)
  (cond
    [(empty? count-list) (list (make-hm-leaf s 1))]
    [(cons? count-list)
     (if (string=? s (hm-leaf-char (first count-list)))
         (cons (make-hm-leaf s (add1 (hm-leaf-number (first count-list))))
               (rest count-list))
         (cons (first count-list)
               (character-counter s (rest count-list))))]))

(check-expect (character-counter "a" '()) (list (make-hm-leaf "a" 1)))
(check-expect (character-counter "a" (list (make-hm-leaf "a" 1)))
              (list (make-hm-leaf "a" 2)))
(check-expect (character-counter "b"
                            (list (make-hm-leaf "a" 1) (make-hm-leaf "b" 2)))
              (list (make-hm-leaf "a" 1) (make-hm-leaf "b" 3)))

;; String -> ListOfLeaves
;; counts the frenquency of every character in the string
;; exapmle:
;; given "We are Jordan, never give up" ->
;;              (list (make-hm-leaf "W" 1) (make-hm-leaf "e" 5)
;;                    (make-hm-leaf " " 5) (make-hm-leaf "a" 2)
;;                    (make-hm-leaf "r" 3) (make-hm-leaf "J" 1)
;;                    (make-hm-leaf "o" 1) (make-hm-leaf "d" 1)
;;                    (make-hm-leaf "n" 2) (make-hm-leaf "," 1)
;;                    (make-hm-leaf "v" 2) (make-hm-leaf "g" 1)
;;                    (make-hm-leaf "i" 1) (make-hm-leaf "u" 1)
;;                    (make-hm-leaf "p" 1))
;; given "" -> '()
;; given "apple" -> (list (make-hm-leaf "a" 1) (make-hm-leaf "p" 2)
;;                        (make-hm-leaf "l" 1) (make-hm-leaf "e" 1))
;; Strategy: function composition
(define (leaves-list s)
  (foldl character-counter '() (explode s)))

(check-expect (leaves-list "We are Jordan, never give up")
              (list (make-hm-leaf "W" 1) (make-hm-leaf "e" 5)
                    (make-hm-leaf " " 5) (make-hm-leaf "a" 2)
                    (make-hm-leaf "r" 3) (make-hm-leaf "J" 1)
                    (make-hm-leaf "o" 1) (make-hm-leaf "d" 1)
                    (make-hm-leaf "n" 2) (make-hm-leaf "," 1)
                    (make-hm-leaf "v" 2) (make-hm-leaf "g" 1)
                    (make-hm-leaf "i" 1) (make-hm-leaf "u" 1)
                    (make-hm-leaf "p" 1)))
(check-expect (leaves-list "apple")
              (list (make-hm-leaf "a" 1) (make-hm-leaf "p" 2)
                     (make-hm-leaf "l" 1) (make-hm-leaf "e" 1)))
(check-expect (leaves-list "") '())

;; Huffmantree Huffmantree -> Boolean
;; Interpretation: given two Huffmantree and decide which one is smaller
;; Examples:
;; (make-hm-leaf "W" 1) (make-hm-leaf "e" 5) -> #true
;; (make-hm-leaf "W" 1) (make-hm-node 6 (make-hm-leaf "W" 1)
;;                                      (make-hm-leaf "e" 5)) -> #true
;; (make-hm-node 6 (make-hm-leaf "W" 1) (make-hm-leaf "e" 5))
;; (make-hm-leaf "W" 1) -> #false
;; (make-hm-node 6 (make-hm-leaf "W" 1) (make-hm-leaf "e" 5))
;; (make-hm-node 3 (make-hm-leaf "v" 2) (make-hm-leaf "g" 1)) -> #false
;; Strategy: structural decomposition

(define (hm<=? l1 l2)
  (cond [(and (hm-leaf? l1) (hm-leaf? l2))
         (<= (hm-leaf-number l1) (hm-leaf-number l2))]
        [(hm-leaf? l1) (<= (hm-leaf-number l1) (hm-node-number l2))]
        [(hm-leaf? l2) (<= (hm-node-number l1) (hm-leaf-number l2))]
        [else (<= (hm-node-number l1) (hm-node-number l2))]))

(check-expect (hm<=? (make-hm-leaf "W" 1) (make-hm-leaf "e" 5)) #true)
(check-expect (hm<=? (make-hm-leaf "W" 1) (make-hm-node 6 (make-hm-leaf "W" 1)
                                                        (make-hm-leaf "e" 5)))
              #true)
(check-expect (hm<=? (make-hm-node 6 (make-hm-leaf "W" 1) (make-hm-leaf "e" 5))
                     (make-hm-leaf "W" 1)) #false)

(check-expect (hm<=? (make-hm-node 6 (make-hm-leaf "W" 1) (make-hm-leaf "e" 5))
                     (make-hm-node 3 (make-hm-leaf "v" 2) (make-hm-leaf "g" 1)))
              #false)

(define TEST-LEAVE-LIST (leaves-list "We are Jordan, never give up"))
;; ListOfLeaves-> Huffmantree
;; Interpretation: given a ListOfLeaves make it into a priority queue and
;; make the priority queue to a huffmantree
;; examples:
;; TEST-LEAVE-LIST -> (make-hm-node 28
;;                 (make-hm-node 11
;;                    (make-hm-leaf "e" 5)
;;                    (make-hm-node 6
;;                       (make-hm-node 3
;;                          (make-hm-leaf "W" 1)
;;                          (make-hm-leaf "a" 2))
;;                       (make-hm-leaf "r" 3)))
;;                 (make-hm-node 17
;;                    (make-hm-node 8
;;                       (make-hm-node 4
;;                          (make-hm-node 2
;;                             (make-hm-leaf "o" 1)
;;                             (make-hm-leaf "J" 1))
;;                          (make-hm-node 2
;;                             (make-hm-leaf "," 1)
;;                             (make-hm-leaf "d" 1)))
;;                       (make-hm-node 4
;;                          (make-hm-leaf "n" 2)
;;                          (make-hm-node 2
;;                             (make-hm-leaf "i" 1)
;;                             (make-hm-leaf "g" 1))))
;;                    (make-hm-node 9
;;                       (make-hm-node 4
;;                          (make-hm-leaf "v" 2)
;;                          (make-hm-node 2
;;                             (make-hm-leaf "p" 1)
;;                             (make-hm-leaf "u" 1)))
;;                       (make-hm-leaf " " 5))))
;; (leaves-list "") -> (make-hm-none)
;; Strategy: function composition

(define (produce-huffmantree stat)
  (local
    [(define stat-heap (foldl (λ (v h) (insert v h hm<=?)) LEAF stat))]
    (heap-node-value (get-huffmantree stat-heap))))

(check-expect (produce-huffmantree TEST-LEAVE-LIST)
              (make-hm-node 28
                 (make-hm-node 11
                    (make-hm-leaf "e" 5)
                    (make-hm-node 6
                       (make-hm-node 3
                          (make-hm-leaf "W" 1)
                          (make-hm-leaf "a" 2))
                       (make-hm-leaf "r" 3)))
                 (make-hm-node 17
                    (make-hm-node 8
                       (make-hm-node 4
                          (make-hm-node 2
                             (make-hm-leaf "o" 1)
                             (make-hm-leaf "J" 1))
                          (make-hm-node 2
                             (make-hm-leaf "," 1)
                             (make-hm-leaf "d" 1)))
                       (make-hm-node 4
                          (make-hm-leaf "n" 2)
                          (make-hm-node 2
                             (make-hm-leaf "i" 1)
                             (make-hm-leaf "g" 1))))
                    (make-hm-node 9
                       (make-hm-node 4
                          (make-hm-leaf "v" 2)
                          (make-hm-node 2
                             (make-hm-leaf "p" 1)
                             (make-hm-leaf "u" 1)))
                       (make-hm-leaf " " 5)))))
(check-expect (produce-huffmantree (leaves-list "")) (make-hm-none))

;; [LeftistHeapNode X] -> Huffmantree
;; interpretation: given a priority queue to make a huffmantree
;; Strategy: function composition 
(define (get-huffmantree stat-heap)
  (cond
    [(isEmpty? stat-heap) (make-heap-node NONE 1 LEAF LEAF)]
    [(isEmpty? (remove-min stat-heap hm<=?)) stat-heap]
    [else
     (get-huffmantree (insert (get-two-min stat-heap)
                              (remove-min (remove-min stat-heap hm<=?) hm<=?)
                              hm<=?))]))

;; [LeftistHeapNode X] -> HM-Node
;; remove the two trees with the minimum count,
;; then combine them into a new tree with an updated count
;; Strategy: structural decomposition 

(define (get-two-min stat-heap)
  (local
    [(define first stat-heap)
     (define second (remove-min stat-heap hm<=?))
     (define rest (remove-min (remove-min stat-heap hm<=?) hm<=?))]
    (cond
      [(and (hm-leaf? (heap-node-value first))
            (hm-leaf? (heap-node-value second)))
       (make-hm-node (+ (hm-leaf-number (heap-node-value first))
                        (hm-leaf-number (heap-node-value second)))
                     (heap-node-value first)
                     (heap-node-value second))]
      [(hm-leaf? (heap-node-value first))
       (make-hm-node (+ (hm-leaf-number (heap-node-value first))
                        (hm-node-number (heap-node-value second)))
                     (heap-node-value first)
                     (heap-node-value second))]
      [(hm-leaf? (heap-node-value second))
       (make-hm-node (+ (hm-node-number (heap-node-value first))
                        (hm-leaf-number (heap-node-value second)))
                     (heap-node-value first)
                     (heap-node-value second))]
      [else
       (make-hm-node (+ (hm-node-number (heap-node-value first))
                        (hm-node-number (heap-node-value second)))
                     (heap-node-value first)
                     (heap-node-value second))])))





;; A KVPair is (make-kv-pair 1String BinaryString)
;; Interpretation:
;; the Key is the character and the Value is the corresponding code
(define-struct kv-pair (key value))

;; Huffmantree -> ListOfKVPair
;; Converts a huffmantree to a list of kv-pairs 
;; Strategy: structrual decomposition with accumulator
(define (encode-tree a-tree)
  (local [;; Accumulator:
          ;; code is a binary string represents the elements traversed thus far
          (define (encode-hmtree code a-tree )
            (cond
              [(hm-leaf? a-tree)
               (list (make-kv-pair (hm-leaf-char a-tree) code))]
              [(hm-node? a-tree)
               (append (encode-hmtree (string-append code "0")
                                      (hm-node-left a-tree))
                       (encode-hmtree (string-append code "1")
                                      (hm-node-right a-tree)))]))]
    (cond
      [(hm-none? a-tree) '()]
      [(hm-leaf? a-tree) (list (make-kv-pair (hm-leaf-char a-tree) "0"))]
      [(hm-node? a-tree) (append (encode-hmtree "0" (hm-node-left a-tree))
                                 (encode-hmtree "1" (hm-node-right a-tree)))])))


;; A Encoding is (make-encoding tree coding)
;; Interpretation:
;; Combinatation of huffman tree and a coding
(define-struct encoding (tree coding))

;; String -> Encoding
;; Converts a string to a corresponding huffmantree and code
;; Example:
;; "" -> (make-encoding (make-hm-none) "")
;; "a" -> (make-encoding (make-hm-leaf "a" 1) "0")
;; "We are Jordan" -> (make-encoding (make-hm-node 13
;;                                (make-hm-node 5
;;                                   (make-hm-leaf "e" 2)
;;                                   (make-hm-node 3
;;                                      (make-hm-leaf "W" 1)
;;                                      (make-hm-leaf "r" 2)))
;;                                (make-hm-node 8
;;                                   (make-hm-node 4
;;                                      (make-hm-node 2
;;                                         (make-hm-leaf "o" 1)
;;                                         (make-hm-leaf "J" 1))
;;                                      (make-hm-leaf " " 2))
;;                                   (make-hm-node 4
;;                                      (make-hm-leaf "a" 2)
;;                                      (make-hm-node 2
;;                                         (make-hm-leaf "n" 1)
;;                                        (make-hm-leaf "d" 1)))))
;;                             "01000101110011001011001100001111111101110")
;; Strategy: fuction composition 
(define (encode s)
  (local
    [(define tree (produce-huffmantree (leaves-list s)))
     (define dict (encode-tree tree))
     ;; 1String Listofkvpair -> BinaryString
     ;; Interpretation:
     ;; searchs the given key in the dict 
     (define (search-in-dict 1s dict)
       (cond
         [(empty? dict) (error 'encode "Invalid Char Detected")]
         [(cons? dict) (if (string=? 1s (kv-pair-key (first dict)))
                           (kv-pair-value (first dict))
                           (search-in-dict 1s (rest dict)))]))
     ;; ListOfChar -> Binarystring
     ;; Converts the string to the code
     (define (encode-helper char-list)
       (cond
         [(empty? char-list) ""]
         [(cons? char-list) (string-append
                             (search-in-dict (first char-list) dict)
                             (encode-helper (rest char-list)))]))]
    (make-encoding tree (encode-helper (explode s)))))

(check-expect (encode "") (make-encoding (make-hm-none) ""))
(check-expect (encode "a") (make-encoding (make-hm-leaf "a" 1) "0"))
(check-expect (encode "We are Jordan")
              (make-encoding (make-hm-node 13
                                (make-hm-node 5
                                   (make-hm-leaf "e" 2)
                                   (make-hm-node 3
                                      (make-hm-leaf "W" 1)
                                      (make-hm-leaf "r" 2)))
                                (make-hm-node 8
                                   (make-hm-node 4
                                      (make-hm-node 2
                                         (make-hm-leaf "o" 1)
                                         (make-hm-leaf "J" 1))
                                      (make-hm-leaf " " 2))
                                   (make-hm-node 4
                                      (make-hm-leaf "a" 2)
                                      (make-hm-node 2
                                         (make-hm-leaf "n" 1)
                                         (make-hm-leaf "d" 1)))))
                             "01000101110011001011001100001111111101110"))


;; Encoding -> String
;; Interpretation: give a encoding and convert it to the corresponding string
;; examples:
;; given (encode "We are Jordan, never give up") ->
;;                                              "We are Jordan, never give up"
;; given (encode "a") -> "a"
;; given (encode "") ->""
;; Strategy: structural decomposition with accumulator 
(define (decode encoding)
  (local
    [(define hm-tree (encoding-tree encoding))
     (define code-list (explode (encoding-coding encoding)))
      ;; Accumulator :
      ;; tracks strings have been decoded thus far
      (define (decode-tree-search tree code-list s)
       (cond
         [(empty? code-list) s]
         [(cons? code-list)
          (cond
            [(hm-none? tree) (error 'decode "Empty Huffman Tree Detected")]
            [(hm-leaf? tree)
             (decode-tree-search tree
                                 (rest code-list)
                                 (string-append s (hm-leaf-char tree)))]
            [(hm-node? tree)
             (cond
               [(string=? (first code-list) "0")
                (if (hm-leaf? (hm-node-left tree))
                    (decode-tree-search hm-tree
                                        (rest code-list)
                                        (string-append s
                                                       (hm-leaf-char
                                                        (hm-node-left tree))))
                    (decode-tree-search (hm-node-left tree)
                                        (rest code-list) s))]
               [(string=? (first code-list) "1")
                (if (hm-leaf? (hm-node-right tree))
                    (decode-tree-search hm-tree
                                        (rest code-list)
                                        (string-append s
                                                       (hm-leaf-char
                                                        (hm-node-right tree))))
                (decode-tree-search (hm-node-right tree)
                                    (rest code-list) s))])])]))]
    (decode-tree-search hm-tree code-list "")))

(check-expect (decode (encode "We are Jordan, never give up"))
              "We are Jordan, never give up")
(check-expect (decode (encode "a")) "a")
(check-expect (decode (encode "")) "")
    
    