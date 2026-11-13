import ContractForge
open ContractForge

-- 3.11.4/I5: TALDT denotes Total Administrative and Logistic Downtime

-- L0 spec

structure Input where
  downtime : Nat
  deriving DecidableEq, Repr

structure Output where
  availability : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.downtime < 100
  post := fun i o => o.availability = 100 - i.downtime

example : Spec.pre { downtime := 5 } ∧
          Spec.post { downtime := 5 } { availability := 95 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { availability := 100 - x.downtime }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
