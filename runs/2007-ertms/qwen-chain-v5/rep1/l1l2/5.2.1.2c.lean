import ContractForge
open ContractForge

-- 5.2.1.2c: In ETCS with RBC this restriction on performance shall, if possible be transmitted to the RBC.

-- L0 spec

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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  performanceStatus : String
  deriving DecidableEq, Repr

def ComputePerformanceStatusContract : Contract Input Mid where
  pre  := fun i => i.equipmentFailure = true
  post := fun i m => m.performanceStatus = "transmitted" ↔
                     (i.performanceRestriction ≠ "" ∧ m.performanceStatus = "transmitted")

def TransmitToRBCContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.transmittedToRBC = true ↔
                     (m.performanceStatus = "transmitted" ∧
                      o.performanceStatus = "transmitted") ∧
                     (o.transmittedToRBC = false →
                      o.performanceStatus = "not transmitted")
