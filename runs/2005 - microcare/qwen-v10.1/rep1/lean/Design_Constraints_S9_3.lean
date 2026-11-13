import ContractForge
open ContractForge

-- Design Constraints/S9#3: The authorized user can alter / amend the Claim if required.
-- compiles: True · rejects_bad_example: None · checked: False

structure Claim where
  id          : Nat
  user        : String
  status      : String
  description : String
  amount      : Nat
  deriving DecidableEq, Repr

structure Input where
  claims : List Claim
  id     : Nat
  user   : String
  status : String
  description : String
  amount   : Nat
  deriving DecidableEq, Repr

structure Output where
  claims : List Claim
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user ≠ "" ∧ i.id ≠ 0 ∧
                  ∃ c ∈ i.claims, c.user = i.user ∧ c.id = i.id
  post := fun i o => (o.claims.length = i.claims.length ∧
                      ∀ c ∈ o.claims, (c.id = i.id →
                        (c.status = i.status ∧
                         c.description = i.description ∧
                         c.amount = i.amount) ∨
                        (c.id ≠ i.id ∧
                         ∃ c' ∈ i.claims, c'.id = i.id ∧
                         c = c'))) ∧
                     (o.claims.length = i.claims.length →
                      ∃ c ∈ o.claims, c.id = i.id ∧
                      (c.status = i.status ∨
                       c.description = i.description ∨
                       c.amount = i.amount))

example : Spec.pre { claims := [{ id := 1, user := "user1", status := "pending", description := "claim1", amount := 500 }],
                     id := 1, user := "user1", status := "amended", description := "claim1", amount := 600 } ∧
          Spec.post { claims := [{ id := 1, user := "user1", status := "amended", description := "claim1", amount := 600 }],
                      id := 1, user := "user1", status := "amended", description := "claim1", amount := 600 }
                    { claims := [{ id := 1, user := "user1", status := "amended", description := "claim1", amount := 600 }] } := by
  unfold Spec; decide
