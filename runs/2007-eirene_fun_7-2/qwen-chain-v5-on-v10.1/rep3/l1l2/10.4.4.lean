import ContractForge
open ContractForge

-- 10.4.4: 10.4.4 In order to provide interoperability, Cab radios will be members of a number of standard groups: Railway emergency call; (M) all train drivers; (M) shunting team; (M) trackside worker. (O)

-- L0 spec

structure Input where
  cabId : Nat
  groupMemberships : List String
  deriving DecidableEq, Repr

structure Output where
  cabId : Nat
  groupMemberships : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabId ≠ 0
  post := fun i o => o.cabId = i.cabId ∧
                     (o.groupMemberships = ["Railway emergency call"] ∨
                      o.groupMemberships.contains "all train drivers" ∨
                      o.groupMemberships.contains "shunting team" ∨
                      o.groupMemberships.contains "trackside worker")

example : Spec.pre { cabId := 1, groupMemberships := ["Railway emergency call", "all train drivers"] } ∧
          Spec.post { cabId := 1, groupMemberships := ["Railway emergency call", "all train drivers"] }
                    { cabId := 1, groupMemberships := ["Railway emergency call", "all train drivers"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { cabId := x.cabId,
    groupMemberships := if x.groupMemberships.contains "all train drivers" then
                            x.groupMemberships ++ ["Railway emergency call"]
                         else if x.groupMemberships.contains "shunting team" then
                            x.groupMemberships ++ ["Railway emergency call"]
                         else if x.groupMemberships.contains "trackside worker" then
                            x.groupMemberships ++ ["Railway emergency call"]
                         else
                            ["Railway emergency call"] }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
