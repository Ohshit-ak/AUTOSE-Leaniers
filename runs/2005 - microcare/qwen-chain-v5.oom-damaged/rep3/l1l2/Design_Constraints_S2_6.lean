import ContractForge
open ContractForge

-- Design Constraints/S2#6: The following part will explain how the systems will validate every information during claim entry.

-- L0 spec

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

example : Spec.pre { claims := [{ amount := 500, code := "C1" }],
                     maxAmount := 1000 } ∧
          Spec.post { claims := [{ amount := 500, code := "C1" }],
                      maxAmount := 1000 }
                    { accepted := true, message := "" } := by
  unfold Spec; decide
