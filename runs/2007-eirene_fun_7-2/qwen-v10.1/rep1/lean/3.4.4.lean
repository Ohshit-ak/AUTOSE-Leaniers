import ContractForge
open ContractForge

-- 3.4.4: 3.4.4 Set-up times shall include the time required for any translation of functional numbers internal to the EIRENE network. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  functionalNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  setUpTime : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.Nodup
  post := fun i o => o.setUpTime ≥ i.functionalNumbers.length

example : Spec.pre { functionalNumbers := ["123", "456"] } ∧
          Spec.post { functionalNumbers := ["123", "456"] }
                    { setUpTime := 2 } := by
  unfold Spec; decide
