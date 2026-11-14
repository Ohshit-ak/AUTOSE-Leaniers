import ContractForge
open ContractForge

-- 3.10.1.2: Default values shall be harmonised values, permanently stored in all ERTMS/ETCS on board equipment
-- compiles: True · rejects_bad_example: True · checked: True

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
