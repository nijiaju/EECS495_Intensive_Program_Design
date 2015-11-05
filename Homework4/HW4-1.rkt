;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname HW4-1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define-struct add [left right])
(define-struct mul [left right])
;; A BSL-var-expr is one of: 
;; – Number
;; – Symbol 
;; – (make-add BSL-var-expr BSL-var-expr)
;; – (make-mul BSL-var-expr BSL-var-expr)
(define BSL-var-expr-1 666)
(define BSL-var-expr-2 'h)
(define BSL-var-expr-3 (make-add 333 'y))
(define BSL-var-expr-4 (make-mul 'x 11))
(define BSL-var-expr-5 (make-mul (make-add 2 3) 5))
(define BSL-var-expr-6 (make-add (make-mul 2 'x) 'y))
#;
(define (process-BSL-var-expr expr x v)
  (cond
    [(number? expr) ...]
    [(symbol? expr) ...]
    [(add? expr) ... (process-BSL-var-expr (add-left expr) x v) ...
                 ... (process-BSL-var-expr (add-right expr) x v) ...]
    [(mul? expr) ... (process-BSL-var-expr (add-left expr) x v) ...
                 ... (process-BSL-var-expr (add-right expr) x v) ...]))

;; BSL-var-expr Symbol Number -> BSL-var-expr
;; produces a BSL-var-expr with all occurrences of x replaced by v
;;
;; Examples:
;;  - 2247149801 'x 2 => 2247149801
;;  - 'x 'x 2 => 2
;;  - (make-add 'x 5) 'x 2 => (make-add 2 5)
;;
;; Strategy: struc decomp
(define (subst expr x v)
  (cond
    [(number? expr) expr]
    [(symbol? expr)
     (if (symbol=? expr x) v expr)]
    [(add? expr)
     (make-add (subst (add-left expr) x v)
               (subst (add-right expr) x v))]
    [(mul? expr)
     (make-mul (subst (mul-left expr) x v)
               (subst (mul-right expr) x v))]))

(check-expect (subst BSL-var-expr-1 'x 1) 666)
(check-expect (subst BSL-var-expr-2 'x 1) 'h)
(check-expect (subst BSL-var-expr-2 'h 1) 1)
(check-expect (subst BSL-var-expr-3 'y 222) (make-add 333 222))
(check-expect (subst BSL-var-expr-4 'x 11) (make-mul 11 11))

;; Exerciese 337

;; A BSL-expr is one of
;; – Number 
;; – (make-add BSL-var-expr BSL-var-expr)
;; – (make-mul BSL-var-expr BSL-var-expr)

;; BSL-var-expr -> Boolean
;; determines whether a BSL-var-expr is also a BSL-expr
;;
;; Examples:
;;  - BSL-var-expr-1 is a BSL-expr
;;  - BSL-var-expr-2 is not a BSL-expr
;;  - BSL-var-expr-3 is not a BSL-expr
;;
;; Strategy: struc decomp
(define (numeric? expr)
  (cond
    [(number? expr) #t]
    [(symbol? expr) #f]
    [(add? expr)
     (and (numeric? (add-left expr))
          (numeric? (add-right expr)))]
    [(mul? expr)
     (and (numeric? (mul-left expr))
          (numeric? (mul-right expr)))]))

(check-expect (numeric? BSL-var-expr-1) #t)
(check-expect (numeric? BSL-var-expr-2) #f)
(check-expect (numeric? BSL-var-expr-3) #f)
(check-expect (numeric? BSL-var-expr-5) #t)

;; Exercise 338
;;
;; BSL-var-expr -> Number
;; consumes a BSL-var-expr and determines its value if numeric? is true.
;; Otherwise it signals an error.
;;
;; Examples:
;;  - BSL-var-expr-1 => 6
;;  - BSL-var-expr-2 => error
;;  - BSL-var-expr-5 => 5
;;
;; Strategy: struc decomp
(define (eval-variable expr)
  (if (numeric? expr)
      (cond
        [(number? expr) expr]
        [(add? expr) (+ (eval-variable (add-left expr))
                        (eval-variable (add-right expr)))]
        [(mul? expr) (* (eval-variable (mul-left expr))
                        (eval-variable (mul-right expr)))])
      (error "Cannot deal with variables")))

(check-expect (eval-variable BSL-var-expr-1) 666)
(check-expect (eval-variable BSL-var-expr-5) 25)
(check-error (eval-variable BSL-var-expr-3) "Cannot deal with variables")

;; An AL (association list) is [List-of Association].
;; An Association is (cons Symbol (cons Number '())).
(define AssociationList (list (list 'x 2) (list 'y 5) (list 'z 7) (list 'x 3)))

;; BSL-var-expr AL -> Number
;; iteratively applies subst to all associations in AL.
;; If numeric? holds for the result, it determines its value;
;; otherwise it signals the same error as eval-variable.
;; If there are two or more bindings for the same variable in AL,
;; the function uses the first one.
;;
;; Examples:
;;  - BSL-var-expr-6, AssociationList => 9
;;  - BSL-var-expr-2, AssociationList => ERROR
;;
;; Strategy: function composition
(define (eval-variable* ex da)
  (eval-variable (foldl (lambda (association expr)
                          (subst expr (first association) (second association)))
                        ex
                        da)))

(check-expect (eval-variable* BSL-var-expr-6 AssociationList) 9)
(check-error (eval-variable* BSL-var-expr-2 AssociationList)
             "Cannot deal with variables")

;; Exercise 339
(require htdp/docs)

;; S-expr -> BSL-var-expr
;; creates representation of a BSL expression for s (if possible)
;;
;; Examples:
;;  - '4 => 4
;;  - '(+ 1 1) => (make-add 1 1)
;;  - '(+ 1 2 3) => (error "invalid s-expression")
;;  - '(* 1) => (error "invalid s-expression")
;;  - '(* (+ 2 3) (+ 3 4)) => (make-mul (make-add 2 3) (make-add 3 4))
;;
;; Strategy: Structural Decomposition
(define (parse s)
  (local (;; S-expr -> BSL-expr
          (define (parse s)
            (cond
              [(atom? s) (parse-atom s)]
              [else (parse-sl s)]))
          ;; SL -> BSL-expr
          (define (parse-sl s)
            (local ((define L (length s)))
              (cond
                [(< L 3)
                 (error "invalid s-expression")]
                [(and (= L 3) (symbol? (first s)))
                 (cond
                   [(symbol=? (first s) '+)
                    (make-add (parse (second s)) (parse (third s)))]
                   [(symbol=? (first s) '*)
                    (make-mul (parse (second s)) (parse (third s)))]
                   [else (error "invalid s-expression")])]
                [else (error "invalid s-expression")])))
          ;; Atom -> BSL-expr
          (define (parse-atom s)
            (cond
              [(number? s) s]
              [(string? s) (error "invalid s-expression")]
              [(symbol? s) s])))
    (parse s)))
          
(check-expect (parse '5) 5)
(check-expect (parse '(+ 1 1)) (make-add 1 1))
(check-expect (parse '(* (+ 2 3) (+ 3 4)))
              (make-mul (make-add 2 3) (make-add 3 4)))
(check-error (parse '(+ 1 2 3)) "invalid s-expression")
(check-error (parse '(* 1)) "invalid s-expression")
(check-expect (parse 'x) 'x)
(check-expect (parse '(+ x (* y (+ z 6))))
              (make-add 'x
                        (make-mul 'y
                                  (make-add 'z 6))))
(check-error (parse '"666") "invalid s-expression")
(check-error (parse '(- 4 3)) "invalid s-expression")

;; Exercise 340
;; AL Symbol -> Number
;; Returns the first binding value of the given symbol in AL (if possible)
;;
;; AssociationList (list (list 'x 2) (list 'y 5) (list 'z 7) (list 'x 3)))
;; Examples:
;;  - the value of 'x in AssociationList is 2
;;  - Looking up for the value of 'a in AssociationList returns an ERROR
;;
;; Strategy: struc decomp
(define (lookup-con da x)
  (cond
    [(empty? da) (error "Symbol not found")]
    [(cons? da)
     (if (symbol=? x (first (first da)))
         (second (first da))
         (lookup-con (rest da) x))]))

(check-expect (lookup-con AssociationList 'x) 2)
(check-expect (lookup-con AssociationList 'y) 5)
(check-error (lookup-con AssociationList 'a)
             "Symbol not found")

;; Exercise 341

;; BSL-var-expr AL -> Number
;; Evaluate a BSL-var-expr;
;; call lookup-cons whenever there is a symbol.
;; If there are two or more bindings for the same variable in AL,
;; the function uses the first one.
;;
;; Examples:
;;  - BSL-var-expr-6, AssociationList => 9
;;  - BSL-var-expr-2, AssociationList => ERROR
;;
;; Strategy: struct decomp
(define (eval-var-lookup e da)
  (cond
    [(number? e) e]
    [(symbol? e) (lookup-con da e)]
    [(add? e)
     (+ (eval-var-lookup (add-left e) da)
        (eval-var-lookup (add-right e) da))]
    [(mul? e)
     (+ (eval-var-lookup (mul-left e) da)
        (eval-var-lookup (mul-right e) da))]))

(check-expect (eval-var-lookup BSL-var-expr-6 AssociationList) 9)
(check-error (eval-var-lookup BSL-var-expr-2 AssociationList)
             "Symbol not found")