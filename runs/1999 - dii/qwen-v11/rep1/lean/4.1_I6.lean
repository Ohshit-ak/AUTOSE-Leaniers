import ContractForge
open ContractForge

-- 4.1/I6: End User Mode: Portion of XS services shall be used by various classes of users: data consumers, data and database managers, network information infrastructure resource managers. Some of these uses of the data management services will entail unique requirements that shall be fulfilled within the capability of XS services.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  userClass : String
  dataConsumed : Bool
  dataAndDBManager : Bool
  networkInfoManager : Bool
  deriving DecidableEq, Repr

structure Output where
  serviceUsed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userClass ≠ "" ∧
                  (i.dataConsumed ∨ i.dataAndDBManager ∨ i.networkInfoManager)
  post := fun i o => o.serviceUsed = true ↔
    (i.dataConsumed → o.serviceUsed) ∧
    (i.dataAndDBManager → o.serviceUsed) ∧
    (i.networkInfoManager → o.serviceUsed)

example : Spec.pre { userClass := "dataConsumer", dataConsumed := true, dataAndDBManager := false, networkInfoManager := false } ∧
          Spec.post { userClass := "dataConsumer", dataConsumed := true, dataAndDBManager := false, networkInfoManager := false }
                    { serviceUsed := true } := by
  unfold Spec; decide
