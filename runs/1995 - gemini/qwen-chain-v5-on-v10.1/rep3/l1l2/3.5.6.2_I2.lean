import ContractForge
open ContractForge

-- 3.5.6.2/I2: soft limit switches - the software will detect unsafe areas and halt; the software will allow movement off of soft limits

-- L0 spec

structure Input where
  position : Nat
  softLimit : Nat
  deriving DecidableEq, Repr

structure Output where
  halted : Bool
  moved : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.softLimit ∧ i.position < i.softLimit
  post := fun i o => (o.halted = true ↔ i.position = i.softLimit - 1) ∧
                     (o.moved = true ↔ i.position < i.softLimit - 1)

example : Spec.pre { position := 5, softLimit := 10 } ∧
          Spec.post { position := 5, softLimit := 10 }
                    { halted := false, moved := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { halted := decide (x.position = x.softLimit - 1),
    moved := decide (x.position < x.softLimit - 1) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
