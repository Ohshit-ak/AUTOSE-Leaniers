import ContractForge
open ContractForge

-- 2.5.3/S1: Systems supporting OM must be able to create and send messages for laboratory test requests.

-- L0 spec

structure TestRequest where
  patientID : Nat
  testCode  : String
  priority  : Nat
  deriving DecidableEq, Repr

structure Message where
  patientID : Nat
  testCode  : String
  priority  : Nat
  sent      : Bool
  deriving DecidableEq, Repr

structure Input where
  patientID : Nat
  testCode  : String
  priority  : Nat
  deriving DecidableEq, Repr

structure Output where
  sent      : Bool
  patientID : Nat
  testCode  : String
  priority  : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.patientID ≠ 0 ∧ i.testCode ≠ "" ∧ 1 ≤ i.priority
  post := fun i o => o.sent = true ∧
                     o.patientID = i.patientID ∧
                     o.testCode = i.testCode ∧
                     o.priority = i.priority

example : Spec.pre { patientID := 123, testCode := "A1", priority := 1 } ∧
          Spec.post { patientID := 123, testCode := "A1", priority := 1 }
                    { sent := true, patientID := 123, testCode := "A1", priority := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { sent := true, patientID := x.patientID, testCode := x.testCode, priority := x.priority }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
