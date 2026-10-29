-- UC-customer-logout-customer: Logout Customer: Logout the customer account on the system.
-- checked: None

structure Contract (Input Output : Type) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure SystemState where
  sessionId : Option String

def Spec : Contract SystemState SystemState where
  pre s := s.sessionId ≠ none
  post s1 s2 := s1.sessionId = none ∧ s2.sessionId = none

example : Spec :=
begin
  -- Example witness
  let s1 := SystemState.mk (some "abc123"),
  let s2 := SystemState.mk none,
  exact ⟨s1, s2, by simp⟩
end
