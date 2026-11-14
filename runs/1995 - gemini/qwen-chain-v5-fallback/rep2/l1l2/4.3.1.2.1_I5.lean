import ContractForge
open ContractForge

-- 4.3.1.2.1/I5: Databases Monitors The routines described in this section provide a callback mechanism for database value changes. This allows the caller to be notified when database values change without constantly polling the database. A mask can be set to specify value changes, alarm state changes, and/or archive changes. At the present time only channel access uses database monitors. No other software should use the database monitors. Because they are of interest only to channel access, the monitor routines will not be described.

-- L0 spec

structure Input where
  mask : Nat
  deriving DecidableEq, Repr

structure Output where
  notified : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mask ≠ 0
  post := fun i o => o.notified = true ↔ i.mask ≠ 0 ∧
    (o.notified = true → i.mask ≠ 0)

example : Spec.pre { mask := 5 } ∧ Spec.post { mask := 5 } { notified := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { notified := decide (x.mask ≠ 0) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
