import ContractForge
open ContractForge

-- UC-sales-person-update-product-attributes: Update Product Attributes: Update Product attributes within the system.

-- L0 spec

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Output where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock ∧
                     o.rating = i.rating

example : Spec.pre { name := "Laptop", price := 1000, stock := 50, rating := 4 } ∧
          Spec.post { name := "Laptop", price := 1000, stock := 50, rating := 4 }
                    { name := "Laptop", price := 1000, stock := 50, rating := 4 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Output where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock ∧
                     o.rating = i.rating

def NameContract : Contract Input Input := 
  { pre  := fun i => i.name ≠ ""
    post := fun i i' => i' = i }

def PriceStockContract : Contract Input Input := 
  { pre  := fun i => 0 < i.price ∧ i.stock > 0
    post := fun i i' => i'.price = i.price ∧ i'.stock = i.stock }

def RatingContract : Contract Input Input := 
  { pre  := fun i => i.rating > 0
    post := fun i i' => i'.rating = i.rating }

def NamePriceStockContract : Contract Input Input := 
  { pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0
    post := fun i i' => i'.name = i.name ∧ i'.price = i.price ∧ i'.stock = i.stock }

def NamePriceStockRatingContract : Contract Input Input := 
  { pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
    post := fun i i' => i'.name = i.name ∧ i'.price = i.price ∧ i'.stock = i.stock ∧ i'.rating = i.rating }

def NamePriceStockRatingContract : Contract Input Output := 
  { pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
    post := fun i o => o.name = i.name ∧
                       o.price = i.price ∧
                       o.stock = i.stock ∧
                       o.rating = i.rating }

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible NameContract PriceStockContract := by
  unfold NameContract PriceStockContract; discharge_po

example : Contract.Compatible PriceStockContract RatingContract := by
  unfold PriceStockContract RatingContract; discharge_po

example : Contract.Compatible RatingContract NamePriceStockRatingContract := by
  unfold RatingContract NamePriceStockRatingContract; discharge_po

-- Prove PO2: the composition refines the spec
example : Contract.Refines (NameContract.seq PriceStockContract.seq RatingContract) Spec := by
  unfold NameContract PriceStockContract RatingContract Spec; discharge_po