import ContractForge
open ContractForge

-- UC-sales-person-remove-product: Remove Product: Remove a product from the system.

-- L0 spec

structure Product where
  name   : String
  price  : Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  name     : String
  price    : Nat
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.products.Nodup
  post := fun i o => o.products = i.products.filter (fun p => p.name ≠ i.name ∧ p.price ≠ i.price)

example : Spec.pre { products := [{ name := "apple", price := 100 },
                                   { name := "banana", price := 200 }],
                     name := "apple", price := 100 } ∧
          Spec.post { products := [{ name := "apple", price := 100 },
                                    { name := "banana", price := 200 }],
                      name := "apple", price := 100 }
                    { products := [{ name := "banana", price := 200 }] } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  products : List Product
  deriving DecidableEq, Repr

def FilterContract : Contract Input Mid where
  pre  := fun i => i.products.Nodup
  post := fun i m => m.products = i.products.filter (fun p => p.name ≠ i.name ∧ p.price ≠ i.price)

def UpdateContract : Contract Mid Output where
  pre  := fun m => m.products.Nodup
  post := fun m o => o.products = m.products

theorem po1 : Contract.Compatible FilterContract UpdateContract := by
  discharge_po [FilterContract, Spec, UpdateContract]

theorem po2 : Contract.Refines (FilterContract.seq UpdateContract) Spec := by
  discharge_po [FilterContract, Spec, UpdateContract]

-- L2 FilterContract (success=True)

def FilterContractImpl (i : Input) : Mid := { products := i.products.filter (fun p => p.name ≠ i.name ∧ p.price ≠ i.price) }

theorem FilterContractImpl_ok : FilterContract.Satisfies FilterContractImpl := by
  discharge_po [FilterContract, FilterContractImpl, Spec, UpdateContract]

-- L2 UpdateContract (success=True)

def UpdateContractImpl (m : Mid) : Output := { products := m.products }

theorem UpdateContractImpl_ok : UpdateContract.Satisfies UpdateContractImpl := by
  discharge_po [FilterContract, Spec, UpdateContract, UpdateContractImpl]