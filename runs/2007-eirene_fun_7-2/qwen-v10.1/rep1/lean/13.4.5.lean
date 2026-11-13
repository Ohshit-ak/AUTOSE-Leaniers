import ContractForge
open ContractForge

-- 13.4.5: 13.4.5 For Railway emergency calls initiated by a mobile, the automatic confirmation message of the initiating mobile shall contain: (M) the time at call establishment; the time at clear down; the functional number of the call originator; the train number and engine number of the call originator, if a train.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  timeEstablishment : Nat -- in seconds
  timeClearDown     : Nat -- in seconds
  functionalNumber  : String
  trainNumber       : Option String
  engineNumber      : Option String
  deriving DecidableEq, Repr

structure Output where
  timeEstablishment : Nat -- in seconds
  timeClearDown     : Nat -- in seconds
  functionalNumber  : String
  trainNumber       : Option String
  engineNumber      : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.timeEstablishment = i.timeEstablishment ∧
                     o.timeClearDown = i.timeClearDown ∧
                     o.functionalNumber = i.functionalNumber ∧
                     o.trainNumber = i.trainNumber ∧
                     o.engineNumber = i.engineNumber

example : Spec.pre { timeEstablishment := 120, timeClearDown := 300,
                     functionalNumber := "1234567890", trainNumber := some "12345",
                     engineNumber := some "67890" } ∧
          Spec.post { timeEstablishment := 120, timeClearDown := 300,
                      functionalNumber := "1234567890", trainNumber := some "12345",
                      engineNumber := some "67890" }
                    { timeEstablishment := 120, timeClearDown := 300,
                      functionalNumber := "1234567890", trainNumber := some "12345",
                      engineNumber := some "67890" } := by
  unfold Spec; decide
