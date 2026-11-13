import ContractForge
open ContractForge

-- 5.2.3.36: 5.2.3.36 Where an on-train bus is connected to the Cab radio, deregistration of functional numbers can be performed on an individual basis and also by the train driver, by one action for all users (including the driver), at the end of the journey when the train number is no longer associated with the train. (O) Register and deregister stock number (engine/coach number)
-- compiles: False · rejects_bad_example: None · checked: False

structure Train where
  trainNumber : String
  functionalNumbers : List String
  deriving DecidableEq, Repr

structure Input where
  train : Train
  action : String
  deriving DecidableEq, Repr

structure Output where
  train : Train
  action : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["deregister", "deregister all"]
  post := fun i o =>
    (o.action = i.action ∧
     (i.action = "deregister" →
      o.train.functionalNumbers = i.train.functionalNumbers \ [i.train.trainNumber] ∧
      o.train.trainNumber = i.train.trainNumber) ∧
     (i.action = "deregister all" →
      o.train.functionalNumbers = [] ∧
      o.train.trainNumber = i.train.trainNumber))

example : Spec.pre { train := { trainNumber := "1234", functionalNumbers := ["1234", "5678"] },
                     action := "deregister all" } ∧
          Spec.post { train := { trainNumber := "1234", functionalNumbers := ["1234", "5678"] },
                      action := "deregister all" }
                    { train := { trainNumber := "1234", functionalNumbers := [] },
                      action := "deregister all" } := by
  unfold Spec; decide
