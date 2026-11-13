import ContractForge
open ContractForge

-- 3.10.1.2: Default values shall be harmonised values, permanently stored in all ERTMS/ETCS on board equipment

-- L0 spec

structure Input where
  harmonisedValues : List String
  deriving DecidableEq, Repr

structure Output where
  harmonisedValues : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.harmonisedValues.Nodup
  post := fun i o => o.harmonisedValues = i.harmonisedValues

example : Spec.pre { harmonisedValues := ["value1", "value2"] } ∧
          Spec.post { harmonisedValues := ["value1", "value2"] }
                    { harmonisedValues := ["value1", "value2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { harmonisedValues := x.harmonisedValues }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
