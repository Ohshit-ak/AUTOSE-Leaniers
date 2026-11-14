import ContractForge
open ContractForge

-- 3.2.2/I6: One component receives data unscheduled (Pull)

-- L0 spec

structure Input where
  data : String
  isScheduled : Bool
  deriving DecidableEq, Repr

structure Output where
  processed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => (o.processed = true ↔ i.isScheduled = false)

example : Spec.pre { data := "some data", isScheduled := false } ∧
          Spec.post { data := "some data", isScheduled := false } { processed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processed := decide (x.isScheduled = false) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
