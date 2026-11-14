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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  weekNumber : Nat
  isEvenWeek : Bool
  deriving DecidableEq, Repr

def ComputeWeekEvennessContract : Contract Input Mid where
  pre  := fun i => 1 ≤ i.weekNumber
  post := fun i m => m.weekNumber = i.weekNumber ∧ m.isEvenWeek = (i.weekNumber % 2 = 0)

def GenerateOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.deploymentSuccessful = true ↔ m.isEvenWeek) ∧
                     (o.deploymentSuccessful = false →
                     o.message = "Integration and deployment failed this week.")

theorem po1 : Contract.Compatible ComputeWeekEvennessContract GenerateOutputContract := by
  discharge_po1 [ComputeWeekEvennessContract, GenerateOutputContract, Spec]

theorem po2 : Contract.Refines (ComputeWeekEvennessContract.seq GenerateOutputContract) Spec := by
  discharge_po2 [ComputeWeekEvennessContract, GenerateOutputContract, Spec]

-- L2 ComputeWeekEvennessContract (success=True)

def ComputeWeekEvennessContractImpl (x : Input) : Mid :=
  { weekNumber := x.weekNumber,
    isEvenWeek := x.weekNumber % 2 = 0 }

theorem ComputeWeekEvennessContractImpl_ok : ComputeWeekEvennessContract.Satisfies ComputeWeekEvennessContractImpl := by
  discharge_po3 [ComputeWeekEvennessContract, ComputeWeekEvennessContractImpl]

-- L2 GenerateOutputContract (success=True)

def GenerateOutputContractImpl (x : Mid) : Output :=
  { deploymentSuccessful := decide (x.isEvenWeek),
    message := if x.isEvenWeek then "" else "Integration and deployment failed this week." }

theorem GenerateOutputContractImpl_ok : GenerateOutputContract.Satisfies GenerateOutputContractImpl := by
  discharge_po3 [GenerateOutputContract, GenerateOutputContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (GenerateOutputContractImpl ∘ ComputeWeekEvennessContractImpl) :=
  Contract.system_sound po1 po2 ComputeWeekEvennessContractImpl_ok GenerateOutputContractImpl_ok
