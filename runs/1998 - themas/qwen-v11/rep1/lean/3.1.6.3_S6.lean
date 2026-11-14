import ContractForge
open ContractForge

-- 3.1.6.3/S6: This ev ent shall contain the identification of the heating or cooling unit whose status is being changed.
-- compiles: False · rejects_bad_example: None · checked: False

structure HeatingCoolingUnit where
  id : Nat
  status : String
  deriving DecidableEq, Repr

structure Input where
  units : List HeatingCoolingUnit
  deriving DecidableEq, Repr

structure Output where
  unitId : Nat
  status : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.units.length > 0
  post := fun i o => o.unitId = i.units.head.id ∧
                     o.status = i.units.head.status

example : Spec.pre { units := [{ id := 1, status := "on" }] } ∧
          Spec.post { units := [{ id := 1, status := "on" }] }
                    { unitId := 1, status := "on" } := by
  unfold Spec; decide
