import ContractForge
open ContractForge

-- 3.2.5.2/S2: Processing will include formatting, storing, routing, and display.

-- L0 spec

structure Input where
  data : String
  format : String
  deriving DecidableEq, Repr

structure Output where
  formatted : String
  stored : Bool
  routed : Bool
  displayed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.format ≠ ""
  post := fun i o => o.formatted = i.data ∧
                     o.stored = true ∧
                     o.routed = true ∧
                     o.displayed = true

example : Spec.pre { data := "", format := "formatted data" } ∧ Spec.post { data := "", format := "formatted data" } { formatted := "", stored := true, routed := true, displayed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { formatted := x.data, stored := true, routed := true, displayed := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
