import ContractForge
open ContractForge

-- 0/S5: The following description responds to these comments and criticism by arguing how and where revisions and updates of the work presented in this deliverable will be implemented in subsequent results of WP 2.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  revisions : List String
  updates   : List String
  deriving DecidableEq, Repr

structure Output where
  implemented : Bool
  deriving DecidableEq, Repr

-- IMPL: The revisions and updates will be implemented in subsequent results of WP 2 by checking if the revisions and updates are present in the input.

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.implemented = true ↔
    (i.revisions.Nodup ∧ i.updates.Nodup) ∧
    (i.revisions.length + i.updates.length > 0)

example : Spec.pre { revisions := ["rev1", "rev2"], updates := ["up1"] } ∧
          Spec.post { revisions := ["rev1", "rev2"], updates := ["up1"] }
                    { implemented := true } := by
  unfold Spec; decide
