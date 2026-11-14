import ContractForge
open ContractForge

-- 4.3.1.2.2/S5: A client can communicate with an arbitrary number of servers.

-- L0 spec

structure Input where
  clientID : Nat
  serverIDs : List Nat
  messages : List String
  deriving DecidableEq, Repr

structure Output where
  clientID : Nat
  serverIDs : List Nat
  responses : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.clientID ≠ 0 ∧ i.serverIDs.Nodup ∧ i.messages.Nodup
  post := fun i o => o.clientID = i.clientID ∧
                     o.serverIDs = i.serverIDs ∧
                     o.responses.length = i.messages.length ∧
                     ∀ j ∈ i.messages, o.responses.contains j ∧
                     (o.responses = i.messages ↔ i.messages.length = o.responses.length)

example : Spec.pre { clientID := 1, serverIDs := [2, 3, 4], messages := ["msg1", "msg2"] } ∧
          Spec.post { clientID := 1, serverIDs := [2, 3, 4], messages := ["msg1", "msg2"] }
                    { clientID := 1, serverIDs := [2, 3, 4], responses := ["msg1", "msg2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { clientID := x.clientID,
    serverIDs := x.serverIDs,
    responses := x.messages }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
