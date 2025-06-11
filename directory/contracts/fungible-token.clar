;; Enhanced Fungible Token Contract
;; Fixes validation warnings by using direct validation in operations

(define-constant FT-NAME "MyToken")
(define-constant FT-SYMBOL "MTK")
(define-constant DECIMALS u6)
(define-constant TOTAL-SUPPLY u1000000)

;; Error constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-BALANCE (err u101))
(define-constant ERR-INSUFFICIENT-ALLOWANCE (err u102))
(define-constant ERR-ALREADY-INITIALIZED (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-SAME-SENDER-RECIPIENT (err u105))
(define-constant ERR-INVALID-PRINCIPAL (err u106))

;; Data variables
(define-map balances principal uint)
(define-map allowances { owner: principal, spender: principal } uint)
(define-data-var contract-owner principal tx-sender)
(define-data-var initialized bool false)
(define-data-var total-supply uint u0)

;; Events for better tracking
(define-map transfer-events 
  { tx-id: uint } 
  { from: principal, to: principal, amount: uint, block-height: uint })
(define-data-var event-counter uint u0)

;; Authorization check
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner)))

;; Initialization guard
(define-private (assert-not-initialized)
  (ok (asserts! (not (var-get initialized)) ERR-ALREADY-INITIALIZED)))

;; Validation functions (returning bool instead of validated values)
(define-private (is-valid-amount (amount uint))
  (> amount u0))

(define-private (is-valid-principal (principal-to-check principal))
  (not (is-eq principal-to-check 'SP000000000000000000002Q6VF78)))

(define-private (is-safe-amount (amount uint) (max-allowed uint))
  (and (> amount u0) (<= amount max-allowed)))

(define-private (are-valid-transfer-participants (from principal) (to principal))
  (and 
    (is-valid-principal from)
    (is-valid-principal to)
    (not (is-eq from to))))

;; Enhanced initialization with direct validation
(define-public (initialize (initial-owner principal) (amount uint))
  (begin
    (try! (assert-not-initialized))
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-principal initial-owner) ERR-INVALID-PRINCIPAL)
    (asserts! (is-safe-amount amount TOTAL-SUPPLY) ERR-INVALID-AMOUNT)
    
    (map-set balances initial-owner amount)
    (var-set total-supply amount)
    (var-set initialized true)
    (ok amount)))

;; Enhanced transfer with direct validation
(define-public (transfer (to principal) (amount uint))
  (let (
        (sender tx-sender)
        (sender-balance (default-to u0 (map-get? balances sender)))
       )
    (begin
      (asserts! (is-valid-principal to) ERR-INVALID-PRINCIPAL)
      (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
      (asserts! (are-valid-transfer-participants sender to) ERR-SAME-SENDER-RECIPIENT)
      (asserts! (>= sender-balance amount) ERR-INSUFFICIENT-BALANCE)
      
      ;; Update balances
      (map-set balances sender (- sender-balance amount))
      (map-set balances to (+ (default-to u0 (map-get? balances to)) amount))
      
      ;; Log transfer event
      (log-transfer-event sender to amount)
      
      (ok amount))))

;; Enhanced approve function with direct validation
(define-public (approve (spender principal) (amount uint))
  (let ((owner tx-sender))
    (begin
      (asserts! (is-valid-principal spender) ERR-INVALID-PRINCIPAL)
      (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
      (asserts! (are-valid-transfer-participants owner spender) ERR-SAME-SENDER-RECIPIENT)
      
      (map-set allowances { owner: owner, spender: spender } amount)
      (ok amount))))

;; Enhanced transfer-from with direct validation
(define-public (transfer-from (from principal) (to principal) (amount uint))
  (let (
        (spender tx-sender)
        (allowance (default-to u0 (map-get? allowances { owner: from, spender: spender })))
        (from-balance (default-to u0 (map-get? balances from)))
       )
    (begin
      (asserts! (is-valid-principal from) ERR-INVALID-PRINCIPAL)
      (asserts! (is-valid-principal to) ERR-INVALID-PRINCIPAL)
      (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
      (asserts! (are-valid-transfer-participants from to) ERR-SAME-SENDER-RECIPIENT)
      (asserts! (>= allowance amount) ERR-INSUFFICIENT-ALLOWANCE)
      (asserts! (>= from-balance amount) ERR-INSUFFICIENT-BALANCE)
      
      ;; Update allowance and balances
      (map-set allowances { owner: from, spender: spender } (- allowance amount))
      (map-set balances from (- from-balance amount))
      (map-set balances to (+ (default-to u0 (map-get? balances to)) amount))
      
      ;; Log transfer event
      (log-transfer-event from to amount)
      
      (ok amount))))

;; Mint function with direct validation
(define-public (mint (to principal) (amount uint))
  (let (
        (current-supply (var-get total-supply))
       )
    (begin
      (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
      (asserts! (is-valid-principal to) ERR-INVALID-PRINCIPAL)
      (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
      (asserts! (<= (+ current-supply amount) TOTAL-SUPPLY) ERR-INVALID-AMOUNT)
      
      (map-set balances to (+ (default-to u0 (map-get? balances to)) amount))
      (var-set total-supply (+ current-supply amount))
      
      (log-transfer-event tx-sender to amount)
      (ok amount))))

;; Burn function with validation
(define-public (burn (amount uint))
  (let (
        (sender tx-sender)
        (sender-balance (default-to u0 (map-get? balances sender)))
        (current-supply (var-get total-supply))
       )
    (begin
      (asserts! (is-valid-amount amount) ERR-INVALID-AMOUNT)
      (asserts! (>= sender-balance amount) ERR-INSUFFICIENT-BALANCE)
      
      (map-set balances sender (- sender-balance amount))
      (var-set total-supply (- current-supply amount))
      
      (ok amount))))

;; Transfer ownership with validation
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-principal new-owner) ERR-INVALID-PRINCIPAL)
    (var-set contract-owner new-owner)
    (ok new-owner)))

;; Private function to log transfer events
(define-private (log-transfer-event (from principal) (to principal) (amount uint))
  (let ((event-id (var-get event-counter)))
    (map-set transfer-events 
      { tx-id: event-id }
      { from: from, to: to, amount: amount, block-height: block-height })
    (var-set event-counter (+ event-id u1))))

;; Read-only functions
(define-read-only (get-balance (owner principal))
  (ok (default-to u0 (map-get? balances owner))))

(define-read-only (get-allowance (owner principal) (spender principal))
  (ok (default-to u0 (map-get? allowances { owner: owner, spender: spender }))))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-contract-owner)
  (ok (var-get contract-owner)))

(define-read-only (is-initialized)
  (ok (var-get initialized)))

(define-read-only (get-token-info)
  (ok {
    name: FT-NAME,
    symbol: FT-SYMBOL,
    decimals: DECIMALS,
    total-supply: (var-get total-supply),
    max-supply: TOTAL-SUPPLY
  }))

(define-read-only (get-transfer-event (event-id uint))
  (map-get? transfer-events { tx-id: event-id }))
