;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW3-2) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; 2-3 Tree

(define-struct no-info [])
(define NONE (make-no-info))
(define-struct two-node [num left right])
(define-struct three-node [smaller larger left middle right])

;; A 2-3 Tree (TTT) is one of:
;; - NONE
;; - (make-two-node Number TTT TTT)
;; - (make-three-node Number Number TTT TTT TTT)
(define TTT0 NONE)
(define TTT1 (make-two-node 2 NONE NONE))
(define TTT2 (make-three-node 1 3 NONE NONE NONE))
(define TTT3 (make-three-node 1 3 NONE NONE (make-two-node 5 NONE NONE)))
(define TTT4-1 (make-three-node -2 -1
                                (make-three-node -4 -3 NONE NONE NONE)
                                NONE NONE))
(define TTT4-2 (make-three-node 4 5
                                NONE NONE
                                (make-three-node 6 7 NONE NONE NONE)))
(define TTT11 (make-three-node 1 3 TTT4-1 TTT1 TTT4-2))
                               
;; Number TTT -> Boolean
;; search a 2-3 tree to see if it contains the number
;;
;; Examples:
;;  - 2 is in TTT1
;;  - 5 is in TTT11
;;  - 2 is not in TTT4-1
;;
;; Strategy: template for TTT
#;
(define (process-ttt a-ttt ...)
  (cond
    [(no-info? a-ttt) ...]
    [(two-node? a-ttt)
     ... (two-node-num a-ttt) ...
     ... (process-ttt (two-node-left a-ttt) ...) ...
     ... (process-ttt (two-node-right a-ttt) ...) ...]
    [(three-node? a-ttt)
     ... (three-node-smaller a-ttt) ...
     ... (three-node-larger a-ttt) ...
     ... (process-ttt (three-node-left a-ttt) ...) ...
     ... (process-ttt (three-node-middle a-ttt) ...) ...
     ... (process-ttt (three-node-right a-ttt) ...) ...]))

(define (lookup n a-ttt)
  (cond
    [(no-info? a-ttt) #f]
    [(two-node? a-ttt)
     (= (two-node-num a-ttt) n)]
    [(three-node? a-ttt)
     (cond
       [(= (three-node-smaller a-ttt) n) #t]
       [(= (three-node-larger a-ttt) n) #t]
       [(< n (three-node-smaller a-ttt))
        (lookup n (three-node-left a-ttt))]
       [(> n (three-node-larger a-ttt))
        (lookup n (three-node-right a-ttt))]
       [else
         (lookup n (three-node-middle a-ttt))])]))

(check-expect (lookup 2 TTT1) #t)
(check-expect (lookup 2 TTT11) #t)
(check-expect (lookup -3 TTT11) #t)
(check-expect (lookup 6 TTT11) #t)
(check-expect (lookup -4 TTT11) #t)
(check-expect (lookup 10 TTT11) #f)


;; Number TTT -> TTT
;; insert a number into a 2-3 tree
;;
;; Examples:
;;  - given: 5 (make-two-node 2 NONE NONE)
;;  - returns: (make-three-node 2 5 NONE NONE NONE)
;;  - given: 1 (make-two-node 2 NONE NONE)
;;  - returns: (make-three-node 1 2 NONE NONE NONE)
;;  - given: 3 (make-three-node 2 5 NONE NONE NONE)
;;  - return ((make-three-node 2 5 NONE (make-two-node 3 NONE NONE) NONE)
;;
;; Strategy: template for TTT
(define (insert n a-ttt)
  (cond
    [(no-info? a-ttt) (make-two-node n NONE NONE)]
    [(two-node? a-ttt)
     (cond
       [(< n (two-node-num a-ttt))
        (make-three-node n (two-node-num a-ttt) NONE NONE NONE)]
       [(> n (two-node-num a-ttt))
        (make-three-node (two-node-num a-ttt) n NONE NONE NONE)]
       [else (error "already existed value!")])]
    [(three-node? a-ttt)
     (cond
       [(< n (three-node-smaller a-ttt))
        (update-node a-ttt n 'left)]
       [(> n (three-node-larger a-ttt))
        (update-node a-ttt n 'right)]
       [(< (three-node-smaller a-ttt) n (three-node-larger a-ttt))
        (update-node a-ttt n 'middle)]
       [else (error "already existed value!")])]))

;; TTT Number Symbol -> TTT
;; updates a 2-3 tree node structure
;; Stragety: Domain knowledge (TTT)
(define (update-node a-ttt n s)
  (make-three-node
   (three-node-smaller a-ttt)
   (three-node-larger a-ttt)
   (if (symbol=? s 'left)
       (insert n (three-node-left a-ttt))
       (three-node-left a-ttt))
   (if (symbol=? s 'middle)
       (insert n (three-node-middle a-ttt))
       (three-node-middle a-ttt))
   (if (symbol=? s 'right)
       (insert n (three-node-right a-ttt))
       (three-node-right a-ttt))))

(check-expect (insert 6 NONE) (make-two-node 6 NONE NONE))
(check-expect (insert 5 TTT1)
              (make-three-node 2 5 NONE NONE NONE))
(check-expect (insert 1 TTT1)
              (make-three-node 1 2 NONE NONE NONE))
(check-error (insert 2 TTT1) "already existed value!")
(check-expect (insert 2 TTT2)
              (make-three-node 1 3 NONE (make-two-node 2 NONE NONE) NONE))
(check-expect (insert 5 TTT2)
              (make-three-node 1 3 NONE NONE (make-two-node 5 NONE NONE)))
(check-expect (insert -199 TTT2)
              (make-three-node 1 3 (make-two-node -199 NONE NONE) NONE NONE))
(check-error (insert 3 TTT2) "already existed value!")
(check-expect (insert 1.5 TTT11)
              (make-three-node 1 3
                               TTT4-1
                               (make-three-node 1.5 2 NONE NONE NONE)
                               TTT4-2))
(check-expect (insert -6 TTT11)
              (make-three-node 1 3
                               (insert -6 TTT4-1)
                               TTT1
                               TTT4-2))