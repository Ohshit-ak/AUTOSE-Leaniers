import ContractForge
open ContractForge

-- 5.4.2/S1: Upon switch on, the Cab radio shall be registered with a mobile network (see section 10.5).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  cabId : Nat
  networkRegistration : Bool
  deriving DecidableEq, Repr

structure Output where
  cabId : Nat
  networkRegistered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networkRegistration = true
  post := fun i o => o.cabId = i.cabId ∧ o.networkRegistered = true

example : Spec.pre { cabId := 123, networkRegistration := true } ∧
          Spec.post { cabId := 123, networkRegistration := true }
                    { cabId := 123, networkRegistered := true } := by
  unfold Spec; decide
