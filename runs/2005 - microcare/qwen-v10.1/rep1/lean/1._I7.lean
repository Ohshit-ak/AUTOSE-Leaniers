import ContractForge
open ContractForge

-- 1./I7: Additionally the provision for validity date check for the period of vouchers to be used in the program is provided. This validity date can be amended or altered at the system level ONLY by the authorized user
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  voucherId : Nat
  validityDate : String
  isAuthorized : Bool
  deriving DecidableEq, Repr

structure Output where
  voucherId : Nat
  validityDate : String
  isAuthorized : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isAuthorized
  post := fun i o => o.voucherId = i.voucherId ∧
                     o.validityDate = i.validityDate ∧
                     o.isAuthorized = i.isAuthorized

example : Spec.pre { voucherId := 1, validityDate := "2023-12-31", isAuthorized := true } ∧
          Spec.post { voucherId := 1, validityDate := "2023-12-31", isAuthorized := true }
                    { voucherId := 1, validityDate := "2023-12-31", isAuthorized := true } := by
  unfold Spec; decide
