import ContractForge
open ContractForge

-- 0/S17: In reference to this, D2.2 will comprise a short overview of the updated state of practice and the relation to current more detailed results of WP2.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  deriving DecidableEq, Repr

structure Output where
  overview : String
  relation : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.overview ≠ "" ∧ o.relation ≠ ""

example : Spec.pre {} ∧ Spec.post {} { overview := "Short overview of the updated state of practice.", relation := "Relation to current more detailed results of WP2." } := by
  unfold Spec; decide
