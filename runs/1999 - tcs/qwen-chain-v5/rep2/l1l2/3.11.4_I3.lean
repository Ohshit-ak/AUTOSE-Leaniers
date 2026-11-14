import ContractForge
open ContractForge

-- 3.11.4/I3: TPM denotes Total Preventative Maintenance

-- L0 spec

structure Input where
  TPM : Nat
  failures : Nat
  deriving DecidableEq, Repr

structure Output where
  TPM : Nat
  failures : Nat
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.TPM
  post := fun i o => (o.success = true ↔ i.failures = 0) ∧
                     (o.success = false → o.TPM = i.TPM) ∧
                     o.failures = i.failures

example : Spec.pre { TPM := 10, failures := 0 } ∧
          Spec.post { TPM := 10, failures := 0 }
                    { TPM := 10, failures := 0, success := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { TPM := x.TPM,
    failures := x.failures,
    success := decide (x.failures = 0) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
