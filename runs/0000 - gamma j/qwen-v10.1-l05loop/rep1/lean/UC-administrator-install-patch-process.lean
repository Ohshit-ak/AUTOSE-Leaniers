import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: True · checked: True

structure Patch where
  version : Nat
  deriving DecidableEq, Repr

structure SystemState where
  patchInstalled : Bool
  deriving DecidableEq, Repr

structure Input where
  patch : Patch
  patchInstalled : Bool
  deriving DecidableEq, Repr

structure Output where
  patchInstalled : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patch.version > 0
  post := fun i o => o.patchInstalled = true ∧
                     (o.patchInstalled = true ↔
                      i.patchInstalled = false)

example : Spec.pre { patch := { version := 2 }, patchInstalled := false } ∧
          Spec.post { patch := { version := 2 }, patchInstalled := false }
                    { patchInstalled := true } := by
  unfold Spec; decide
