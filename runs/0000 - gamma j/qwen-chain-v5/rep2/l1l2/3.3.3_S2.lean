import ContractForge
open ContractForge

-- 3.3.3/S2: The shopping cart will clearly display the number of items in the cart, along with the total cost.

-- L0 spec

structure CartItem where
  name : String
  price : Nat
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List CartItem
  deriving DecidableEq, Repr

structure Output where
  itemCount : Nat
  totalCost : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => o.itemCount = (i.items.map (fun x => x.quantity)).sum ∧
                     o.totalCost = (i.items.map (fun x => x.quantity * x.price)).sum

example : Spec.pre { items := [{ name := "book", price := 10, quantity := 2 },
                                { name := "pen", price := 5, quantity := 3 }] } ∧
          Spec.post { items := [{ name := "book", price := 10, quantity := 2 },
                                 { name := "pen", price := 5, quantity := 3 }] }
                    { itemCount := 5, totalCost := 35 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { itemCount := (x.items.map (fun x => x.quantity)).sum,
    totalCost := (x.items.map (fun x => x.quantity * x.price)).sum }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
