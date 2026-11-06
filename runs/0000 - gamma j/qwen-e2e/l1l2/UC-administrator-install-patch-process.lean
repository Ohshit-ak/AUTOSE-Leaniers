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

-- Component 1: Ensure webStoreVersion is non-empty
def Component1Contract : Contract Input Input where
  pre  := fun i => i.webStoreVersion ≠ ""
  post := fun i i' => i' = i

-- Component 2: Apply patches and ensure success is true
def Component2Contract : Contract Input Output where
  pre  := fun i => i.webStoreVersion ≠ "" ∧ i.success
  post := fun i o => o.webStoreVersion = i.webStoreVersion ∧
                     o.success = true ∧
                     o.patches = i.patches

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
theorem PO1 : Contract.Compatible (Component1Contract) Spec := by
  intros i o hpre hpost
  unfold Component1Contract Spec
  simp [hpost]
  discharge_po

-- Prove PO2: The composition refines the spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  intros i o hpre hpost
  unfold Component1Contract Component2Contract Spec
  simp [hpre, hpost]
  discharge_po

example : Spec.pre { webStoreVersion := "1.0.0", patches := [], success := true } ∧
          Spec.post { webStoreVersion := "1.0.0", patches := [], success := true }
                    { webStoreVersion := "1.0.0", patches := [], success := true } := by
  unfold Spec; decide