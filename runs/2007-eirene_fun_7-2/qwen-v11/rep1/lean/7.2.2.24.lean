import ContractForge
open ContractForge

-- 7.2.2.24: 7.2.2.24 The radio shall provide a means for the user to terminate calls which he is authorised to terminate (ie all calls except broadcast or group calls not initiated by the user). (M) Shunting mode communications
-- compiles: True · rejects_bad_example: None · checked: True

structure Call where
  id : Nat
  user : String
  type : String
  deriving DecidableEq, Repr

structure Input where
  calls : List Call
  user  : String
  deriving DecidableEq, Repr

structure Output where
  terminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user ≠ "" ∧
                  (i.calls.all (fun c => c.user = i.user) →
                   i.calls.any (fun c => c.type ≠ "broadcast" ∧ c.type ≠ "group" ∧ c.user = i.user))
  post := fun i o => o.terminated = true ↔
                     ∃ c ∈ i.calls, c.user = i.user ∧ c.type ≠ "broadcast" ∧ c.type ≠ "group" ∧
                     (c.type = "private" ∨ (c.type = "group" ∧ c.user = i.user))

example : Spec.pre { calls := [{ id := 1, user := "alice", type := "private" },
                                { id := 2, user := "bob", type := "broadcast" }],
                     user := "alice" } ∧
          Spec.post { calls := [{ id := 1, user := "alice", type := "private" },
                                { id := 2, user := "bob", type := "broadcast" }],
                      user := "alice" }
                    { terminated := true } := by
  unfold Spec; decide
