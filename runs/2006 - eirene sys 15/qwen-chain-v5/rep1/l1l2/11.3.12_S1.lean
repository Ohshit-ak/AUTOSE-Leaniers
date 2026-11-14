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

def FinalizeOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.mobileId = m.mobileId ∧
                     (o.success = true ↔ m.result ≠ 0) ∧
                     (o.success = false → m.result = 0)

theorem po1 : Contract.Compatible ComputeMobileIdContract FinalizeOutputContract := by
  discharge_po1 [ComputeMobileIdContract, FinalizeOutputContract, Spec]

theorem po2 : Contract.Refines (ComputeMobileIdContract.seq FinalizeOutputContract) Spec := by
  discharge_po2 [ComputeMobileIdContract, FinalizeOutputContract, Spec]

-- L2 ComputeMobileIdContract (success=True)

def ComputeMobileIdContractImpl (x : Input) : Mid :=
  { mobileId := x.mobileId,
    result := x.mobileId + 1 }

theorem ComputeMobileIdContractImpl_ok : ComputeMobileIdContract.Satisfies ComputeMobileIdContractImpl := by
  discharge_po3 [ComputeMobileIdContract, ComputeMobileIdContractImpl]

-- L2 FinalizeOutputContract (success=True)

def FinalizeOutputContractImpl (x : Mid) : Output :=
  { mobileId := x.mobileId,
    success := decide (x.result ≠ 0) }

theorem FinalizeOutputContractImpl_ok : FinalizeOutputContract.Satisfies FinalizeOutputContractImpl := by
  discharge_po3 [FinalizeOutputContract, FinalizeOutputContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (FinalizeOutputContractImpl ∘ ComputeMobileIdContractImpl) :=
  Contract.system_sound po1 po2 ComputeMobileIdContractImpl_ok FinalizeOutputContractImpl_ok
