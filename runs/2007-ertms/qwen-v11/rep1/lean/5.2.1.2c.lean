import ContractForge
open ContractForge

-- 5.2.1.2c: In ETCS with RBC this restriction on performance shall, if possible be transmitted to the RBC.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  equipmentFailure : Bool
  performanceRestriction : String
  deriving DecidableEq, Repr

structure Output where
  transmittedToRBC : Bool
  performanceStatus : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.equipmentFailure = true
  post := fun i o => (o.transmittedToRBC = true ↔
    i.performanceRestriction ≠ "" ∧
    (o.performanceStatus = "transmitted" ↔
      o.transmittedToRBC = true)) ∧
    (o.transmittedToRBC = false →
      o.performanceStatus = "not transmitted")

example : Spec.pre { equipmentFailure := true, performanceRestriction := "speed limit" } ∧
          Spec.post { equipmentFailure := true, performanceRestriction := "speed limit" }
                    { transmittedToRBC := true, performanceStatus := "transmitted" } := by
  unfold Spec; decide
