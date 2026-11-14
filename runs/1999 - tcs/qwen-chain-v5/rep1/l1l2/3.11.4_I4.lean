import ContractForge
open ContractForge

-- 3.11.4/I4: TCM denotes Total Corrective Maintenance

-- L0 spec

structure Input where
  failedAttempts : Nat
  totalMaintenance : Nat
  deriving DecidableEq, Repr

structure Output where
  failedAttempts : Nat
  totalMaintenance : Nat
  succeeded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < i.totalMaintenance
  post := fun i o => o.failedAttempts = i.failedAttempts + 1 ∧
                     (o.succeeded = true ↔ i.totalMaintenance > i.failedAttempts)

example : Spec.pre { failedAttempts := 2, totalMaintenance := 5 } ∧
          Spec.post { failedAttempts := 2, totalMaintenance := 5 }
                    { failedAttempts := 3, totalMaintenance := 5, succeeded := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { failedAttempts := x.failedAttempts + 1,
    totalMaintenance := x.totalMaintenance,
    succeeded := decide (x.totalMaintenance > x.failedAttempts) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
