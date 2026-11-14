import ContractForge
open ContractForge

-- Design Constraints/I9: Delete (deleting will be allowed only if no child records are created)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  distributorId : Nat
  childRecords   : Nat
  deriving DecidableEq, Repr

structure Output where
  deleted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.deleted = true ↔
    (i.childRecords = 0)

example : Spec.pre { distributorId := 123, childRecords := 0 } ∧
          Spec.post { distributorId := 123, childRecords := 0 }
                    { deleted := true } := by
  unfold Spec; decide
