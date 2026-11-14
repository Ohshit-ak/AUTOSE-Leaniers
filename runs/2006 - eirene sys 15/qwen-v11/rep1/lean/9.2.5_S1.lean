import ContractForge
open ContractForge

-- 9.2.5/S1: The Engine Function Number(s) and associated MSISDN numbers shall at any time be stored as an entry in the routing database of the home GSM-R network6 of the engine.
-- compiles: False · rejects_bad_example: None · checked: False

structure RoutingEntry where
  engineNumber : String
  msisdn      : String
  deriving DecidableEq, Repr

structure Input where
  engineNumbers : List String
  msisdns       : List String
  routingDatabase : List RoutingEntry
  deriving DecidableEq, Repr

structure Output where
  routingDatabase : List RoutingEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.engineNumbers.Nodup ∧ i.msisdns.Nodup
  post := fun i o => o.routingDatabase.Nodup ∧
                     (∀ e ∈ i.engineNumbers, ∃ r ∈ o.routingDatabase, r.engineNumber = e) ∧
                     (∀ m ∈ i.msisdns, ∃ r ∈ o.routingDatabase, r.msisdn = m) ∧
                     (∀ r1 r2 ∈ o.routingDatabase, r1.engineNumber ≠ r2.engineNumber → r1 ≠ r2) ∧
                     (∀ r1 r2 ∈ o.routingDatabase, r1.msisdn ≠ r2.msisdn → r1 ≠ r2)

example : Spec.pre { engineNumbers := ["1234567890", "9876543210"],
                     msisdns := ["12345678901234567890", "98765432109876543210"],
                     routingDatabase := [] } ∧
          Spec.post { engineNumbers := ["1234567890", "9876543210"],
                      msisdns := ["12345678901234567890", "98765432109876543210"],
                      routingDatabase := [{ engineNumber := "1234567890", msisdn := "12345678901234567890" },
                                          { engineNumber := "9876543210", msisdn := "98765432109876543210" }] }
                    { routingDatabase := [{ engineNumber := "1234567890", msisdn := "12345678901234567890" },
                                          { engineNumber := "9876543210", msisdn := "98765432109876543210" }] } := by
  unfold Spec; decide
