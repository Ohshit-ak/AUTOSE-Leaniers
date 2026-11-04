import ContractForge.Soundness

/-!
# Chains of more than two components

`seq` and `system_sound` compose two contracts. L1 composes n components as the
left-nested chain `((c₁.seq c₂).seq c₃) …` in the order the requirements graph gives.
`system_sound` then needs PO1 between the chain built so far and the next component;
`compat_seq` gets it from the PO1s of consecutive components. New module: the
definitions in `Contract`/`Soundness` are unchanged.
-/

namespace ContractForge.Contract

variable {α β γ δ : Type}

/-- PO1 of consecutive components gives PO1 of the chain so far with the next one. -/
theorem compat_seq {c₁ : Contract α β} {c₂ : Contract β γ} {c₃ : Contract γ δ}
    (h12 : Compatible c₁ c₂) (h23 : Compatible c₂ c₃) : Compatible (c₁.seq c₂) c₃ := by
  intro x z hx ⟨y, hy1, hy2⟩
  exact h23 y z (h12 x y hx hy1) hy2

/-- Three components: PO1 for both consecutive pairs, PO2 for the chain, PO3 for each
component ⇒ the composed implementation meets the spec. -/
theorem chain3_sound {c₁ : Contract α β} {c₂ : Contract β γ} {c₃ : Contract γ δ}
    {s : Contract α δ} {f : α → β} {g : β → γ} {h : γ → δ}
    (h12 : Compatible c₁ c₂) (h23 : Compatible c₂ c₃) (hr : ((c₁.seq c₂).seq c₃).Refines s)
    (hf : c₁.Satisfies f) (hg : c₂.Satisfies g) (hh : c₃.Satisfies h) :
    s.Satisfies (h ∘ (g ∘ f)) :=
  system_sound (compat_seq h12 h23) hr (seq_sound h12 hf hg) hh

end ContractForge.Contract
