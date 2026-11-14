import ContractForge
open ContractForge

-- 0/S5: The following description responds to these comments and criticism by arguing how and where revisions and updates of the work presented in this deliverable will be implemented in subsequent results of WP 2.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  version : Nat
  changes : List String
  deriving DecidableEq, Repr

structure Output where
  version : Nat
  changes : List String
  deriving DecidableEq, Repr

-- IMPL: Versioning and Change Log

def Spec : Contract Input Output where
  pre  := fun i => i.version > 0
  post := fun i o => o.version = i.version + 1 ∧
                     o.changes = i.changes

example : Spec.pre { version := 1, changes := ["Fix typos", "Add section on methodology"] } ∧
          Spec.post { version := 1, changes := ["Fix typos", "Add section on methodology"] }
                    { version := 2, changes := ["Fix typos", "Add section on methodology"] } := by
  unfold Spec; decide
