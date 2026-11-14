import ContractForge
open ContractForge

-- 3.1.10.3/I2: For each thermometer, the ratio of the number of requests for a heating and cooling unit that was granted to the number of requests for a heating or cooling unit that was denied.
-- compiles: False · rejects_bad_example: None · checked: False

structure Request where
  unit : String
  granted : Bool
  deriving DecidableEq, Repr

structure Input where
  thermometers : List String
  requests : List Request
  deriving DecidableEq, Repr

structure Output where
  ratios : List (String × Nat × Nat)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.requests.all (fun r => r.unit ∈ i.thermometers)
  post := fun i o => 
    o.ratios.length = i.thermometers.length ∧
    ∀ t ∈ i.thermometers, 
      ∃ (unit : String, grantedCount : Nat, deniedCount : Nat) ∈ o.ratios, 
      unit = t ∧
      (grantedCount = i.requests.filter (fun r => r.unit = t && r.granted = true).length ∧
       deniedCount = i.requests.filter (fun r => r.unit = t && r.granted = false).length)

example : Spec.pre { thermometers := ["therm1", "therm2"], 
                     requests := [{ unit := "therm1", granted := true },
                                  { unit := "therm1", granted := false },
                                  { unit := "therm2", granted := true },
                                  { unit := "therm2", granted := true }] } ∧
          Spec.post { thermometers := ["therm1", "therm2"], 
                      requests := [{ unit := "therm1", granted := true },
                                   { unit := "therm1", granted := false },
                                   { unit := "therm2", granted := true },
                                   { unit := "therm2", granted := true }] }
                    { ratios := [("therm1", 1, 1), ("therm2", 2, 0)] } := by
  unfold Spec; decide
