import ContractForge
open ContractForge

-- 2.6.3/S17: However it must be recognized that:

-- L0 spec

structure Input where
  amount  : Nat
  limit   : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  fee      : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.limit
  post := fun i o => (o.accepted = true ↔ i.amount ≤ i.limit) ∧
                     (o.accepted = false → o.fee = 0)

example : Spec.pre { amount := 5, limit := 10 } ∧
          Spec.post { amount := 5, limit := 10 } { accepted := true, fee := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  accepted : Bool
  deriving DecidableEq, Repr

def ComputeAcceptanceContract : Contract Input Mid where
  pre  := fun i => 0 < i.limit
  post := fun i m => m.accepted = true ↔ i.amount ≤ i.limit

def ComputeFeeContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.accepted = m.accepted ∧ o.fee = if m.accepted then 0 else 0

theorem po1 : Contract.Compatible ComputeAcceptanceContract ComputeFeeContract := by
  discharge_po1 [ComputeAcceptanceContract, ComputeFeeContract, Spec]

theorem po2 : Contract.Refines (ComputeAcceptanceContract.seq ComputeFeeContract) Spec := by
  discharge_po2 [ComputeAcceptanceContract, ComputeFeeContract, Spec]

-- L2 ComputeAcceptanceContract (success=True)

def ComputeAcceptanceContractImpl (x : Input) : Mid :=
  { accepted := decide (x.amount ≤ x.limit) }

theorem ComputeAcceptanceContractImpl_ok : ComputeAcceptanceContract.Satisfies ComputeAcceptanceContractImpl := by
  discharge_po3 [ComputeAcceptanceContract, ComputeAcceptanceContractImpl]

-- L2 ComputeFeeContract (success=True)

def ComputeFeeContractImpl (x : Mid) : Output :=
  { accepted := x.accepted, fee := if x.accepted then 0 else 0 }

theorem ComputeFeeContractImpl_ok : ComputeFeeContract.Satisfies ComputeFeeContractImpl := by
  discharge_po3 [ComputeFeeContract, ComputeFeeContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ComputeFeeContractImpl ∘ ComputeAcceptanceContractImpl) :=
  Contract.system_sound po1 po2 ComputeAcceptanceContractImpl_ok ComputeFeeContractImpl_ok
