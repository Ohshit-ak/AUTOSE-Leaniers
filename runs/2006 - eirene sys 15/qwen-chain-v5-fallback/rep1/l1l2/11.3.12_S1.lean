import ContractForge
open ContractForge

-- 11.3.12/S1: The result of the deregistration procedure shall be sent back to the mobile.

-- L0 spec

structure Input where
  mobileId : Nat
  deriving DecidableEq, Repr

structure Output where
  mobileId : Nat
  success  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileId ≠ 0
  post := fun i o => o.mobileId = i.mobileId ∧
                     (o.success = true ↔ o.mobileId ≠ 0) ∧
                     (o.success = false → o.mobileId = 0)

example : Spec.pre { mobileId := 123 } ∧
          Spec.post { mobileId := 123 }
                    { mobileId := 123, success := true } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  mobileId : Nat
  result   : Nat
  deriving DecidableEq, Repr

def ComputeMobileIdContract : Contract Input Mid where
  pre  := fun i => i.mobileId ≠ 0
  post := fun i m => m.mobileId = i.mobileId ∧ m.result = i.mobileId + 1

def DetermineSuccessContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.mobileId = m.mobileId ∧
                     (o.success = true ↔ m.result ≠ 0) ∧
                     (o.success = false → m.result = 0)

theorem po1 : Contract.Compatible ComputeMobileIdContract DetermineSuccessContract := by
  discharge_po1 [ComputeMobileIdContract, DetermineSuccessContract, Spec]

theorem po2 : Contract.Refines (ComputeMobileIdContract.seq DetermineSuccessContract) Spec := by
  discharge_po2 [ComputeMobileIdContract, DetermineSuccessContract, Spec]

-- L2 ComputeMobileIdContract (success=True)

def ComputeMobileIdContractImpl (x : Input) : Mid :=
  { mobileId := x.mobileId,
    result := x.mobileId + 1 }

theorem ComputeMobileIdContractImpl_ok : ComputeMobileIdContract.Satisfies ComputeMobileIdContractImpl := by
  discharge_po3 [ComputeMobileIdContract, ComputeMobileIdContractImpl]

-- L2 DetermineSuccessContract (success=True)

def DetermineSuccessContractImpl (x : Mid) : Output :=
  { mobileId := x.mobileId,
    success := decide (x.result ≠ 0) }

theorem DetermineSuccessContractImpl_ok : DetermineSuccessContract.Satisfies DetermineSuccessContractImpl := by
  discharge_po3 [DetermineSuccessContract, DetermineSuccessContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (DetermineSuccessContractImpl ∘ ComputeMobileIdContractImpl) :=
  Contract.system_sound po1 po2 ComputeMobileIdContractImpl_ok DetermineSuccessContractImpl_ok
