import ContractForge
open ContractForge

-- 12.3.2: 12.3.2 The transfer time for each message segment should be less then 30 seconds for 95% of messages. (O)

-- L0 spec

structure Input where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.elapsedMicros ≤ 30000000 ∧
                     (o.elapsedMicros = i.elapsedMicros → o.elapsedMicros ≤ 30000000)

example : Spec.pre { elapsedMicros := 28000000 } ∧
          Spec.post { elapsedMicros := 28000000 } { elapsedMicros := 28000000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := min x.elapsedMicros 30000000 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
