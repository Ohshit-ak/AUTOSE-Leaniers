import ContractForge
open ContractForge

-- 11.3.8iii/S1: The system shall require manual confirmation prior to the removal of the relationship between Engine Number and MSISDN Number.
-- compiles: True · rejects_bad_example: None · checked: True

structure EngineNumber where
  number : Nat
  deriving DecidableEq, Repr

structure MsisdnNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Input where
  engineNumber : EngineNumber
  msisdnNumber : MsisdnNumber
  confirmed    : Bool
  deriving DecidableEq, Repr

structure Output where
  engineNumber : EngineNumber
  msisdnNumber : MsisdnNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.confirmed
  post := fun i o => (o.engineNumber = i.engineNumber ∧ o.msisdnNumber = i.msisdnNumber) ↔
                     (i.confirmed = true)

example : Spec.pre { engineNumber := { number := 1234 }, msisdnNumber := { number := 5678 },
                     confirmed := true } ∧
          Spec.post { engineNumber := { number := 1234 }, msisdnNumber := { number := 5678 },
                      confirmed := true }
                    { engineNumber := { number := 1234 }, msisdnNumber := { number := 5678 } } := by
  unfold Spec; decide
