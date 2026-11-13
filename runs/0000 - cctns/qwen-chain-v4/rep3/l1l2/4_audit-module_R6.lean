import ContractForge
open ContractForge

-- 4/audit-module/R6: The System must be able to capture and store violations (i.e. A user's attempts to access a case to which he is denied access), and (where violations can validly be attempted) attempted violations, of access control mechanisms.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { user := x.user, caseId := x.caseId, access := x.access, violation := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
