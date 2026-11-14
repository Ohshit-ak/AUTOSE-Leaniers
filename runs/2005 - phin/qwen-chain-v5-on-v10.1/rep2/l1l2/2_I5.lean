import ContractForge
open ContractForge

-- 2/I5: 2.5 System Integration and Data Exchange: OM information must be exchangeable, based on established standards, between systems involved in the investigation, identification, confirmation, and reporting of a health event.

-- L0 spec

structure Input where
  omData : String
  deriving DecidableEq, Repr

structure Output where
  exchanged : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.omData ≠ ""
  post := fun i o => o.exchanged = true ↔
    (i.omData.length ≤ 1024 ∧ i.omData.toList.all Char.isAlphanum = true)

example : Spec.pre { omData := "OM1234567890" } ∧
          Spec.post { omData := "OM1234567890" }
                    { exchanged := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { exchanged := decide ((x.omData.length ≤ 1024 ∧ x.omData.toList.all Char.isAlphanum = true)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
