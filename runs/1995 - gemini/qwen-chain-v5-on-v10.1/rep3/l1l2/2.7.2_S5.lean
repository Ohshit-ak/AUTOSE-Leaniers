import ContractForge
open ContractForge

-- 2.7.2/S5: The system design, if it does not include a scheduler, should specifically allow for its future implementation.

-- L0 spec

structure Input where
  queue : List Nat
  hasScheduler : Bool
  deriving DecidableEq, Repr

structure Output where
  processed : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.hasScheduler = false
  post := fun i o => if i.hasScheduler then
                       o.processed.length = i.queue.length ∧
                       (∀ n ∈ i.queue, ∃ p ∈ o.processed, p = n) ∧
                       o.processed.Nodup
                     else
                       o.processed.length = 0

example : Spec.pre { queue := [1, 2, 3], hasScheduler := false } ∧
          Spec.post { queue := [1, 2, 3], hasScheduler := false }
                    { processed := [] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { processed := if x.hasScheduler then
                  x.queue
                else
                  []
  }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
