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
  post := fun i o => o.displayed = i.description ∧
                     (o.displayed ≠ i.description → o.displayed.toList.all Char.isAlphanum = true)

example : Spec.pre { description := "5 Cab Radio" } ∧
          Spec.post { description := "5 Cab Radio" } { displayed := "5 Cab Radio" } := by
  unfold Spec; decide
