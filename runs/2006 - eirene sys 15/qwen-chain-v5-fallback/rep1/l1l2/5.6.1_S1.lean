import ContractForge
open ContractForge

-- 5.6.1/S1: Incoming calls to the Cab radio shall be routed to the correct on-train user or device using information contained in the sub-addressing field.

-- L0 spec

structure Input where
  subAddress : String
  onTrainUsers : List String
  deriving DecidableEq, Repr

structure Output where
  routedTo : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.subAddress ≠ "" ∧ i.onTrainUsers.Nodup
  post := fun i o => 
    (∃ u ∈ i.onTrainUsers, o.routedTo = u ↔ i.subAddress = u) ∧
    (o.routedTo = "" ↔ ¬ ∃ u ∈ i.onTrainUsers, i.subAddress = u)

example : Spec.pre { subAddress := "user1", onTrainUsers := ["user1", "user2"] } ∧
          Spec.post { subAddress := "user1", onTrainUsers := ["user1", "user2"] }
                    { routedTo := "user1" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { routedTo := if ¬ ∃ u ∈ x.onTrainUsers, x.subAddress = u then "" else ∃! u ∈ x.onTrainUsers, x.subAddress = u }
