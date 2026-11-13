import ContractForge
open ContractForge

-- 4/audit-module/R6: The System must be able to capture and store violations (i.e. A user's attempts to access a case to which he is denied access), and (where violations can validly be attempted) attempted violations, of access control mechanisms.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  user    : String
  caseId  : Nat
  access  : Bool
  deriving DecidableEq, Repr

structure Output where
  user    : String
  caseId  : Nat
  access  : Bool
  violation : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.access = false
  post := fun i o => o.violation = true ∧
                     (o.access = false ↔ i.access = false) ∧
                     (o.user = i.user ∧ o.caseId = i.caseId)

example : Spec.pre { user := "alice", caseId := 123, access := false } ∧
          Spec.post { user := "alice", caseId := 123, access := false }
                    { user := "alice", caseId := 123, access := false, violation := true } := by
  unfold Spec; decide
