import ContractForge
open ContractForge

-- 2.4.11/S1: Health event data should be aggregated into a centralized data store (i.e., data warehouse) designed specifically to support analysis of events over time.

-- L0 spec

structure Input where
  events : List String
  deriving DecidableEq, Repr

structure Output where
  aggregated : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.events.Nodup
  post := fun i o => o.aggregated.length = i.events.length ∧
                     o.aggregated.Nodup ∧
                     ∀ e ∈ i.events, o.aggregated.contains e

example : Spec.pre { events := ["event1", "event2", "event3"] } ∧
          Spec.post { events := ["event1", "event2", "event3"] }
                    { aggregated := ["event1", "event2", "event3"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { aggregated := x.events }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
