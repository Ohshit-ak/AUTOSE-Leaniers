-- 3.2.3/S2: The inventory management will allow for administrators to update the categories, the products placed in categories, and the specific product details.
-- checked: None

structure Category := (name : String)

structure Product := (name : String)
                   (details : String)

structure Inventory :=
  (categories : List Category)
  (products : List (Category × Product))

structure UpdateRequest :=
  (categories : List Category)
  (products : List (Category × Product))
  (productDetails : List (Product × String))

def Spec : Contract UpdateRequest Inventory :=
  { pre := λ u, 
      let categories' := u.categories,
          products' := u.products,
          productDetails' := u.productDetails,
      List.Perm categories' (Inventory.categories u) ∧
      List.Perm (List.zip categories' products') (List.zip (Inventory.categories u) (Inventory.products u)) ∧
      List.Perm (List.zip (Inventory.products u) productDetails') (List.zip (Inventory.products u) productDetails')
  , post := λ u inv',
      let categories' := u.categories,
          products' := u.products,
          productDetails' := u.productDetails,
      inv'.categories = categories' ∧
      inv'.products = (List.zip categories' products').map (λ p, (p.1, p.2.details := (List.mem_product_details u p))))
  
  where List.mem_product_details u p := List.mem (p.1, p.2) (List.zip (Inventory.products u) productDetails')

example : Spec
where
  u := UpdateRequest.mk
    #[Category.mk "Electronics"]
    #[(Category.mk "Electronics", Product.mk "Laptop" "A high-end laptop")]
    #[((Product.mk "Laptop" "A high-end laptop"), "A new detail for the laptop")]
  inv := Inventory.mk
    #[Category.mk "Electronics"]
    #[(Category.mk "Electronics", Product.mk "Laptop" "An old detail for the laptop")]
  inv' := Inventory.mk
    #[Category.mk "Electronics"]
    #[(Category.mk "Electronics", Product.mk "Laptop" "A new detail for the laptop")]
