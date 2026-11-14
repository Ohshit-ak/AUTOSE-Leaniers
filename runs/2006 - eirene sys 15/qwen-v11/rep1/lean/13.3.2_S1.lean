import ContractForge
open ContractForge

-- 13.3.2/S1: The call area and list of train controllers for each emergency group call will be fixed in the Group Call Register (GCR) of the anchor MSC.
-- compiles: False · rejects_bad_example: None · checked: False

structure CallArea where
  id : Nat
  deriving DecidableEq, Repr

structure TrainController where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure EmergencyGroup where
  callArea : CallArea
  trainControllers : List TrainController
  deriving DecidableEq, Repr

structure GroupCallRegister where
  emergencyGroups : List EmergencyGroup
  deriving DecidableEq, Repr

structure Input where
  emergencyGroups : List EmergencyGroup
  deriving DecidableEq, Repr

structure Output where
  emergencyGroups : List EmergencyGroup
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.emergencyGroups.Nodup
  post := fun i o => o.emergencyGroups = i.emergencyGroups ∧
                     ∀ g ∈ o.emergencyGroups, g.callArea ∈ i.emergencyGroups.map (·.callArea) ∧
                     g.trainControllers.length = i.emergencyGroups.find? (·.callArea = g.callArea).get!.trainControllers.length

example : Spec.pre { emergencyGroups := [{ callArea := { id := 1 }, trainControllers := [{ id := 101, name := "TC1" }] },
                                           { callArea := { id := 2 }, trainControllers := [{ id := 102, name := "TC2" }] }] } ∧
          Spec.post { emergencyGroups := [{ callArea := { id := 1 }, trainControllers := [{ id := 101, name := "TC1" }] },
                                           { callArea := { id := 2 }, trainControllers := [{ id := 102, name := "TC2" }] }] }
                    { emergencyGroups := [{ callArea := { id := 1 }, trainControllers := [{ id := 101, name := "TC1" }] },
                                           { callArea := { id := 2 }, trainControllers := [{ id := 102, name := "TC2" }] }] } := by
  unfold Spec; decide
