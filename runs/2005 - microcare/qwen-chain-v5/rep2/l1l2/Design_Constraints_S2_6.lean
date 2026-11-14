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
  maxAmount : Nat
  accepted  : Bool
  message   : String
  claims : List Claim
  deriving DecidableEq, Repr

def ComputeMidContract : Contract Input Mid where
  pre  := fun i => i.claims.Nodup ∧ 0 < i.maxAmount
  post := fun i m => (m.maxAmount = i.maxAmount ∧
    (m.accepted = true ↔
      ∃ c ∈ i.claims, c.amount ≤ i.maxAmount) ∧
    (m.accepted = false →
      m.message = "All claims exceed the maximum amount.")) ∧ m.claims = i.claims

def FinalizeContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.accepted = m.accepted ∧
    o.message = m.message ∧
    (o.accepted = true →
      ∃ c ∈ m.claims, c.amount ≤ m.maxAmount)



theorem po1 : Contract.Compatible ComputeMidContract FinalizeContract := by
  discharge_po1 [ComputeMidContract, FinalizeContract, Spec]

theorem po2 : Contract.Refines (ComputeMidContract.seq FinalizeContract) Spec := by
  discharge_po2 [ComputeMidContract, FinalizeContract, Spec]

-- L2 ComputeMidContract (success=True)

def ComputeMidContractImpl (x : Input) : Mid :=
  { maxAmount := x.maxAmount,
    accepted := decide (∃ c ∈ x.claims, c.amount ≤ x.maxAmount),
    message := if decide (∃ c ∈ x.claims, c.amount ≤ x.maxAmount) = true then "" else "All claims exceed the maximum amount.",
    claims := x.claims }

theorem ComputeMidContractImpl_ok : ComputeMidContract.Satisfies ComputeMidContractImpl := by
  discharge_po3 [ComputeMidContract, ComputeMidContractImpl]

-- L2 FinalizeContract (success=False)

def FinalizeContractImpl (x : Mid) : Output :=
  { accepted := decide (∃ c ∈ x.claims, c.amount ≤ x.maxAmount),
    message := x.message }
