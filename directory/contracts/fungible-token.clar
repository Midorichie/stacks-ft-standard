(define-constant FT-NAME "MyToken")
(define-constant FT-SYMBOL "MTK")
(define-constant DECIMALS u6)
(define-constant TOTAL-SUPPLY u1000000)

(define-data-var balances (map principal uint) {})
(define-data-var allowances (map { owner: principal, spender: principal } uint) {})
(define-data-var initialized bool false)

(define-private (assert-init)
  (asserts! (not (var-get initialized)) (err u100)))

(define-public (initialize (owner principal) (amount uint))
  (begin
    (assert-init)
    (var-set balances (map-set? (var-get balances) owner amount))
    (var-set initialized true)
    (ok amount)))

(define-public (transfer (to principal) (value uint))
  (let (
        (sender tx-sender)
        (current (default-to u0 (map-get? (var-get balances) sender)))
       )
    (begin
      (asserts! (>= current value) (err u101))
      (var-set balances (map-set (var-get balances) sender (- current value)))
      (var-set balances (map-set? (var-get balances) to (+ (default-to u0 (map-get? (var-get balances) to)) value)))
      (ok value))))

(define-public (approve (spender principal) (value uint))
  (let ((owner tx-sender))
    (var-set allowances (map-set (var-get allowances) { owner: owner, spender: spender } value))
    (ok value)))

(define-public (transfer-from (from principal) (to principal) (value uint))
  (let (
        (spender tx-sender)
        (allow (default-to u0 (map-get? (var-get allowances) { owner: from, spender: spender })))
        (from-bal (default-to u0 (map-get? (var-get balances) from)))
       )
    (begin
      (asserts! (>= allow value) (err u102))
      (asserts! (>= from-bal value) (err u101))
      (var-set allowances (map-set (var-get allowances) { owner: from, spender: spender } (- allow value)))
      (var-set balances (map-set (var-get balances) from (- from-bal value)))
      (var-set balances (map-set? (var-get balances) to (+ (default-to u0 (map-get? (var-get balances) to)) value)))
      (ok value))))

(define-read-only (get-balance (owner principal))
  (ok (default-to u0 (map-get? (var-get balances) owner))))

(define-read-only (get-allowance (owner principal) (spender principal))
  (ok (default-to u0 (map-get? (var-get allowances) { owner: owner, spender: spender }))))
