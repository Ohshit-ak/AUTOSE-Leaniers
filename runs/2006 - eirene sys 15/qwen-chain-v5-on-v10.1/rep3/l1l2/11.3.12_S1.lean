import ContractForge
open ContractForge

-- 11.3.12/S1: The result of the deregistration procedure shall be sent back to the mobile.

-- L0 spec

structure Mobile where
  number : Nat
  deriving DecidableEq, Repr

structure DeregistrationResult where
  success : Bool
  message : String
  deriving DecidableEq, Repr

structure Input where
  mobileNumber : Nat
  exists_       : Bool
  deriving DecidableEq, Repr

structure Output where
  mobileNumber : Nat
  result       : DeregistrationResult
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileNumber ≠ 0
  post := fun i o => o.mobileNumber = i.mobileNumber ∧
                     (o.result.success = true ↔ i.exists_) ∧
                     (o.result.success = false →
                      (i.exists_ → o.result.message = "Mobile number not found") ∧
                      (¬ i.exists_ → o.result.message = "Deregistration successful"))

example : Spec.pre { mobileNumber := 12345, exists_ := true } ∧ Spec.post { mobileNumber := 12345, exists_ := true } { mobileNumber := 12345, result := { success := true, message := "" } } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { mobileNumber := x.mobileNumber,
    result := 
      { success := decide (x.exists_),
        message := if decide (x.exists_) then "Mobile number not found" else "Deregistration successful" } }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
