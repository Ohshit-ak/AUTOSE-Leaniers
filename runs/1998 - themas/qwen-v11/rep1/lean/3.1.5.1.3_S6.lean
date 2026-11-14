import ContractForge
open ContractForge

-- 3.1.5.1.3/S6: When a request to turn off a heating or cooling unit is received, this process shall check the queue of waiting heating and cooling requests.
-- compiles: False · rejects_bad_example: None · checked: False

structure HeatingCoolingUnit where
  id : Nat
  status : String
  deriving DecidableEq, Repr

structure Request where
  unitId : Nat
  action : String
  deriving DecidableEq, Repr

structure Input where
  units : List HeatingCoolingUnit
  requests : List Request
  deriving DecidableEq, Repr

structure Output where
  units : List HeatingCoolingUnit
  processed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requests.length > 0
  post := fun i o => o.processed = true ∧
                     (∀ u ∈ i.units, u.status = o.units.find (·.id = u.id).status) ∧
                     (∃ r ∈ i.requests, r.action = "turn off" ∧
                      o.units.find (·.id = r.unitId).status = "off")

example : Spec.pre { units := [{ id := 1, status := "on" }, { id := 2, status := "on" }],
                     requests := [{ unitId := 1, action := "turn off" }] } ∧
          Spec.post { units := [{ id := 1, status := "off" }, { id := 2, status := "on" }],
                      requests := [{ unitId := 1, action := "turn off" }],
                      processed := true }
                    { units := [{ id := 1, status := "off" }, { id := 2, status := "on" }],
                      processed := true } := by
  unfold Spec; decide
