import ContractForge
open ContractForge

-- 3.4.4: 3.4.4 Set-up times shall include the time required for any translation of functional numbers internal to the EIRENE network. (M)

-- L0 spec

structure Input where
  functionalNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  setUpTime : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.Nodup
  post := fun i o => o.setUpTime ≥ i.functionalNumbers.length

example : Spec.pre { functionalNumbers := ["123", "456"] } ∧
          Spec.post { functionalNumbers := ["123", "456"] }
                    { setUpTime := 2 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { setUpTime := x.functionalNumbers.length }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
