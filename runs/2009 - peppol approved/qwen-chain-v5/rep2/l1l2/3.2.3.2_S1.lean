import ContractForge
open ContractForge

-- 3.2.3.2/S1: Tagged records, information and data can be processed by independent systems and applications only if the constraining tags or metadata are recognized by the different processing parties.

-- L0 spec

structure Input where
  record : String
  tags   : List String
  deriving DecidableEq, Repr

structure Output where
  processed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.tags.Nodup
  post := fun i o => o.processed = true ↔
    (∃ tag ∈ i.tags, tag = "constraining" ∧
     i.record = "record_value")

example : Spec.pre { record := "record_value", tags := ["constraining"] } ∧
          Spec.post { record := "record_value", tags := ["constraining"] }
                    { processed := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processed := decide ((∃ tag ∈ x.tags, tag = "constraining" ∧
     x.record = "record_value")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
