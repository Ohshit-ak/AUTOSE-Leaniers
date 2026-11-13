import ContractForge
open ContractForge

-- 11.4.4: 11.4.4 When operating with location dependent addressing, no manual action shall be required to update the system when a mobile moves between locations. (M)

-- L0 spec

structure Input where
  mobileId : Nat
  oldLocation : Nat
  newLocation : Nat
  deriving DecidableEq, Repr

structure Output where
  updated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mobileId ≠ 0 ∧ i.oldLocation < 100 ∧ i.newLocation < 100
  post := fun i o => o.updated = true ↔
    (i.oldLocation ≠ i.newLocation →
      (i.oldLocation = 0 → o.updated = true) ∧
      (i.newLocation = 0 → o.updated = true))

example : Spec.pre { mobileId := 1, oldLocation := 5, newLocation := 10 } ∧
          Spec.post { mobileId := 1, oldLocation := 5, newLocation := 10 }
                    { updated := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { updated := decide (x.oldLocation ≠ x.newLocation →
    (x.oldLocation = 0 → true) ∧
    (x.newLocation = 0 → true)) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
