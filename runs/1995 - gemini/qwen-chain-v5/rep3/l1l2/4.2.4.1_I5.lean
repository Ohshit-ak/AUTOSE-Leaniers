import ContractForge
open ContractForge

-- 4.2.4.1/I5: Start-up and shut-down. There are start-up and shut-down procedures that must exist at many different levels: Cold start-up, starting the system from scratch (including time to download all software) should take about 5 minutes. This does not include time to start-up the telescope or instruments. Warm start-up, starting from scratch but also excluding software download time should take about 1 minute. Telescope start-up, measured from end of cold or warm start-up should be about 4 minutes. Instrument start-up, measured from end of telescope start-up, should take 2 minutes or less.There must be a way to shut down all subsystems (hardware and software). All start-ups and shut-downs are to be automatically logged with time stamps, to allow for statistics on system availability.

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  coldStart     : Nat
  warmStart     : Nat
  telescopeStart: Nat
  instrumentStart: Nat
  shutdown      : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o =>
    o.elapsedMicros ≤ 300000000 ∧
    o.coldStart ≤ 300000000 ∧
    o.warmStart ≤ 60000000 ∧
    o.telescopeStart ≤ 240000000 ∧
    o.instrumentStart ≤ 120000000 ∧
    o.shutdown ≤ 100000000

example : Spec.pre {} ∧
          Spec.post {} { elapsedMicros := 300000000, coldStart := 150000000, warmStart := 50000000, telescopeStart := 120000000, instrumentStart := 60000000, shutdown := 50000000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := 300000000,
    coldStart := 300000000,
    warmStart := 60000000,
    telescopeStart := 240000000,
    instrumentStart := 120000000,
    shutdown := 100000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
