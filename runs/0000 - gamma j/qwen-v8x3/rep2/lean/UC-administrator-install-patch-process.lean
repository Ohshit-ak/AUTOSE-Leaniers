import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  version : String
  patch   : String
  deriving DecidableEq, Repr

structure Output where
  version : String
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.version ≠ "" ∧ i.patch ≠ ""
  post := fun i o => o.success ↔
    (o.version = i.version ∧ i.patch = o.version) ∧
    o.success = true

example : Spec.pre { version := "1.0.0", patch := "1.0.1" } ∧ Spec.post { version := "1.0.0", patch := "1.0.1" } { version := "1.0.1", success := false } := by
  unfold Spec; decide
