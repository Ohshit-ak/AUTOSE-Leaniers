import ContractForge
open ContractForge

-- REQ-3#3: Loading the program will take less than 10 seconds.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 10000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 9000000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 10000000

-- Decompose the spec into two components

def Component1Contract : Contract Input (Output × Nat) := 
  { pre  := fun _ => True
    post := fun _ (o, _) => o.elapsedMicros < 5000000 }

def Component2Contract : Contract (Output × Nat) Output := 
  { pre  := fun (o, _) => o.elapsedMicros < 5000000
    post := fun (o, _) o' => o'.elapsedMicros < 10000000 }

-- Prove PO1: Component1Contract's assumption follows from Spec's guarantee
example : Contract.Compatible Component1Contract Spec := by
  unfold Component1Contract Spec; discharge_po

-- Prove PO2: Component1Contract and Component2Contract refine the spec
example : Contract.Refines (Component1Contract.seq Component2Contract) Spec := by
  unfold Component1Contract Component2Contract Spec; discharge_po