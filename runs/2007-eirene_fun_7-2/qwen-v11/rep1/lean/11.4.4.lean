import ContractForge
open ContractForge

-- 11.4.4: 11.4.4 When operating with location dependent addressing, no manual action shall be required to update the system when a mobile moves between locations. (M)
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  mobileId : Nat
  oldLocation : Nat
  newLocation : Nat
  updated : Bool
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  mobileId : Nat
  oldLocation : Nat
  newLocation : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileId ≠ 0 ∧ 0 ≤ i.oldLocation ∧ i.oldLocation < 100 ∧
                  0 ≤ i.newLocation ∧ i.newLocation < 100
  post := fun i o => o.updated = true ∧
                     (i.mobileId = i.mobileId ∧
                      i.oldLocation = i.oldLocation ∧
                      i.newLocation = i.newLocation) →
                     (o.mobileId = i.mobileId ∧
                      o.oldLocation = i.oldLocation ∧
                      o.newLocation = i.newLocation)

example : Spec.pre { mobileId := 1, oldLocation := 5, newLocation := 10, updated := true } ∧
          Spec.post { mobileId := 1, oldLocation := 5, newLocation := 10, updated := true }
                    { mobileId := 1, oldLocation := 5, newLocation := 10, updated := true } := by
  unfold Spec; decide
