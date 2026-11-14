import ContractForge
open ContractForge

-- 4.2.4.1/I4: Performance. Overall performance of the Gemini telescope is defined as the percentage of viewable time during which exposures have been taken (i.e. sum of all exposure times over available time for exposures). To improve this performance, all possible concurrencies in system operation should be used. Best use of concurrency occurs when using the Sequencer.

-- L0 spec

structure Input where
  exposureTimes : List Nat
  availableTime : Nat
  deriving DecidableEq, Repr

structure Output where
  performance : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.exposureTimes.Nodup ∧ 0 < i.availableTime
  post := fun i o => o.performance = (i.exposureTimes.sum / i.availableTime) * 100

example : Spec.pre { exposureTimes := [10, 20, 30], availableTime := 60 } ∧
          Spec.post { exposureTimes := [10, 20, 30], availableTime := 60 }
                    { performance := 100 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { performance := (x.exposureTimes.sum / x.availableTime) * 100 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
