import ContractForge
open ContractForge

-- 5.2.3.17: 5.2.3.17 By default, the loudspeaker volume shall be set to a pre-determined level suitable for the operating environment (as stored within the system). (M)

-- L0 spec

structure Input where
  volumeLevel : Nat
  deriving DecidableEq, Repr

structure Output where
  volumeLevel : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.volumeLevel = i.volumeLevel

example : Spec.pre { volumeLevel := 70 } ∧
          Spec.post { volumeLevel := 70 } { volumeLevel := 70 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { volumeLevel := x.volumeLevel }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
