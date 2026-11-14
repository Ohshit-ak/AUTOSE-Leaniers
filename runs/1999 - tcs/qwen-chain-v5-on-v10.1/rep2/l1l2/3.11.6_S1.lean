import ContractForge
open ContractForge

-- 3.11.6/S1: Hardware and software shall be selected for use in the TCS with the goal of providing ease of future changes to the TCS elements. [SSS418] The object of portability for the TCS is to select or develop hardware which will readily host emerging software packages and software which will be as independent of host hardware as possible.

-- L0 spec

structure Input where
  software : String
  hardware : String
  deriving DecidableEq, Repr

structure Output where
  compatible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.compatible ↔
    (i.software = "" ∨ i.hardware.contains "Linux" ∨ i.hardware.contains "x86_64")

example : Spec.pre { software := "", hardware := "Linux" } ∧ Spec.post { software := "", hardware := "Linux" } { compatible := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { compatible := decide ((x.software = "" ∨ x.hardware.contains "Linux" ∨ x.hardware.contains "x86_64")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
