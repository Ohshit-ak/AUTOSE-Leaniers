import ContractForge
open ContractForge

-- 13.3.2: 13.3.2 For Railway emergency calls initiated by a mobile, the controllers display will indicate: location; (O) the functional identity of the originating mobile, which includes the following: the train number, if available; (M) the engine number, if no train number is available; (M) the coach number of the leading cab, if neither a train number nor an engine number is available. (O)
-- compiles: True · rejects_bad_example: False · checked: False

structure Location where
  trainNumber : Option String
  engineNumber : Option String
  coachNumber : Option String
  deriving DecidableEq, Repr

structure Input where
  location : Location
  deriving DecidableEq, Repr

structure Output where
  location : Location
  functionalIdentity : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.location = i.location ∧
                     (o.functionalIdentity = i.location.trainNumber.getD "" ∨
                      o.functionalIdentity = i.location.engineNumber.getD "" ∨
                      o.functionalIdentity = i.location.coachNumber.getD "")

example : Spec.pre { location := { trainNumber := some "1234", engineNumber := none, coachNumber := none } } ∧
          Spec.post { location := { trainNumber := some "1234", engineNumber := none, coachNumber := none } }
                    { location := { trainNumber := some "1234", engineNumber := none, coachNumber := none }, functionalIdentity := "1234" } := by
  unfold Spec; decide
