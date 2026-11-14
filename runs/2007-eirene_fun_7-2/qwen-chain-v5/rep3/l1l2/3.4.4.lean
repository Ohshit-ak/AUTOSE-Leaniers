import ContractForge
open ContractForge

-- 3.4.4: 3.4.4 Set-up times shall include the time required for any translation of functional numbers internal to the EIRENE network. (M)

-- L0 spec

structure Input where
  functionalNumber : Nat
  deriving DecidableEq, Repr

structure Output where
  setupTime : Nat
  translated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber > 0
  post := fun i o => o.setupTime ≥ i.functionalNumber ∧
                     (o.translated = true ↔ i.functionalNumber > 10)

example : Spec.pre { functionalNumber := 15 } ∧
          Spec.post { functionalNumber := 15 }
                    { setupTime := 15, translated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { setupTime := x.functionalNumber + 1,
    translated := decide (x.functionalNumber > 10) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
