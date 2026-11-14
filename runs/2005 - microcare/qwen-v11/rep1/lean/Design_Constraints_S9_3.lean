import ContractForge
open ContractForge

-- Design Constraints/S9#3: The authorized user can alter / amend the Claim if required.
-- compiles: False · rejects_bad_example: None · checked: False

structure Claim where
  id       : Nat
  status   : String
  amount   : Nat
  deriving DecidableEq, Repr

structure Input where
  claims   : List Claim
  claimId  : Nat
  status   : String
  amount   : Nat
  deriving DecidableEq, Repr

structure Output where
  claims   : List Claim
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.claimId < i.claims.length ∧ i.claims.get? i.claimId ≠ none
  post := fun i o => o.claims = i.claims.map (fun c =>
    if c.id = i.claimId then
      { c with status := i.status, amount := i.amount }
    else
      c)

example : Spec.pre { claims := [{ id := 1, status := "draft", amount := 1000 },
                                { id := 2, status := "draft", amount := 2000 }],
                    claimId := 1, status := "approved", amount := 1500 } ∧
          Spec.post { claims := [{ id := 1, status := "draft", amount := 1000 },
                                 { id := 2, status := "draft", amount := 2000 }],
                      claimId := 1, status := "approved", amount := 1500 }
                    { claims := [{ id := 1, status := "approved", amount := 1500 },
                                 { id := 2, status := "draft", amount := 2000 }] } := by
  unfold Spec; decide
