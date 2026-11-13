import ContractForge
open ContractForge

-- 4.3.4.2: On lines fitted with RBC, the ETCS trainborne equipment shall be able to transmit the location of the entire train to the RBC.

-- L0 spec

structure Input where
  trainLocation : Nat -- location of the train in some unit (e.g., meters)
  deriving DecidableEq, Repr

structure Output where
  transmitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true -- no assumptions about the input
  post := fun i o => o.transmitted = true ↔ 0 ≤ i.trainLocation

example : Spec.pre { trainLocation := 1000 } ∧
          Spec.post { trainLocation := 1000 } { transmitted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { transmitted := decide (0 ≤ x.trainLocation) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
