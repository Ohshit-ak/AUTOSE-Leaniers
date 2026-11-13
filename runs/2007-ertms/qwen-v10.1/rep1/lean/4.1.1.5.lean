import ContractForge
open ContractForge

-- 4.1.1.5: Track to train transmission shall provide the capability to send different speed profiles for specific train categories.
-- compiles: False · rejects_bad_example: None · checked: False

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
  post := fun i o => o.selected.category = i.profiles.map (fun p => p.category).head
                    ∧ o.selected.speeds = i.profiles.map (fun p => p.speeds).head

example : Spec.pre { profiles := [{ category := "category1", speeds := [50, 60] },
                                   { category := "category2", speeds := [70, 80] }] } ∧
          Spec.post { profiles := [{ category := "category1", speeds := [50, 60] },
                                   { category := "category2", speeds := [70, 80] }] }
                    { selected := { category := "category1", speeds := [50, 60] } } := by
  unfold Spec; decide
