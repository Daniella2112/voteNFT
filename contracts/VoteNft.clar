(define-non-fungible-token vote-nft uint)

(define-data-var total-votes uint u0)

(define-map voter-nft-count {voter: principal} {count: uint})



(define-public (vote)
  (begin
    ;; Increase the total number of votes
    (let ((new-total-votes (+ (var-get total-votes) u1)))
      (var-set total-votes new-total-votes)
    
      ;; Mint a new NFT to the voter
      (let ((voter tx-sender)
            (vote-nft-id new-total-votes))
        (try! (nft-mint? vote-nft vote-nft-id voter))
      
        ;; Update the voter's NFT count
        (let ((current-count (default-to u0 (get count (map-get? voter-nft-count {voter: voter})))))
          (map-set voter-nft-count {voter: voter} {count: (+ current-count u1)})
        )
        (ok "Vote registered, and NFT minted!")
      )
    )
  )


)

;; Get the total number of votes cast
(define-read-only (get-total-votes)
  (ok (var-get total-votes))
)

;; Get the number of NFTs a user has
(define-read-only (get-nft-count (voter principal))
  (ok (default-to u0 (get count (map-get? voter-nft-count {voter: voter}))))
)