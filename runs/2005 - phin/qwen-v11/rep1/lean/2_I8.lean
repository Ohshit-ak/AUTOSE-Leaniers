import ContractForge
open ContractForge

-- 2/I8: 2.8 System Security and Availability: Security of OM data includes the protection of data from corruption and access by unauthorized individuals, as well as the protection of the actual systems supporting OM from sabotage or other failure. A plan must be established for continuing activities when systems supporting OM are unavailable.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  data : String
  systemStatus : String
  deriving DecidableEq, Repr

structure Output where
  dataProtected : Bool
  systemAvailable : Bool
  contingencyPlan : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ "" ∧ i.systemStatus ≠ ""
  post := fun i o => o.dataProtected = true ∧
                     (o.systemAvailable ↔ i.systemStatus = "active") ∧
                     o.contingencyPlan = true

example : Spec.pre { data := "OM data", systemStatus := "active" } ∧
          Spec.post { data := "OM data", systemStatus := "active" }
                    { dataProtected := true, systemAvailable := true, contingencyPlan := true } := by
  unfold Spec; decide
