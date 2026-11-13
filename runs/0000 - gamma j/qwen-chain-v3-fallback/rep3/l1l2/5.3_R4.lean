import ContractForge
open ContractForge

-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.

-- L0 spec

structure Input where
  ip : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  ip : String
  blocked : Bool
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.failedAttempts < 10
  post := fun i o => (o.blocked = true ↔ i.failedAttempts + 1 ≥ 10) ∧
                     o.failedAttempts = i.failedAttempts + 1

example : Spec.pre { ip := "192.168.1.1", failedAttempts := 9 } ∧
          Spec.post { ip := "192.168.1.1", failedAttempts := 9 }
                    { ip := "192.168.1.1", blocked := true, failedAttempts := 10 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { ip := x.ip, blocked := decide (x.failedAttempts + 1 ≥ 10), failedAttempts := x.failedAttempts + 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
