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

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { deploymentSuccessful := decide (x.weekNumber % 2 = 0),
    message := if x.weekNumber % 2 = 0 then "" else "Integration and deployment failed this week." }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
