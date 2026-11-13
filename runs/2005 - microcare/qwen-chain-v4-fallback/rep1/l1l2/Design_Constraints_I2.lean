import ContractForge
open ContractForge

-- Design Constraints/I2: The will be a provision to create a minimum quantity of vouchers at one time (such minimum numbers will be decided by the management team).

-- L0 spec

structure Input where
  quantity : Nat
  minQuantity : Nat
  deriving DecidableEq, Repr

structure Output where
  created : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.minQuantity
  post := fun i o => o.created = i.quantity ∧ i.quantity ≥ i.minQuantity

example : Spec.pre { quantity := 10, minQuantity := 5 } ∧
          Spec.post { quantity := 10, minQuantity := 5 }
                    { created := 10 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { created := x.quantity }
