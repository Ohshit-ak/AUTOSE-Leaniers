import ContractForge.Contract

namespace ContractForge.Contract

variable {α β γ : Type}

/-- PO1 + PO3 for both halves ⇒ the composed pipeline meets the composed contract. -/
theorem seq_sound {c₁ : Contract α β} {c₂ : Contract β γ} {f : α → β} {g : β → γ}
    (h12 : Compatible c₁ c₂) (hf : c₁.Satisfies f) (hg : c₂.Satisfies g) :
    (c₁.seq c₂).Satisfies (g ∘ f) := by
  intro x hx
  exact ⟨f x, hf x hx, hg (f x) (h12 x (f x) hx (hf x hx))⟩

/-- PO2 + PO3 ⇒ the implementation meets the spec. -/
theorem refines_sound {c s : Contract α β} {f : α → β}
    (hr : c.Refines s) (hf : c.Satisfies f) : s.Satisfies f := by
  intro x hx
  exact hr.2 x (f x) hx (hf x (hr.1 x hx))

/-- End-to-end: two compatible components whose composition refines the spec. -/
theorem system_sound {c₁ : Contract α β} {c₂ : Contract β γ} {s : Contract α γ}
    {f : α → β} {g : β → γ}
    (h12 : Compatible c₁ c₂) (hr : (c₁.seq c₂).Refines s)
    (hf : c₁.Satisfies f) (hg : c₂.Satisfies g) :
    s.Satisfies (g ∘ f) :=
  refines_sound hr (seq_sound h12 hf hg)

end ContractForge.Contract
