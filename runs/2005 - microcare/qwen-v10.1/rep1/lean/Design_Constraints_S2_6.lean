import ContractForge
open ContractForge

-- Design Constraints/S2#6: The following part will explain how the systems will validate every information during claim entry.
-- compiles: False · rejects_bad_example: None · checked: False

structure Claim where
  amount : Nat
  code   : String
  deriving DecidableEq, Repr

structure Input where
  claims : List Claim
  maxAmount : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.claims.Nodup ∧ 0 < i.maxAmount
  post := fun i o =>
    (o.accepted = true ↔
      ∃ c ∈ i.claims, c.amount ≤ i.maxAmount) ∧
    (o.accepted = false →
      o.message = "All claims exceed the maximum amount.")

example : Spec.pre { claims := [{ amount := 50, code := "A1" },
                                 { amount := 70, code := "B2" }],
                     maxAmount := 100 } ∧
          Spec.post { claims := [{ amount := 50, code := "A1" },
                                 { amount := 70, code := "B2" }],
                     maxAmount := 100 }
                    { accepted := false, message := "All claims exceed the maximum amount." } := by
  unfold Spec; decide
