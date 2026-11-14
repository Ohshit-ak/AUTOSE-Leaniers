import ContractForge
open ContractForge

-- 7.5.5/S1: SIM cards shall be fixed into the radio such that they can only be removed by the use of a tool.

-- L0 spec

structure Input where
  toolUsed : Bool
  deriving DecidableEq, Repr

structure Output where
  simRemoved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.toolUsed = false
  post := fun i o => o.simRemoved = false ∧
                     (o.simRemoved = true ↔ i.toolUsed = true)

example : Spec.pre { toolUsed := false } ∧ Spec.post { toolUsed := false } { simRemoved := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { simRemoved := false }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
