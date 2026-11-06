import ContractForge
open ContractForge

-- REQ-2#3: Sending the hyperlink to the default browser will take less than 1 second.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 1000000

example : Spec.pre {} ∧ Spec.post {} { elapsedMicros := 950000 } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros < 1000000

-- Decompose the spec into two components

def Component1Contract : Contract Input Nat := 
  pre  := fun _ => True
  post := fun _ n => n < 1000000

def Component2Contract : Contract Nat Output := 
  pre  := fun n => n < 1000000
  post := fun n o => o.elapsedMicros = n

-- Prove PO1: Component1Contract and Component2Contract are compatible with Spec

theorem PO1 : Contract.Compatible Component1Contract (Component2Contract.seq Spec) :=
begin
  unfold Contract.Compatible,
  unfold Component1Contract,
  unfold Component2Contract,
  unfold Spec,
  unfold seq,
  unfold Contract.seq,
  unfold Contract.post,
  unfold Component1Contract.post,
  unfold Component2Contract.pre,
  unfold Component2Contract.post,
  unfold Spec.pre,
  unfold Spec.post,
  simp,
  discharge_po
end

-- Prove PO2: The composition of Component1Contract and Component2Contract refines Spec

theorem PO2 : Contract.Refines (Component1Contract.seq Component2Contract) Spec :=
begin
  unfold Contract.Refines,
  unfold Component1Contract,
  unfold Component2Contract,
  unfold Spec,
  unfold seq,
  unfold Contract.seq,
  unfold Contract.post,
  unfold Component1Contract.post,
  unfold Component2Contract.pre,
  unfold Component2Contract.post,
  unfold Spec.pre,
  unfold Spec.post,
  simp,
  discharge_po
end