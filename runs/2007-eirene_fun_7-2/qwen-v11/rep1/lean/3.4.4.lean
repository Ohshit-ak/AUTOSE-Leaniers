import ContractForge
open ContractForge

-- 3.4.4: 3.4.4 Set-up times shall include the time required for any translation of functional numbers internal to the EIRENE network. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functionalNumber : Nat
  deriving DecidableEq, Repr

structure Output where
  setupTime : Nat
  translated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber > 0
  post := fun i o => o.setupTime ≥ i.functionalNumber ∧
                     (o.translated = true ↔ i.functionalNumber > 10)

example : Spec.pre { functionalNumber := 15 } ∧
          Spec.post { functionalNumber := 15 }
                    { setupTime := 15, translated := true } := by
  unfold Spec; decide
