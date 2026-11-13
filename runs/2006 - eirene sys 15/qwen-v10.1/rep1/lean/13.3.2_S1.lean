import ContractForge
open ContractForge

-- 13.3.2/S1: The call area and list of train controllers for each emergency group call will be fixed in the Group Call Register (GCR) of the anchor MSC.
-- compiles: True · rejects_bad_example: True · checked: True

structure CallArea where
  name : String
  Nodup : Bool := true
  deriving DecidableEq, Repr

structure TrainController where
  name : String
  deriving DecidableEq, Repr

structure EmergencyGroup where
  callArea : CallArea
  trainControllers : List TrainController
  Nodup : Bool := true
  deriving DecidableEq, Repr

structure Input where
  gcr : List EmergencyGroup
  deriving DecidableEq, Repr

structure Output where
  gcr : List EmergencyGroup
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.gcr.Nodup
  post := fun i o => o.gcr = i.gcr ∧
                     ∀ g ∈ o.gcr, g.callArea.Nodup ∧ g.trainControllers.Nodup

example : Spec.pre { gcr := [{ callArea := { name := "Area1" },
                               trainControllers := [{ name := "Ctrl1" }] },
                             { callArea := { name := "Area2" },
                               trainControllers := [{ name := "Ctrl2" }] }] } ∧
          Spec.post { gcr := [{ callArea := { name := "Area1" },
                                trainControllers := [{ name := "Ctrl1" }] },
                               { callArea := { name := "Area2" },
                                 trainControllers := [{ name := "Ctrl2" }] }] }
                    { gcr := [{ callArea := { name := "Area1" },
                                trainControllers := [{ name := "Ctrl1" }] },
                              { callArea := { name := "Area2" },
                                trainControllers := [{ name := "Ctrl2" }] }] } := by
  unfold Spec; decide
