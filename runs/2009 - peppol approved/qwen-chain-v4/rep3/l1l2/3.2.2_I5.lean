import ContractForge
open ContractForge

-- 3.2.2/I5: One component sends data unscheduled to another one (Push)

-- L0 spec

structure Input where
  data : String
  isScheduled : Bool
  deriving DecidableEq, Repr

structure Output where
  received : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.received ↔ i.isScheduled = false

example : Spec.pre { data := "unscheduledData", isScheduled := false } ∧ Spec.post { data := "unscheduledData", isScheduled := false } { received := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { received := decide (x.isScheduled = false) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
