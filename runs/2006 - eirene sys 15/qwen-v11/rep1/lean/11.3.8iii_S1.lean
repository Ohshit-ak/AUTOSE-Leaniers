import ContractForge
open ContractForge

-- 11.3.8iii/S1: The system shall require manual confirmation prior to the removal of the relationship between Engine Number and MSISDN Number.
-- compiles: False · rejects_bad_example: None · checked: False

structure EngineNumber where
  number : Nat
  deriving DecidableEq, Repr

structure MsisdnNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Input where
  engineNumber : EngineNumber
  msisdnNumber : MsisdnNumber
  confirmation : Bool
  deriving DecidableEq, Repr

structure Output where
  engineNumber : EngineNumber
  msisdnNumber : MsisdnNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.confirmation = true
  post := fun i o => o.engineNumber = i.engineNumber ∧
                     o.msisdnNumber = i.msisdnNumber ∧
                     (o.engineNumber.number ≠ i.engineNumber.number ∨
                      o.msisdnNumber.number ≠ i.msisdnNumber.number)

example : Spec.pre { engineNumber := { number := 12345 }, msisdnNumber := { number := 67890 },
                     confirmation := true } ∧
          Spec.post { engineNumber := { number := 12345 }, msisdnNumber := { number := 67890 },
                      confirmation := true }
                    { engineNumber := { number := 12345 }, msisdnNumber := { number := 67890 } } := by
  unfold Spec; decide
