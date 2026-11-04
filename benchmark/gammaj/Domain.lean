-- STATUS: DRAFT, needs human review
/-!
# GAMMA-J Web Store — shared domain types (L1)

Extracted from `benchmark/gammaj/GammaJ_L0.lean` (hand-written gold): `Product`, `CartLine`,
`Cart`, `Account`, `Order` and the helpers `qtyOf`, `itemCount`, `totalCost`, unchanged
except that every structure derives `DecidableEq, Repr` (so equality of values and lists of
them is decidable). Lean core only. Locked during L1: the harness hashes this file.
-/

/-- A product in the store. Prices are in cents. -/
structure Product where
  id    : String
  price : Nat
  deriving DecidableEq, Repr

/-- One line of a shopping cart. -/
structure CartLine where
  product : Product
  qty     : Nat
  deriving DecidableEq, Repr

/-- A shopping cart. -/
abbrev Cart := List CartLine

/-- Units of the product with id `pid` in the cart. -/
def qtyOf (c : Cart) (pid : String) : Nat :=
  ((c.filter (fun l => l.product.id == pid)).map (·.qty)).sum

/-- Number of items in the cart (sum of quantities). -/
def itemCount (c : Cart) : Nat := (c.map (·.qty)).sum

/-- Total cost of the cart in cents. -/
def totalCost (c : Cart) : Nat := (c.map (fun l => l.qty * l.product.price)).sum

/-- A registered customer account. -/
structure Account where
  email    : String
  password : String
  name     : String
  billing  : String
  shipping : String
  deriving DecidableEq, Repr

/-- A placed order. -/
structure Order where
  lines : Cart
  total : Nat
  deriving DecidableEq, Repr

-- Decidable over `List`: these evaluate with `decide`.
example : itemCount [⟨⟨"AB12345", 500⟩, 2⟩] = 2 := by decide
example : totalCost [⟨⟨"AB12345", 500⟩, 2⟩] = 1000 := by decide
example : qtyOf [⟨⟨"AB12345", 500⟩, 2⟩, ⟨⟨"ZZ00001", 100⟩, 1⟩] "AB12345" = 2 := by decide
example : (⟨"a@b.in", "pass1234", "Ada", "x", "x"⟩ : Account) ∈
    [(⟨"a@b.in", "pass1234", "Ada", "x", "x"⟩ : Account)] := by decide
