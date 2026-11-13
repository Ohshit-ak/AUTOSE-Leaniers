import ContractForge
open ContractForge

-- 2/I5: 2.5 System Integration and Data Exchange: OM information must be exchangeable, based on established standards, between systems involved in the investigation, identification, confirmation, and reporting of a health event.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  omData : String
  deriving DecidableEq, Repr

structure Output where
  exchanged : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.omData ≠ ""
  post := fun i o => o.exchanged = true ↔
    (i.omData.length ≤ 1024 ∧ i.omData.toList.all Char.isAlphanum = true)

example : Spec.pre { omData := "OM1234567890" } ∧
          Spec.post { omData := "OM1234567890" }
                    { exchanged := true } := by
  unfold Spec; decide
