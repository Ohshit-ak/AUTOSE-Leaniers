import ContractForge
open ContractForge

-- 2.6.3/S17: However it must be recognized that:

-- L0 spec

structure Input where
  amount  : Nat
  limit   : Nat
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  fee      : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.limit
  post := fun i o => (o.accepted = true ↔ i.amount ≤ i.limit) ∧
                     (o.accepted = false → o.fee = 0)

example : Spec.pre { amount := 5, limit := 10 } ∧
          Spec.post { amount := 5, limit := 10 } { accepted := true, fee := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { accepted := decide (x.amount ≤ x.limit),
    fee := if decide (x.amount ≤ x.limit) = false then 0 else 1 }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
