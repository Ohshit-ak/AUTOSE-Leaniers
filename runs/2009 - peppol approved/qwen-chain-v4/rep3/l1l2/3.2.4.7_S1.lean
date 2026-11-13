import ContractForge
open ContractForge

-- 3.2.4.7/S1: Description Any VCD package that is created by a VCD system should be an artefact that can be interpreted without using specific technology.

-- L0 spec

structure VCDPackage where
  content : String
  deriving DecidableEq, Repr

structure Input where
  vcdPackage : VCDPackage
  deriving DecidableEq, Repr

structure Output where
  interpretable : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.interpretable = true

example : Spec.pre { vcdPackage := { content := "example content" } } ∧
          Spec.post { vcdPackage := { content := "example content" } }
                    { interpretable := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { interpretable := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
