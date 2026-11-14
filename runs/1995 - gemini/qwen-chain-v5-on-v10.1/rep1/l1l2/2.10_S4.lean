import ContractForge
open ContractForge

-- 2.10/S4: Critical resources (those that can support only a restricted number of simultaneous uses) are assigned solely through this allocation system.

-- L0 spec

structure Input where
  criticalResource : Nat
  concurrentUsers  : Nat
  isCritical       : Bool
  deriving DecidableEq, Repr

structure Output where
  assigned        : Bool
  concurrentUsers : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.concurrentUsers
  post := fun i o => (o.assigned = true ↔ i.isCritical) ∧
                     (o.assigned = false → o.concurrentUsers = i.concurrentUsers) ∧
                     o.concurrentUsers = i.concurrentUsers

example : Spec.pre { criticalResource := 1, concurrentUsers := 5, isCritical := true } ∧
          Spec.post { criticalResource := 1, concurrentUsers := 5, isCritical := true }
                    { assigned := true, concurrentUsers := 5 } := by
  unfold Spec; decide

example : Spec.pre { criticalResource := 1, concurrentUsers := 5, isCritical := false } ∧
          Spec.post { criticalResource := 1, concurrentUsers := 5, isCritical := false }
                    { assigned := false, concurrentUsers := 5 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { assigned := decide (x.isCritical),
    concurrentUsers := x.concurrentUsers }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
