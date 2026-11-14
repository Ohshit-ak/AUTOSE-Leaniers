import ContractForge
open ContractForge

-- 3.2.3.1/S1: A selection of such documents will be included in any VCD; they will be produced by national units according to national legislation.

-- L0 spec

structure Input where
  documents : List String
  nationalLegislation : String
  deriving DecidableEq, Repr

structure Output where
  vcd : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.documents.Nodup ∧ i.nationalLegislation ≠ ""
  post := fun i o => o.vcd.Nodup ∧
                     (∀ d ∈ o.vcd, d ∈ i.documents) ∧
                     (∀ d ∈ o.vcd, i.nationalLegislation = d)

example : Spec.pre { documents := ["doc1", "doc2"], nationalLegislation := "leg1" } ∧ Spec.post { documents := ["doc1", "doc2"], nationalLegislation := "leg1" } { vcd := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { vcd := x.documents.filter (fun d => x.nationalLegislation = d) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
