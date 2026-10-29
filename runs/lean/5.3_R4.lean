-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- checked: None

structure Contract (Input : Type) (Output : Type) where
  pre  : Input → Prop
  post : Input → Output → Prop

structure IPAddress where
  addr : Nat

structure AttackRecord where
  ip : IPAddress
  count : Nat

def Spec : Contract (List AttackRecord) Bool where
  pre input := true
  post input blocked :=
    input =· input.filter (fun ar => ar.count < 100) ∧
    blocked =· (input.any (fun ar => ar.count >= 100)).ip ≠· none

example : Spec (List.mk [AttackRecord.mk (IPAddress.mk 1) 100, AttackRecord.mk (IPAddress.mk 2) 50]) true :=
begin
  unfold Spec,
  simp,
  split,
  { simp, },
  { simp, },
end
