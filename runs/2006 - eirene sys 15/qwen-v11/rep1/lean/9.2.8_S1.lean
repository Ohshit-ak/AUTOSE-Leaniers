import ContractForge
open ContractForge

-- 9.2.8/S1: The functional numbers of the Shunting Team Members, Maintenance Team Members and Train Controller (and any associated MSISDN numbers) shall be stored as entries in the routing database of the home GSM-R network.
-- compiles: True · rejects_bad_example: None · checked: True

structure FunctionalNumber where
  team : String
  member : Nat
  deriving DecidableEq, Repr

structure MSISDN where
  number : String
  deriving DecidableEq, Repr

structure Input where
  routingDatabase : List FunctionalNumber
  msisdnNumbers   : List MSISDN
  deriving DecidableEq, Repr

structure Output where
  routingDatabase : List FunctionalNumber
  msisdnNumbers   : List MSISDN
  deriving DecidableEq, Repr

-- A helper function to check if a team is one of the allowed teams
def isAllowedTeam (team : String) : Bool :=
  team ∈ ["Shunting", "Maintenance", "Train Controller"]

def Spec : Contract Input Output where
  pre  := fun i => i.routingDatabase.all (fun fn => isAllowedTeam fn.team)
  post := fun i o =>
    o.routingDatabase = i.routingDatabase.filter (fun fn => isAllowedTeam fn.team) ∧
    o.msisdnNumbers = i.msisdnNumbers

example : Spec.pre { routingDatabase := [{ team := "Shunting", member := 1 },
                                          { team := "Maintenance", member := 2 }],
                     msisdnNumbers := [{ number := "1234567890" }] } ∧
          Spec.post { routingDatabase := [{ team := "Shunting", member := 1 },
                                           { team := "Maintenance", member := 2 }],
                      msisdnNumbers := [{ number := "1234567890" }] }
                    { routingDatabase := [{ team := "Shunting", member := 1 },
                                          { team := "Maintenance", member := 2 }],
                      msisdnNumbers := [{ number := "1234567890" }] } := by
  unfold Spec; decide
