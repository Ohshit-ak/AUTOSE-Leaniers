-- DD-location: Place where the item is kept in the warehouse in the form of (aisle, column, shelf)
-- checked: None

structure Location where
  aisle : Nat
  column : Nat
  shelf : Nat

def pre (raw : List Nat) : Prop :=
  raw.length = 3 ∧
  raw[0] = aisle ∧
  raw[1] = column ∧
  raw[2] = shelf

def post (raw : List Nat) (loc : Location) : Prop :=
  raw.length = 3 ∧
  raw[0] = loc.aisle ∧
  raw[1] = loc.column ∧
  raw[2] = loc.shelf

def Spec : Contract (List Nat) Location :=
  { pre := pre
    post := post }

example : Spec.pre [1, 2, 3] :=
  by simp

example : Spec.post [1, 2, 3] (Location.mk 1 2 3) :=
  by simp
