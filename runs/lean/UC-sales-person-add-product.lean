-- UC-sales-person-add-product: Add Product: Add a product to the system.
-- checked: None

structure Product where
  name : String
  price : Nat
  description : String

structure Input where
  newProduct : Product
  existingProducts : List Product

structure Output where
  updatedProducts : List Product

def Spec : Contract Input Output where
  pre input := true -- Assuming the input is always valid for this example
  post input output := 
    List.Perm input.existingProducts output.updatedProducts ∧
    output.updatedProducts.length = input.existingProducts.length + 1 ∧
    let newProduct := input.newProduct;
    let lastProduct := output.updatedProducts.last;
    lastProduct = newProduct

example : Spec :=
  { input := { newProduct := { name := "New Product", price := 100, description := "Description" },
               existingProducts := [] },
    output := { updatedProducts := [ { name := "New Product", price := 100, description := "Description" } ] } }
