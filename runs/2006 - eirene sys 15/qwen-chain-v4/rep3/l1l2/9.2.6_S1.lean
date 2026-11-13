import ContractForge
open ContractForge

-- 9.2.6/S1: The Coach Function Number(s) and associated MSISDN number(s) shall at any time be stored as an entry in the routing database of the home GSM-R network of the coach.

-- L0 spec

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

example : Spec.pre { routingDatabase := [{ coachFunctionNumber := "CF1", msisdnNumbers := ["MSISDN1"] }],
                     coachFunctionNumber := "CF1", msisdnNumbers := ["MSISDN1"] } ∧
          Spec.post { routingDatabase := [{ coachFunctionNumber := "CF1", msisdnNumbers := ["MSISDN1"] }],
                      coachFunctionNumber := "CF1", msisdnNumbers := ["MSISDN1"] }
                    { routingDatabase := [{ coachFunctionNumber := "CF1", msisdnNumbers := ["MSISDN1"] }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { routingDatabase := x.routingDatabase }
