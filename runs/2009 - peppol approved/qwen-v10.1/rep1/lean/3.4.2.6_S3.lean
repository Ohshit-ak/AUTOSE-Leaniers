import ContractForge
open ContractForge

-- 3.4.2.6/S3: (Bausa O. and Boujraf A. 2009) Requirement In stage 4 it MUST be possible to discover the verified electronic address for an identified party.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  partyId : String
  verifiedAddresses : List String
  deriving DecidableEq, Repr

structure Output where
  verifiedAddress : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.partyId ≠ "" ∧ i.verifiedAddresses.Nodup
  post := fun i o => o.verifiedAddress ∈ i.verifiedAddresses ∧
                     (o.verifiedAddress = i.verifiedAddresses.head ↔ i.verifiedAddresses.length = 1)

example : Spec.pre { partyId := "12345", verifiedAddresses := ["addr1@example.com", "addr2@example.com"] } ∧
          Spec.post { partyId := "12345", verifiedAddresses := ["addr1@example.com", "addr2@example.com"] }
                    { verifiedAddress := "addr1@example.com" } := by
  unfold Spec; decide
