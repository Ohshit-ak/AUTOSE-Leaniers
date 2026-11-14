import ContractForge
open ContractForge

-- 3.4.1/S8: This should greatly simplify the coordination problem posed by the large number of simultaneous users (as already described in the Capacity requirements, Section 3.2.2).

-- L0 spec

structure Input where
  userCount : Nat
  deriving DecidableEq, Repr

structure Output where
  userCount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.userCount > 0
  post := fun i o => o.userCount = i.userCount ∧
                     (i.userCount ≥ 100 → o.userCount ≥ 101)

example : Spec.pre { userCount := 1 } ∧ Spec.post { userCount := 1 } { userCount := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { userCount := if x.userCount ≥ 100 then x.userCount + 1 else x.userCount }
