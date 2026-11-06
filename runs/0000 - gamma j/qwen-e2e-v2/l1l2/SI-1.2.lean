import ContractForge
open ContractForge

-- SI-1.2: Through programmatic interface, WebOrder will transmit information of items ordered by customers to the Inventory management system.

-- L0 spec

structure Item where
  name   : String
  count  : Nat
  deriving DecidableEq, Repr

structure Input where
  orderedItems : List Item
  deriving DecidableEq, Repr

structure Output where
  success  : Bool
  updatedItems : List Item
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderedItems.Nodup
  post := fun i o => (o.success = true ↔
    ∀ it ∈ i.orderedItems, ∃ uit ∈ o.updatedItems, uit.name = it.name ∧ uit.count = it.count + 1)

example : Spec.pre { orderedItems := [{ name := "Laptop", count := 3 }, { name := "Mouse", count := 2 }] } ∧ Spec.post { orderedItems := [{ name := "Laptop", count := 3 }, { name := "Mouse", count := 2 }] } { success := false, updatedItems := [{ name := "Laptop", count := 3 }, { name := "Mouse", count := 2 }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Mid where
  updatedItems : List Item
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.orderedItems.Nodup
  post := fun i m => m.updatedItems = i.orderedItems

def UpdateContract : Contract Mid Output where
  pre  := fun m => m.updatedItems.Nodup
  post := fun m o => (o.success = true ↔
    ∀ it ∈ m.updatedItems, it.count = it.count + 1)

theorem po1 : Contract.Compatible ValidateContract UpdateContract := by
  unfold Contract.Compatible ValidateContract UpdateContract
  intro i m _ h
  exact h.2

theorem po2 : Contract.Refines (ValidateContract.seq UpdateContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract UpdateContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hm1, hm2⟩, ho⟩
  simp only at *
  rw [ho, hm1, hm2]