import ContractForge
open ContractForge

-- 5.5/R5: The system shall validate email address existence.
-- compiles: True · rejects_bad_example: True · checked: True

structure Email where
  address : String
  deriving DecidableEq, Repr

structure Input where
  email : Email
  check : Bool -- Flag to indicate whether the email check is performed
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email.address ≠ "" ∧ i.check = true
  post := fun i o => (o.exists_ = true ↔
    i.email.address = "test@example.com") ∧
    (o.exists_ = false ↔
      i.email.address ≠ "test@example.com" ∧ i.check = true)

example : Spec.pre { email := { address := "test@example.com" }, check := true } ∧
          Spec.post { email := { address := "test@example.com" }, check := true }
                    { exists_ := true } := by
  unfold Spec; decide
