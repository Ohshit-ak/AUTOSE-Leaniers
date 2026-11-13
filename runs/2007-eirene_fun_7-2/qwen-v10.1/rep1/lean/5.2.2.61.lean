import ContractForge
open ContractForge

-- 5.2.2.61: 5.2.2.61 For group or broadcast calls, a means to leave the call without terminating the call shall be provided. (M) Receive text messages
-- compiles: True · rejects_bad_example: True · checked: True

structure CallMember where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Call where
  members : List CallMember
  deriving DecidableEq, Repr

structure Input where
  call : Call
  leaving : Bool
  deriving DecidableEq, Repr

structure Output where
  call : Call
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.call.members.length > 0
  post := fun i o => (o.call = i.call ∧
                      (o.message = "Left the call." ↔ i.leaving = true)) ∧
                     (o.message = "Call terminated." ↔
                      i.call.members.length = 1 ∧ i.leaving = true) ∧
                     (o.message = "Text message received." ↔ i.leaving = false)

example : Spec.pre { call := { members := [{ id := 1, name := "Alice" }, { id := 2, name := "Bob" }] }, leaving := false } ∧ Spec.post { call := { members := [{ id := 1, name := "Alice" }, { id := 2, name := "Bob" }] }, leaving := false } { call := { members := [{ id := 1, name := "Alice" }, { id := 2, name := "Bob" }] }, message := "Text message received." } := by
  unfold Spec; decide
