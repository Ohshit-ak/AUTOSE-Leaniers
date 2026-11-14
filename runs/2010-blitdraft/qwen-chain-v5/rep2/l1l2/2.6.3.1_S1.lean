import ContractForge
open ContractForge

-- 2.6.3.1/S1: The Development Team shall perform weekly integrations of the [SYSTEM NAME] system and deploy these system updates to the Staging environment.

-- L0 spec

structure Input where
  weekNumber : Nat
  deriving DecidableEq, Repr

structure Output where
  deploymentSuccessful : Bool
  message              : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 1 ≤ i.weekNumber
  post := fun i o => (o.deploymentSuccessful = true ↔
    i.weekNumber % 2 = 0) ∧
    (o.deploymentSuccessful = false →
    o.message = "Integration and deployment failed this week.")

example : Spec.pre { weekNumber := 2 } ∧
          Spec.post { weekNumber := 2 }
                    { deploymentSuccessful := true, message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  deploymentSuccessful : Bool
  deriving DecidableEq, Repr

def ComputeDeploymentContract : Contract Input Mid where
  pre  := fun i => 1 ≤ i.weekNumber
  post := fun i m => m.deploymentSuccessful = (i.weekNumber % 2 = 0)

def FormatMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.deploymentSuccessful = true → o.message = "") ∧
                     (m.deploymentSuccessful = false → o.message = "Integration and deployment failed this week.")
