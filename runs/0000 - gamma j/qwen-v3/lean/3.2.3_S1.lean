-- 3.2.3/S1: Products will be stored in multi-tiered categories; a category can contain sub categories or products.
-- checked: False

structure Input where
  category : String
  subcat   : Option String
  product  : Option String
  deriving DecidableEq, Repr

structure Output where
  category : String
  subcat   : Option String
  product  : Option String
  valid    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.category ≠ "" ∧ (i.subcat.isSome ∨ i.product.isSome)
  post := fun i o => o.valid = true ∧
                     (i.subcat.isSome →
                       (o.category = i.category ∧ o.subcat = i.subcat.get ∧ o.product = none)) ∧
                     (i.product.isSome →
                       (o.category = i.category ∧ o.subcat = none ∧ o.product = i.product.get)) ∧
                     (i.subcat.isNone ∧ i.product.isNone →
                       (o.category = i.category ∧ o.subcat = none ∧ o.product = none))

example : Spec.pre { category := "Electronics", subcat := some "Computers", product := none } ∧
          Spec.post { category := "Electronics", subcat := some "Computers", product := none }
                     { category := "Electronics", subcat := some "Computers", product := none, valid := true } := by
  unfold Spec; decide
