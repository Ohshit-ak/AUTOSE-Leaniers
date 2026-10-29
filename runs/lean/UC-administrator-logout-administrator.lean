-- UC-administrator-logout-administrator: Logout Administrator: Logout the Administrator account on the system.
-- checked: None

structure Contract (Input Output) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure SystemState where
  sessionId : Option String

def Spec : Contract SystemState SystemState where
  pre s := s.sessionId ≠ none
  post s s' := s'.sessionId = none

example : Spec (SystemState.mk (some "session123")) (SystemState.mk none) :=
begin
  unfold Spec,
  split,
  { intro s, cases s with s, simp at s, exact s },
  { intro s, cases s with s, simp at s, exact s }
end
