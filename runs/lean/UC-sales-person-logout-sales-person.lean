-- UC-sales-person-logout-sales-person: Logout Sales Person: Logout the Sales Person account on the system.
-- checked: None

structure Contract (α β : Type) where
  pre  : α → Prop
  post : α → β → Prop

structure SystemState where
  sessionId : Option String

def Spec : Contract SystemState SystemState where
  pre s := s.sessionId ≠ none
  post s1 s2 := s1.sessionId = none ∧ s2.sessionId = none

example : Spec := by
  let s1 := SystemState.mk (some "session123")
  let s2 := SystemState.mk none
  exact ⟨s1, s2, by simp⟩
