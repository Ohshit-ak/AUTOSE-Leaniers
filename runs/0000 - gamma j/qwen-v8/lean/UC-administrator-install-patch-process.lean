import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  version : String
  deriving DecidableEq, Repr

structure Output where
  version : String
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.version ≠ ""
  post := fun i o => o.success = true ∧ o.version = i.version

example : Spec.pre { version := "1.2.3" } ∧
          Spec.post { version := "1.2.3" } { success := true, version := "1.2.3" } := by
  unfold Spec; decide
