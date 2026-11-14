import ContractForge
open ContractForge

-- 13.3.2: 13.3.2 For Railway emergency calls initiated by a mobile, the controllers display will indicate: location; (O) the functional identity of the originating mobile, which includes the following: the train number, if available; (M) the engine number, if no train number is available; (M) the coach number of the leading cab, if neither a train number nor an engine number is available. (O)
-- compiles: True · rejects_bad_example: True · checked: True

structure Location where
  lat : Nat
  lon : Nat
  deriving DecidableEq, Repr

structure Mobile where
  trainNumber : Option String
  engineNumber : Option String
  coachNumber : Option String
  deriving DecidableEq, Repr

structure Input where
  location : Location
  mobile : Mobile
  deriving DecidableEq, Repr

structure Output where
  location : Location
  trainNumber : Option String
  engineNumber : Option String
  coachNumber : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => 
    o.location = i.location ∧
    (o.trainNumber = i.mobile.trainNumber ↔ i.mobile.trainNumber.isSome) ∧
    (o.engineNumber = i.mobile.engineNumber ↔ i.mobile.engineNumber.isSome ∧ i.mobile.trainNumber.isNone) ∧
    (o.coachNumber = i.mobile.coachNumber ↔ i.mobile.coachNumber.isSome ∧ i.mobile.trainNumber.isNone ∧ i.mobile.engineNumber.isNone)

example : Spec.pre { location := { lat := 0, lon := 0 }, mobile := { trainNumber := some "123", engineNumber := none, coachNumber := none } } ∧ Spec.post { location := { lat := 0, lon := 0 }, mobile := { trainNumber := some "123", engineNumber := none, coachNumber := none } } { location := { lat := 0, lon := 0 }, trainNumber := some "123", engineNumber := (some ""), coachNumber := (some "") } := by
  unfold Spec; decide
