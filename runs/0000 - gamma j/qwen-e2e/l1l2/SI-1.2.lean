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

-- Decompose the spec into two components

def UpdateContract : Contract Input Output where
  pre  := fun i => i.orderedItems.Nodup
  post := fun i o => (o.success = true ↔
    ∀ it ∈ i.orderedItems, ∃ uit ∈ o.updatedItems, uit.name = it.name ∧ uit.count = it.count + 1)

def CheckNodupContract : Contract Input Input where
  pre  := fun i => i.orderedItems.Nodup
  post := fun i i' => i = i'

-- Prove PO1: UpdateContract's assumption follows from CheckNodupContract's guarantee
theorem PO1 : Contract.Compatible (CheckNodupContract.post) (UpdateContract.pre) :=
  by
  intro i i' h
  unfold CheckNodupContract UpdateContract
  simp [h]
  exact h

-- Prove PO2: the composition refines the spec
theorem PO2 : Contract.Refines (CheckNodupContract.seq UpdateContract) Spec :=
  by
  unfold CheckNodupContract UpdateContract Spec
  simp
  exact Contract.system_sound