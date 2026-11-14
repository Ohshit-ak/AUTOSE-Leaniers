import ContractForge
open ContractForge

-- 5.2.3.4: 5.2.3.4 When switched off, the radio shall retain any numbers which are stored at the time the radio is switched off. (M) Switch radio MMI on/off

-- L0 spec

structure Input where
  numbersStored : List Nat
  switchedOn    : Bool
  deriving DecidableEq, Repr

structure Output where
  switchedOn    : Bool
  numbersStored : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.switchedOn
  post := fun i o => o.switchedOn = false ∧
                     o.numbersStored = i.numbersStored

example : Spec.pre { numbersStored := [5, 10, 15], switchedOn := true } ∧
          Spec.post { numbersStored := [5, 10, 15], switchedOn := true }
                    { switchedOn := false, numbersStored := [5, 10, 15] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { switchedOn := false,
    numbersStored := x.numbersStored }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
