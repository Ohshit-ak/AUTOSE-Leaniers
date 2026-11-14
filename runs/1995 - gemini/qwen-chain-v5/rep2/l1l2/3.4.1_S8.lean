import ContractForge
open ContractForge

-- 3.4.1/S8: This should greatly simplify the coordination problem posed by the large number of simultaneous users (as already described in the Capacity requirements, Section 3.2.2).

-- L0 spec

structure Input where
  maxUsers : Nat
  currentUsers : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  currentUsers : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.maxUsers
  post := fun i o => (o.accepted = true ↔ i.currentUsers < i.maxUsers) ∧
                     (o.accepted = false → o.currentUsers = i.currentUsers + 1)

example : Spec.pre { maxUsers := 10, currentUsers := 8 } ∧
          Spec.post { maxUsers := 10, currentUsers := 8 }
                    { accepted := true, currentUsers := 9 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { accepted := decide (x.currentUsers < x.maxUsers),
    currentUsers := if x.currentUsers < x.maxUsers then x.currentUsers else x.currentUsers + 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
