import ContractForge
open ContractForge

-- UC-administrator-install-patch-process: Install patch process: Install patches or software updates to the web store.

-- L0 spec

structure Patch where
  version : String
  deriving DecidableEq, Repr

structure Input where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

structure Output where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i o => o.webStoreVersion = i.webStoreVersion ∧
                     o.success = true ∧
                     o.patches = i.patches

example : Spec.pre { webStoreVersion := "1.0.0", patches := [], success := true } ∧
          Spec.post { webStoreVersion := "1.0.0", patches := [], success := true }
                    { webStoreVersion := "1.0.0", patches := [], success := true } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  webStoreVersion : String
  patches         : List Patch
  success         : Bool
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i m => m.webStoreVersion = i.webStoreVersion ∧ m.success = i.success ∧ m.patches = i.patches

def ComputeContract : Contract Mid Output where
  pre  := fun m => m.success
  post := fun m o => o.webStoreVersion = m.webStoreVersion ∧ o.patches = m.patches ∧ o.success = true

theorem po1 : Contract.Compatible ValidateContract ComputeContract := by
  unfold Contract.Compatible ValidateContract ComputeContract
  intro i m _ h
  simp only at h
  exact h.2.2

theorem po2 : Contract.Refines (ValidateContract.seq ComputeContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract ComputeContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]