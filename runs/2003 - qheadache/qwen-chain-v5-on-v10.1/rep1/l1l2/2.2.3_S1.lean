import ContractForge
open ContractForge

-- 2.2.3/S1: The product must count and display the number of the user' asction.

-- L0 spec

structure Input where
  actionCount : Nat
  deriving DecidableEq, Repr

structure Output where
  actionCount : Nat
  displaying   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.actionCount = i.actionCount ∧ o.displaying = true

example : Spec.pre { actionCount := 5 } ∧
          Spec.post { actionCount := 5 } { actionCount := 5, displaying := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { actionCount := x.actionCount,
    displaying := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
