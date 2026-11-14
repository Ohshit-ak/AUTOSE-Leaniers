import ContractForge
open ContractForge

-- 3.1.5.1.3/S4: If the maximum number of heating or cooling units is already running, the request will be added to a LIFO queue.

-- L0 spec

structure Input where
  maxUnits : Nat
  runningUnits : Nat
  request : Bool
  deriving DecidableEq, Repr

structure Output where
  maxUnits : Nat
  runningUnits : Nat
  inQueue : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.runningUnits ≤ i.maxUnits
  post := fun i o => (o.runningUnits = i.runningUnits + 1 ∧ o.inQueue = false) ↔
                     (i.request = true ∧ i.runningUnits = i.maxUnits) ∧
                     (o.runningUnits = i.runningUnits ∧ o.inQueue = true →
                      i.request = true ∧ i.runningUnits < i.maxUnits)

example : Spec.pre { maxUnits := 5, runningUnits := 4, request := true } ∧
          Spec.post { maxUnits := 5, runningUnits := 4, request := true }
                    { maxUnits := 5, runningUnits := 5, inQueue := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { maxUnits := x.maxUnits,
    runningUnits := if x.request = true ∧ x.runningUnits = x.maxUnits then x.runningUnits + 1 else x.runningUnits,
    inQueue := if x.request = true ∧ x.runningUnits = x.maxUnits then false else true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
