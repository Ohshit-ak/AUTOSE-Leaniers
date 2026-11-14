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
  deriving DecidableEq, Repr

def ComputeTotalExceededContract : Contract Input Mid where
  pre  := fun i => i.claims.Nodup ∧ 0 < i.maxAmount
  post := fun i m => 
    m.totalExceeded = 
      (∀ c ∈ i.claims, c.amount > i.maxAmount) ∧
    m.message = 
      if m.totalExceeded then "All claims exceed the maximum amount." else ""

def DecideAcceptanceContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o =>
    (o.accepted = true ↔ m.totalExceeded = false) ∧
    (o.accepted = false → o.message = m.message)

theorem po1 : Contract.Compatible ComputeTotalExceededContract DecideAcceptanceContract := by
  discharge_po1 [ComputeTotalExceededContract, DecideAcceptanceContract, Spec]

theorem po2 : Contract.Refines (ComputeTotalExceededContract.seq DecideAcceptanceContract) Spec := by
  discharge_po2 [ComputeTotalExceededContract, DecideAcceptanceContract, Spec]

-- L2 ComputeTotalExceededContract (success=True)

def ComputeTotalExceededContractImpl (x : Input) : Mid :=
  { totalExceeded := ∀ c ∈ x.claims, c.amount > x.maxAmount,
    message := if ∀ c ∈ x.claims, c.amount > x.maxAmount then "All claims exceed the maximum amount." else "" }

theorem ComputeTotalExceededContractImpl_ok : ComputeTotalExceededContract.Satisfies ComputeTotalExceededContractImpl := by
  discharge_po3 [ComputeTotalExceededContract, ComputeTotalExceededContractImpl]

-- L2 DecideAcceptanceContract (success=True)

def DecideAcceptanceContractImpl (x : Mid) : Output :=
  { accepted := decide (x.totalExceeded = false),
    message := if x.totalExceeded then x.message else "" }

theorem DecideAcceptanceContractImpl_ok : DecideAcceptanceContract.Satisfies DecideAcceptanceContractImpl := by
  discharge_po3 [DecideAcceptanceContract, DecideAcceptanceContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (DecideAcceptanceContractImpl ∘ ComputeTotalExceededContractImpl) :=
  Contract.system_sound po1 po2 ComputeTotalExceededContractImpl_ok DecideAcceptanceContractImpl_ok
