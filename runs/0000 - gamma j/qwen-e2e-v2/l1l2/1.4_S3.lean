import ContractForge
open ContractForge

-- 1.4/S3: Expandable with unique codes, the owners can purchase to expand the inventory.

-- L0 spec

structure Code where
  code : String
  unique : Bool
  deriving DecidableEq, Repr

structure Input where
  inventory : List Code
  purchases : List Code
  deriving DecidableEq, Repr

structure Output where
  inventory : List Code
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.purchases.all (fun c => c.unique)
  post := fun i o => o.inventory.length = i.inventory.length + i.purchases.length ∧
                     ∀ c ∈ i.purchases, c ∈ o.inventory ∧ c.unique

example : Spec.pre { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } ∧ Spec.post { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }], purchases := [] } { inventory := [{ code := "A1", unique := true }, { code := "A2", unique := false }, { code := "A3", unique := true }, { code := "A4", unique := true }] } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  inventory : List Code
  purchases : List Code
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.purchases.all (fun c => c.unique)
  post := fun i m => m.purchases = i.purchases ∧ m.inventory = i.inventory

def UpdateContract : Contract Mid Output where
  pre  := fun m => m.purchases.all (fun c => c.unique)
  post := fun m o => o.inventory.length = m.inventory.length + m.purchases.length ∧
                     ∀ c ∈ m.purchases, c ∈ o.inventory ∧ c.unique

theorem po1 : Contract.Compatible ValidateContract UpdateContract := by
  discharge_po [Spec, UpdateContract, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq UpdateContract) Spec := by
  discharge_po [Spec, UpdateContract, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid :=
  { inventory := i.inventory, purchases := i.purchases }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [Spec, UpdateContract, ValidateContract, ValidateContractImpl]

-- L2 UpdateContract (success=True)

def UpdateContractImpl (m : Mid) : Output := { inventory := m.inventory ++ m.purchases.filter (fun c => c.unique) }

theorem UpdateContractImpl_ok : UpdateContract.Satisfies UpdateContractImpl := by
  discharge_po [Spec, UpdateContract, UpdateContractImpl, ValidateContract]