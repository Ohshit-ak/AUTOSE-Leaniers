import ContractForge
open ContractForge

-- 5.4.2/S1: Upon switch on, the Cab radio shall be registered with a mobile network (see section 10.5).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mobileNetwork : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.registered = true

example : Spec.pre { mobileNetwork := "NetworkX" } ∧
          Spec.post { mobileNetwork := "NetworkX" }
                    { registered := true } := by
  unfold Spec; decide
