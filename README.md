;; Define constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-already-voted (err u101))
(define-constant err-invalid-option (err u102))
(define-constant err-voting-closed (err u103))
(define-constant err-not-whitelisted (err u104))

;; Define NFT for votes
(define-non-fungible-token vote-nft uint)

;; Define data variables
(define-data-var total-votes uint u0)
(define-data-var voting-start-block uint u0)
(define-data-var voting-end-block uint u0)

;; Define data maps
(define-map voter-nft-count principal uint)
(define-map whitelist principal bool)
(define-map vote-options uint (string-ascii 50))
(define-map vote-counts uint uint)
(define-map has-voted principal bool)

;; Events
(define-public (print-event (event (string-ascii 50)) (data (string-ascii 50)))
  (ok (print {event: event, data: data}))
)

;; Admin functions

(define-public (set-voting-period (start uint) (end uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (asserts! (> end start) (err u105))
    (var-set voting-start-block start)
    (var-set voting-end-block end)
    (ok true)
  )
)

(define-public (add-voter (voter principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set whitelist voter true)
    (try! (print-event "voter_added" (to-ascii (buff-to-string-be (principal-to-buff voter)))))
    (ok true)
  )
)

(define-public (set-vote-option (id uint) (option (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    (map-set vote-options id option)
    (try! (print-event "vote_option_set" (concat (uint-to-ascii id) option)))
    (ok true)
  )
)

;; Voting function

(define-public (vote (option-id uint))
  (let 
    (
      (voter tx-sender)
      (current-block block-height)
    )
    (asserts! (>= current-block (var-get voting-start-block)) err-voting-closed)
    (asserts! (<= current-block (var-get voting-end-block)) err-voting-closed)
    (asserts! (default-to false (map-get? whitelist voter)) err-not-whitelisted)
    (asserts! (not (default-to false (map-get? has-voted voter))) err-already-voted)
    (asserts! (is-some (map-get? vote-options option-id)) err-invalid-option)
    
    (try! (nft-mint? vote-nft (var-get total-votes) voter))
    (map-set voter-nft-count voter (+ (default-to u0 (map-get? voter-nft-count voter)) u1))
    (map-set has-voted voter true)
    (map-set vote-counts option-id (+ (default-to u0 (map-get? vote-counts option-id)) u1))
    (var-set total-votes (+ (var-get total-votes) u1))
    
    (try! (print-event "vote_cast" (concat (to-ascii (buff-to-string-be (principal-to-buff voter))) (uint-to-ascii option-id))))
    (ok "Vote registered, and NFT minted!")
  )
)

;; Read-only functions

(define-read-only (get-total-votes)
  (ok (var-get total-votes))
)

(define-read-only (get-nft-count (voter principal))
  (ok (default-to u0 (map-get? voter-nft-count voter)))
)

(define-read-only (get-vote-option (id uint))
  (ok (map-get? vote-options id))
)

(define-read-only (get-vote-count (option-id uint))
  (ok (default-to u0 (map-get? vote-counts option-id)))
)

(define-read-only (is-voter-whitelisted (voter principal))
  (ok (default-to false (map-get? whitelist voter)))
)

(define-read-only (has-voter-voted (voter principal))
  (ok (default-to false (map-get? has-voted voter)))
)

(define-read-only (get-voting-period)
  (ok {start: (var-get voting-start-block), end: (var-get voting-end-block)})
)