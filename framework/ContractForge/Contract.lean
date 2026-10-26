namespace ContractForge

/-- An assume/guarantee contract: `pre` is what the component assumes about
its input, `post` is what it guarantees about its output. -/
structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

namespace Contract

variable {α β γ : Type}

/-- PO3: implementation `f` meets contract `c`. -/
def Satisfies (c : Contract α β) (f : α → β) : Prop :=
  ∀ x, c.pre x → c.post x (f x)

/-- PO1: `c₁`'s guarantee establishes `c₂`'s assumption. -/
def Compatible (c₁ : Contract α β) (c₂ : Contract β γ) : Prop :=
  ∀ x y, c₁.pre x → c₁.post x y → c₂.pre y

/-- PO2: `c` refines spec `s` (assumes no more, guarantees at least as much). -/
def Refines (c s : Contract α β) : Prop :=
  (∀ x, s.pre x → c.pre x) ∧ (∀ x y, s.pre x → c.post x y → s.post x y)

/-- Sequential composition: run a `c₁` component, feed its output to a `c₂` one. -/
def seq (c₁ : Contract α β) (c₂ : Contract β γ) : Contract α γ where
  pre x    := c₁.pre x
  post x z := ∃ y, c₁.post x y ∧ c₂.post y z

end Contract

structure Component where
  name : String

structure System where
  components : List Component
  -- start simple, add deps later

end ContractForge
