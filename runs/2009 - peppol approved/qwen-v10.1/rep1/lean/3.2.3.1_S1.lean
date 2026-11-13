import ContractForge
open ContractForge

-- 3.2.3.1/S1: A selection of such documents will be included in any VCD; they will be produced by national units according to national legislation.
-- compiles: True · rejects_bad_example: True · checked: True

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
