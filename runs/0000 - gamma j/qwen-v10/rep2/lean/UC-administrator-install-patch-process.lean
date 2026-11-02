import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.
-- compiles: True · rejects_bad_example: True · checked: True

structure Patch where
  version : Nat
  name    : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : Nat
  patches         : List Patch
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : Nat
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, its source is switched on,
-- and it is not filtered out (rating 0 is never shown)
def Wanted (i : Input) (it : Patch) : Bool :=
  it.version > i.webStoreVersion

def Spec : Contract Input Output where
  pre  := fun i => i.patches.Nodup
  post := fun i o => (o.webStoreVersion = i.webStoreVersion + 1 ↔ o.success = true) ∧
                     (o.success = false ↔ i.patches = []) ∧
                     o.patches = i.patches.filter (Wanted i)

example : Spec.pre { webStoreVersion := 10, patches := [{ version := 11, name := "patch1" }] } ∧
          Spec.post { webStoreVersion := 10, patches := [{ version := 11, name := "patch1" }] }
                    { webStoreVersion := 11, patches := [{ version := 11, name := "patch1" }], success := true } := by
  unfold Spec; decide

example : Spec.pre { webStoreVersion := 10, patches := [] } ∧
          Spec.post { webStoreVersion := 10, patches := [] }
                    { webStoreVersion := 10, patches := [], success := false } := by
  unfold Spec; decide
