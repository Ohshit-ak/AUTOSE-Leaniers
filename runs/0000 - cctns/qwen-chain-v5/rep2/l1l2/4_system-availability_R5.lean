import ContractForge
open ContractForge

-- 4/system-availability/R5: In the event of any software or hardware failure, it must be possible to restore the System (with inline synchronization) within no more than <xx> hours.

-- L0 spec

structure Input where
  failedAttempts : Nat
  systemState    : String
  deriving DecidableEq, Repr

structure Output where
  restored       : Bool
  systemState    : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < 24
  post := fun i o => o.restored = true ↔
                     (i.failedAttempts + 1 ≤ 24) ∧
                     o.systemState = "normal" ∧
                     o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { failedAttempts := 1, systemState := "normal" } ∧
          Spec.post { failedAttempts := 1, systemState := "normal" }
                    { restored := true, systemState := "normal", failedAttempts := 2 } := by
  unfold Spec; decide

example : Spec.pre { failedAttempts := 23, systemState := "normal" } ∧
          Spec.post { failedAttempts := 23, systemState := "normal" }
                    { restored := true, systemState := "normal", failedAttempts := 24 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { restored := true, systemState := "normal", failedAttempts := x.failedAttempts + 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
