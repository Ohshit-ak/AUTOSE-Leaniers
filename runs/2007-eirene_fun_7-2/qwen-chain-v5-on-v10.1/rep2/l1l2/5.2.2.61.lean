import ContractForge
open ContractForge

-- 5.2.2.61: 5.2.2.61 For group or broadcast calls, a means to leave the call without terminating the call shall be provided. (M) Receive text messages

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { call := x.call,
    message := if x.leaving = true then "Left the call." else if x.call.members.length = 1 ∧ x.leaving = true then "Call terminated." else if x.leaving = false then "Text message received." else "Unknown message" }
