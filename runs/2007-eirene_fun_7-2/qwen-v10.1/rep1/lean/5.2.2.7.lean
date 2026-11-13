import ContractForge
open ContractForge

-- 5.2.2.7: 5.2.2.7 If the functional identity of the connected party contains an alphanumeric description, this shall also be displayed. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  description : String
  deriving DecidableEq, Repr

structure Output where
  displayed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.description ≠ ""
  post := fun i o => o.displayed = i.description

example : Spec.pre { description := "Cab Radio" } ∧
          Spec.post { description := "Cab Radio" } { displayed := "Cab Radio" } := by
  unfold Spec; decide
