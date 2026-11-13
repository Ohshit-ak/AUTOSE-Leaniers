import ContractForge
open ContractForge

-- 4.2.4.1/I4: Performance. Overall performance of the Gemini telescope is defined as the percentage of viewable time during which exposures have been taken (i.e. sum of all exposure times over available time for exposures). To improve this performance, all possible concurrencies in system operation should be used. Best use of concurrency occurs when using the Sequencer.
-- compiles: True · rejects_bad_example: True · checked: True

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
