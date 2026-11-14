import ContractForge
open ContractForge

-- 3.2.3.2/S1: Tagged records, information and data can be processed by independent systems and applications only if the constraining tags or metadata are recognized by the different processing parties.
-- compiles: True · rejects_bad_example: True · checked: True

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
