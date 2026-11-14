import ContractForge
open ContractForge

-- 4.1.1.5: Track to train transmission shall provide the capability to send different speed profiles for specific train categories.
-- compiles: True · rejects_bad_example: True · checked: True

structure SpeedProfile where
  category : String
  speeds   : List Nat
  deriving DecidableEq, Repr

structure Input where
  profiles : List SpeedProfile
  deriving DecidableEq, Repr

structure Output where
  selected : SpeedProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.profiles.Nodup
  post := fun i o => o.selected.category = (i.profiles.map (fun p => p.category)).headD ""
                    ∧ o.selected.speeds = (i.profiles.map (fun p => p.speeds)).headD []

example : Spec.pre { profiles := [{ category := "CategoryA", speeds := [50, 60, 70] },
                                    { category := "CategoryB", speeds := [80, 90] }] } ∧
          Spec.post { profiles := [{ category := "CategoryA", speeds := [50, 60, 70] },
                                    { category := "CategoryB", speeds := [80, 90] }] }
                    { selected := { category := "CategoryA", speeds := [50, 60, 70] } } := by
  unfold Spec; decide
