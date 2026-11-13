import ContractForge
open ContractForge

-- 8.3.3/S1: The terminal of the controller should receive a single DTMF grant tone "#" of duration 100ms ± 5ms sent by the network if it has detected the 3-digit DTMF sequence "###" and if the controller was not previously talking.

-- L0 spec

structure Input where
  dtmfSequence : String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

structure Output where
  dtmfSequence : String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dtmfSequence.length = 3 ∧ i.dtmfSequence.toList.all (· == '#')
  post := fun i o => (o.dtmfSequence = "#" ∧ 95000 ≤ o.elapsedMicros ∧ o.elapsedMicros ≤ 105000) ↔
                     (i.dtmfSequence = "###" ∧ o.elapsedMicros ≤ 100000) ∧
                     (o.dtmfSequence ≠ "#" → o.elapsedMicros ≤ 5000)

example : Spec.pre { dtmfSequence := "###", elapsedMicros := 98000 } ∧
          Spec.post { dtmfSequence := "###", elapsedMicros := 98000 }
                    { dtmfSequence := "#", elapsedMicros := 99000 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { dtmfSequence := "#", elapsedMicros := if x.dtmfSequence = "###" ∧ x.elapsedMicros ≤ 100000 then 99000 else 5000 }
