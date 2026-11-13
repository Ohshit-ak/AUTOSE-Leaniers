import ContractForge
open ContractForge

-- 4.3.3/I3: Applications work would then include any of: IOC Database IOC or OPI SNC programs Files associated with OPI Channel Access Tools
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  applicationType : String
  deriving DecidableEq, Repr

structure Output where
  workIncluded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.workIncluded = true ↔
    (i.applicationType = "IOC Database" ∨
     i.applicationType = "IOC" ∨
     i.applicationType = "OPI SNC" ∨
     i.applicationType = "Files associated with OPI" ∨
     i.applicationType = "Channel Access Tools")

example : Spec.pre { applicationType := "IOC" } ∧
          Spec.post { applicationType := "IOC" }
                    { workIncluded := true } := by
  unfold Spec; decide
