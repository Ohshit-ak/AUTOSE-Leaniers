import ContractForge
open ContractForge

-- 9.2.5/S1: The Engine Function Number(s) and associated MSISDN numbers shall at any time be stored as an entry in the routing database of the home GSM-R network6 of the engine.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  engineNumber : String
  msisdn       : String
  routingDatabase : List String
  deriving DecidableEq, Repr

structure Output where
  engineNumber : String
  msisdn       : String
  routingDatabase : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.engineNumber ≠ "" ∧ i.msisdn ≠ ""
  post := fun i o => o.engineNumber = i.engineNumber ∧
                     o.msisdn = i.msisdn ∧
                     ∃ entry ∈ o.routingDatabase, entry = i.engineNumber

example : Spec.pre { engineNumber := "12345", msisdn := "67890", routingDatabase := ["54321"] } ∧
          Spec.post { engineNumber := "12345", msisdn := "67890", routingDatabase := ["12345", "54321"] }
                    { engineNumber := "12345", msisdn := "67890", routingDatabase := ["12345", "54321"] } := by
  unfold Spec; decide
