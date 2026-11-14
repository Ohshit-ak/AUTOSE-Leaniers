import ContractForge
open ContractForge

-- 9.2.6/S1: The Coach Function Number(s) and associated MSISDN number(s) shall at any time be stored as an entry in the routing database of the home GSM-R network of the coach.
-- compiles: True · rejects_bad_example: True · checked: True

structure RoutingEntry where
  coachFunctionNumber : String
  msisdnNumbers       : List String
  deriving DecidableEq, Repr

structure Input where
  routingDatabase : List RoutingEntry
  coachFunctionNumber : String
  msisdnNumbers : List String
  deriving DecidableEq, Repr

structure Output where
  routingDatabase : List RoutingEntry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.coachFunctionNumber ≠ ""
  post := fun i o => o.routingDatabase.Nodup ∧
                     (∃ entry ∈ o.routingDatabase, entry.coachFunctionNumber = i.coachFunctionNumber ∧
                      entry.msisdnNumbers = i.msisdnNumbers)

example : Spec.pre { routingDatabase := [{ coachFunctionNumber := "1234", msisdnNumbers := ["1234567890"] }],
                     coachFunctionNumber := "1234", msisdnNumbers := ["1234567890"] } ∧
          Spec.post { routingDatabase := [{ coachFunctionNumber := "1234", msisdnNumbers := ["1234567890"] }],
                      coachFunctionNumber := "1234", msisdnNumbers := ["1234567890"] }
                    { routingDatabase := [{ coachFunctionNumber := "1234", msisdnNumbers := ["1234567890"] }] } := by
  unfold Spec; decide
