import ContractForge
open ContractForge

-- 7.2.2.24: 7.2.2.24 The radio shall provide a means for the user to terminate calls which he is authorised to terminate (ie all calls except broadcast or group calls not initiated by the user). (M) Shunting mode communications

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { terminated := decide (∃ c ∈ x.calls, c.user = x.user ∧ c.type ≠ "broadcast" ∧ c.type ≠ "group" ∧
                     (c.type = "private" ∨ (c.type = "group" ∧ c.user = x.user))) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
