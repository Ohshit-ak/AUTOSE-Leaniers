import ContractForge
open ContractForge

-- 5.2.3.26: 5.2.3.26 It shall be possible for the driver to register and deregister a train number in the following ways: 1) enter train number; (M) 2) initiate automated request (applicable only for leading driver). (O)
-- compiles: True · rejects_bad_example: True · checked: True

structure TrainNumber where
  number : String
  deriving DecidableEq, Repr

structure Input where
  driverType : String
  trainNumber : Option TrainNumber
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  trainNumber : Option TrainNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driverType ∈ ["leading", "following"]
  post := fun i o => (o.registered = true ↔ i.driverType = "leading" ∧ i.trainNumber.isSome) ∧
                     (o.registered = false ↔ i.driverType = "following" ∨ i.trainNumber = none) ∧
                     (o.registered = true → o.trainNumber = i.trainNumber)

example : Spec.pre { driverType := "leading", trainNumber := some { number := "12345" } } ∧
          Spec.post { driverType := "leading", trainNumber := some { number := "12345" } }
                    { registered := true, trainNumber := some { number := "12345" } } := by
  unfold Spec; decide

example : Spec.pre { driverType := "following", trainNumber := some { number := "12345" } } ∧
          Spec.post { driverType := "following", trainNumber := some { number := "12345" } }
                    { registered := false, trainNumber := some { number := "12345" } } := by
  unfold Spec; decide
