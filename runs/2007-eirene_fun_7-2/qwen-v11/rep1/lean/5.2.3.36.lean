import ContractForge
open ContractForge

-- 5.2.3.36: 5.2.3.36 Where an on-train bus is connected to the Cab radio, deregistration of functional numbers can be performed on an individual basis and also by the train driver, by one action for all users (including the driver), at the end of the journey when the train number is no longer associated with the train. (O) Register and deregister stock number (engine/coach number)
-- compiles: False · rejects_bad_example: None · checked: False

structure Train where
  trainNumber : String
  deriving DecidableEq, Repr

structure FunctionalNumber where
  number : String
  user   : String
  deriving DecidableEq, Repr

structure Input where
  trainNumber : String
  functionalNumbers : List FunctionalNumber
  deriving DecidableEq, Repr

structure Output where
  deregistered : Bool
  functionalNumbers : List FunctionalNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ "" ∧ i.functionalNumbers.Nodup
  post := fun i o =>
    (o.deregistered = true ↔
      i.functionalNumbers.all (fun fn => fn.user = i.trainNumber) ∧
      i.functionalNumbers.length > 5) ∧
    (o.deregistered = false →
      o.functionalNumbers = i.functionalNumbers)

example : Spec.pre { trainNumber := "12345", functionalNumbers := [{ number := "A1", user := "12345" },
                                                                    { number := "A2", user := "12345" },
                                                                    { number := "A3", user := "12345" },
                                                                    { number := "A4", user := "12345" },
                                                                    { number := "A5", user := "12345" },
                                                                    { number := "A6", user := "12346" }] } ∧
          Spec.post { trainNumber := "12345", functionalNumbers := [{ number := "A1", user := "12345" },
                                                                     { number := "A2", user := "12345" },
                                                                     { number := "A3", user := "12345" },
                                                                     { number := "A4", user := "12345" },
                                                                     { number := "A5", user := "12345" },
                                                                     { number := "A6", user := "12346" }] }
                    { deregistered := true, functionalNumbers := [{ number := "A6", user := "12346" }] } := by
  unfold Spec; decide
