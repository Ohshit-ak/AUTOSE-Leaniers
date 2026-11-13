import ContractForge
open ContractForge

-- 4.2.4.1/I5: Start-up and shut-down. There are start-up and shut-down procedures that must exist at many different levels: Cold start-up, starting the system from scratch (including time to download all software) should take about 5 minutes. This does not include time to start-up the telescope or instruments. Warm start-up, starting from scratch but also excluding software download time should take about 1 minute. Telescope start-up, measured from end of cold or warm start-up should be about 4 minutes. Instrument start-up, measured from end of telescope start-up, should take 2 minutes or less.There must be a way to shut down all subsystems (hardware and software). All start-ups and shut-downs are to be automatically logged with time stamps, to allow for statistics on system availability.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  coldStart     : Nat
  warmStart     : Nat
  telescopeStart: Nat
  instrumentStart: Nat
  log           : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.elapsedMicros ≤ 300000000 ∧
                     o.coldStart ≤ 300000000 ∧
                     o.warmStart ≤ 60000000 ∧
                     o.telescopeStart ≤ 240000000 ∧
                     o.instrumentStart ≤ 120000000 ∧
                     o.log ≠ ""

example : Spec.pre { coldStart := 300000, warmStart := 60000, telescopeStart := 240000, instrumentStart := 120000, log := "log entry" } ∧
          Spec.post { coldStart := 300000, warmStart := 60000, telescopeStart := 240000, instrumentStart := 120000, log := "log entry", elapsedMicros := 299999999 } := by
  unfold Spec; decide
