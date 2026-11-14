import ContractForge
open ContractForge

-- 5.4.2i: 5.4.2i The design of the equipment shall make it possible to install it within a cab complying with the requirements of UIC fiche 651 concerning the layout of cab equipment . (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cabLayout : String
  deriving DecidableEq, Repr

structure Output where
  installed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabLayout ≠ ""
  post := fun i o => o.installed = true ↔
    i.cabLayout = "UIC fiche 651 concerning the layout of cab equipment"

example : Spec.pre { cabLayout := "UIC fiche 651 concerning the layout of cab equipment" } ∧
          Spec.post { cabLayout := "UIC fiche 651 concerning the layout of cab equipment" }
                    { installed := true } := by
  unfold Spec; decide
