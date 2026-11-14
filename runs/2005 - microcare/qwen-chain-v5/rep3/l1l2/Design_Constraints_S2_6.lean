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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  totalExceeded : Bool
  message       : String
  claims : List Claim
  maxAmount : Nat
  deriving DecidableEq, Repr

def ComputeTotalExceededContract : Contract Input Mid where
  pre  := fun i => i.claims.Nodup ∧ 0 < i.maxAmount
  post := fun i m => (m.totalExceeded = 
      (∃ c ∈ i.claims, c.amount > i.maxAmount) ∧
    m.message = 
      if m.totalExceeded then "All claims exceed the maximum amount."
                           else "") ∧ m.claims = i.claims ∧ m.maxAmount = i.maxAmount

def DecideOutcomeContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => (o.accepted = true ↔ ∃ c ∈ m.claims, c.amount ≤ m.maxAmount) ∧
    (o.message = m.message) ∧
    (o.accepted = false → o.message = "All claims exceed the maximum amount.")



theorem po1 : Contract.Compatible ComputeTotalExceededContract DecideOutcomeContract := by
  discharge_po1 [ComputeTotalExceededContract, DecideOutcomeContract, Spec]

theorem po2 : Contract.Refines (ComputeTotalExceededContract.seq DecideOutcomeContract) Spec := by
  discharge_po2 [ComputeTotalExceededContract, DecideOutcomeContract, Spec]

-- L2 ComputeTotalExceededContract (success=True)

def ComputeTotalExceededContractImpl (x : Input) : Mid :=
  { totalExceeded := ∃ c ∈ x.claims, c.amount > x.maxAmount,
    message := if x.claims.any (fun c => c.amount > x.maxAmount) then "All claims exceed the maximum amount." else "",
    claims := x.claims,
    maxAmount := x.maxAmount }

theorem ComputeTotalExceededContractImpl_ok : ComputeTotalExceededContract.Satisfies ComputeTotalExceededContractImpl := by
  discharge_po3 [ComputeTotalExceededContract, ComputeTotalExceededContractImpl]

-- L2 DecideOutcomeContract (success=False)

def DecideOutcomeContractImpl (x : Mid) : Output :=
  { accepted := decide (∃ c ∈ x.claims, c.amount ≤ x.maxAmount),
    message := if decide (∃ c ∈ x.claims, c.amount ≤ x.maxAmount) then x.message else "All claims exceed the maximum amount." }
