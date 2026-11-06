import ContractForge
open ContractForge

-- 5.1/R1: Upon the USB being plugged in the system shall be able to be deployed and operational in less than 1 minute.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 60000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 59999999 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 60000000

-- Decompose the spec into two components

def Component1Contract : Contract Input (Output × Nat) where
  pre  := fun _ => True
  post := fun _ (o, _) => o.elapsedMicros < 50000000

def Component2Contract : Contract (Output × Nat) Output where
  pre  := fun (o, _) => o.elapsedMicros < 50000000
  post := fun (o, _) o' => o'.elapsedMicros < 60000000

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
theorem PO1 : Contract.Compatible Component1Contract Spec :=
  by
    unfold Component1Contract Spec
    intros x
    simp [Contract.pre, Contract.post]
    exact dec_trivial

theorem PO1' : Contract.Compatible Component2Contract Component1Contract :=
  by
    unfold Component2Contract Component1Contract
    intros (o, elapsed) o'
    simp [Contract.pre, Contract.post]
    exact dec_trivial

-- Prove PO2: the composition refines the spec
theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec :=
  by
    unfold Component1Contract Component2Contract Spec
    intros x
    simp [Contract.pre, Contract.post, Contract.seq]
    exact dec_trivial