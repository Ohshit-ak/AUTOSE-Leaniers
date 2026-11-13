import ContractForge
open ContractForge

-- 3.1.3/R1: REQ-1: KeePass must be downloaded and installed
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  version : String
  downloaded : Bool
  deriving DecidableEq, Repr

structure Output where
  installed : Bool
  versionInstalled : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.version ≠ "" ∧ i.downloaded
  post := fun i o => (o.installed = true ↔ i.downloaded) ∧
                     (o.installed = false → o.versionInstalled = "") ∧
                     (o.installed = true → o.versionInstalled = i.version)

example : Spec.pre { version := "2.48", downloaded := true } ∧ Spec.post { version := "2.48", downloaded := true } { installed := true, versionInstalled := "2.48" } := by
  unfold Spec; decide
