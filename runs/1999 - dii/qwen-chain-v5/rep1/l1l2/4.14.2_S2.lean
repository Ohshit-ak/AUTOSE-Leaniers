import ContractForge
open ContractForge

-- 4.14.2/S2: The Qualification Methods applied to the software shall include test, demonstration, analysis, and inspection (T, D, A, I).

-- L0 spec

structure Input where
  method : String
  deriving DecidableEq, Repr

structure Output where
  qualified : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.qualified = true ↔
    (i.method = "T" ∨ i.method = "D" ∨ i.method = "A" ∨ i.method = "I")

example : Spec.pre { method := "T" } ∧
          Spec.post { method := "T" } { qualified := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { qualified := decide ((x.method = "T" ∨ x.method = "D" ∨ x.method = "A" ∨ x.method = "I")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
