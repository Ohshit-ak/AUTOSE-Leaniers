import ContractForge
open ContractForge

-- 3.1.10.3/I2: For each thermometer, the ratio of the number of requests for a heating and cooling unit that was granted to the number of requests for a heating or cooling unit that was denied.
-- compiles: False · rejects_bad_example: None · checked: False

structure Request where
  unitType : String
  granted  : Bool
  deriving DecidableEq, Repr

structure Input where
  thermometers : List Request
  deriving DecidableEq, Repr

structure Output where
  ratios : List (String × Nat × Nat)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.thermometers.Nodup
  post := fun i o => 
    (∀ r ∈ i.thermometers, 
     ∃ (unit : String, grantedCount : Nat, deniedCount : Nat) ∈ o.ratios, 
     unit = r.unitType ∧
     (grantedCount = r.thermometers.filter (·.unitType = r.unitType).filter (·.granted = true).length ∧
      deniedCount = r.thermometers.filter (·.unitType = r.unitType).filter (·.granted = false).length))

example : Spec.pre { thermometers := [{ unitType := "heating", granted := true },
                                       { unitType := "cooling", granted := false },
                                       { unitType := "heating", granted := false }] } ∧
          Spec.post { thermometers := [{ unitType := "heating", granted := true },
                                        { unitType := "cooling", granted := false },
                                        { unitType := "heating", granted := false }] }
                    { ratios := [{ unit := "heating", grantedCount := 1, deniedCount := 1 },
                                 { unit := "cooling", grantedCount := 0, deniedCount := 1 }] } := by
  unfold Spec; decide
