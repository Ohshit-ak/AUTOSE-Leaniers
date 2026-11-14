import ContractForge
open ContractForge

-- 4/system-availability/R4: The number of incidents of unplanned downtime for the System must not exceed <x> per <rolling three month period>.

-- L0 spec

structure Input where
  downtimeCount : Nat
  rollingPeriod : Nat
  deriving DecidableEq, Repr

structure Output where
  downtimeCount : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.downtimeCount ≤ 3
  post := fun i o => o.downtimeCount = i.downtimeCount ∧
                     (o.downtimeCount < i.downtimeCount ↔ i.downtimeCount > 3)

example : Spec.pre { downtimeCount := 2, rollingPeriod := 90 } ∧
          Spec.post { downtimeCount := 2, rollingPeriod := 90 }
                    { downtimeCount := 2 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { downtimeCount := x.downtimeCount }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
