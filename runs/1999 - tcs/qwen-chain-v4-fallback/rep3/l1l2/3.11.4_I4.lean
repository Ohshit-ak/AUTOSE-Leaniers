import ContractForge
open ContractForge

-- 3.11.4/I4: TCM denotes Total Corrective Maintenance

-- L0 spec

structure Input where
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  failedAttempts : Nat
  succeeded      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < 3
  post := fun i o => o.succeeded ↔ i.failedAttempts < 3 ∧
                     o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { failedAttempts := 2 } ∧
          Spec.post { failedAttempts := 2 }
                    { succeeded := true, failedAttempts := 3 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { failedAttempts := x.failedAttempts + 1, succeeded := x.failedAttempts < 3 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
