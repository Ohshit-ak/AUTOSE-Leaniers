import ContractForge
open ContractForge

-- 11.4.4: 11.4.4 When operating with location dependent addressing, no manual action shall be required to update the system when a mobile moves between locations. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mobileId : Nat
  oldLocation : Nat
  newLocation : Nat
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileId ≠ 0 ∧ i.oldLocation < 100 ∧ i.newLocation < 100
  post := fun i o => o.updated = true ↔
    (i.oldLocation ≠ i.newLocation →
      (i.oldLocation = 0 → o.updated = true) ∧
      (i.newLocation = 0 → o.updated = true))

example : Spec.pre { mobileId := 1, oldLocation := 5, newLocation := 10 } ∧
          Spec.post { mobileId := 1, oldLocation := 5, newLocation := 10 }
                    { updated := true } := by
  unfold Spec; decide
