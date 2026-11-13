import ContractForge
open ContractForge

-- Design Constraints/I1: The voucher will be created ONLY by the authorized person.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  creator : String
  authorized : Bool
  deriving DecidableEq, Repr

structure Output where
  created : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.authorized
  post := fun i o => o.created = true ↔ i.authorized

example : Spec.pre { creator := "Alice", authorized := true } ∧
          Spec.post { creator := "Alice", authorized := true }
                    { created := true } := by
  unfold Spec; decide
