import ContractForge
open ContractForge

-- 4.4.1.2: Information received shall not influence the traction unit(s) with in-operative cabs.
-- compiles: True · rejects_bad_example: True · checked: True

structure TractionUnit where
  cabStatus : Bool -- true if the cab is in-operative, false otherwise
  powerLevel : Nat -- power level of the traction unit
  deriving DecidableEq, Repr

structure Input where
  cabStatuses : List TractionUnit
  receivedInfo : String
  deriving DecidableEq, Repr

structure Output where
  cabStatuses : List TractionUnit
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.receivedInfo ≠ ""
  post := fun i o => o.cabStatuses = i.cabStatuses ∧
                     (o.cabStatuses.map (fun u => u.cabStatus) = i.cabStatuses.map (fun u => u.cabStatus))

example : Spec.pre { cabStatuses := [{ cabStatus := true, powerLevel := 50 },
                                      { cabStatus := false, powerLevel := 100 }],
                     receivedInfo := "new data" } ∧
          Spec.post { cabStatuses := [{ cabStatus := true, powerLevel := 50 },
                                       { cabStatus := false, powerLevel := 100 }],
                      receivedInfo := "new data" }
                    { cabStatuses := [{ cabStatus := true, powerLevel := 50 },
                                      { cabStatus := false, powerLevel := 100 }] } := by
  unfold Spec; decide
