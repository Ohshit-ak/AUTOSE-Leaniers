import ContractForge
open ContractForge

-- 5.4.2i: 5.4.2i The design of the equipment shall make it possible to install it within a cab complying with the requirements of UIC fiche 651 concerning the layout of cab equipment . (M)
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  cabLayout : String
  cabRequirements : String
  deriving DecidableEq, Repr

structure Output where
  installationPossible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabLayout ≠ "" ∧ i.cabRequirements ≠ ""
  post := fun i o => o.installationPossible = true ↔
    i.cabLayout.toList.all (fun c => c.isAlphanum) = true ∧
    i.cabRequirements.toList.all (fun c => c.isAlphanum) = true ∧
    i.cabLayout.length ≤ 100 ∧
    i.cabRequirements.length ≤ 100

example : Spec.pre { cabLayout := "UIC651", cabRequirements := "UIC651" } ∧
          Spec.post { cabLayout := "UIC651", cabRequirements := "UIC651" }
                    { installationPossible := true } := by
  unfold Spec; decide
