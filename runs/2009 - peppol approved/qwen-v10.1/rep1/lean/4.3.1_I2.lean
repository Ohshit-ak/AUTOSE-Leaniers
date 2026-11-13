import ContractForge
open ContractForge

-- 4.3.1/I2: flexibility to meet the dynamics of the organisational and legal changes and
-- compiles: True · rejects_bad_example: True · checked: True

structure Config where
  settings : List String
  deriving DecidableEq, Repr

structure Input where
  settings : List String
  deriving DecidableEq, Repr

structure Output where
  updatedSettings : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.settings.Nodup
  post := fun i o => o.updatedSettings = i.settings ++ (i.settings.filter (fun s => ¬ o.updatedSettings.contains s))

example : Spec.pre { settings := [] } ∧ Spec.post { settings := [] } { updatedSettings := [] } := by
  unfold Spec; decide
