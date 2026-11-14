import ContractForge
open ContractForge

-- 11.2.2.1: 11.2.2.1 Functional numbers must be unique within the domain of operation. Since the number must be independent of networks, each number must be unique across all networks (including implementation of EIRENE facilities on public networks). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functionalNumber : String
  allNetworks      : List String
  deriving DecidableEq, Repr

structure Output where
  unique : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber.length = 16 ∧
                   i.functionalNumber.toList.all (· ≠ '0') = true
  post := fun i o => (o.unique = true ↔
    ∃ fn ∈ i.allNetworks, fn = i.functionalNumber) ∧
                     (o.unique = false ↔
    ∀ fn ∈ i.allNetworks, fn ≠ i.functionalNumber)

example : Spec.pre { functionalNumber := "a1a1a1a1a1a1a1a1", allNetworks := ["1234567890123456", "7890123456789012"] } ∧ Spec.post { functionalNumber := "a1a1a1a1a1a1a1a1", allNetworks := ["1234567890123456", "7890123456789012"] } { unique := false } := by
  unfold Spec; decide
