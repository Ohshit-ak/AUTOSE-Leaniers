import ContractForge
open ContractForge

-- 7.4.4.1: 7.4.4.1 A visual and audible alarm shall be given when the remaining capacity of the battery is such as to enable only 10 minutes of full duplex call time. (M)

-- L0 spec

structure Input where
  remainingCapacity : Nat
  elapsedMicros     : Nat
  deriving DecidableEq, Repr

structure Output where
  elapsedMicros : Nat
  visualAlarm   : Bool
  audibleAlarm  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.remainingCapacity
  post := fun i o => (o.visualAlarm = true ∧ o.audibleAlarm = true) ↔
                     (i.remainingCapacity ≤ 10 * 60000) ∧
                     o.elapsedMicros ≤ 600000000

example : Spec.pre { remainingCapacity := 600000, elapsedMicros := 599999999 } ∧
          Spec.post { remainingCapacity := 600000, elapsedMicros := 599999999 }
                    { visualAlarm := true, audibleAlarm := true, elapsedMicros := 599999999 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { elapsedMicros := min x.elapsedMicros 600000000, visualAlarm := decide (x.remainingCapacity ≤ 10 * 60000), audibleAlarm := decide (x.remainingCapacity ≤ 10 * 60000) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
