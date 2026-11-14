import ContractForge
open ContractForge

-- 3.11.6/S1: Hardware and software shall be selected for use in the TCS with the goal of providing ease of future changes to the TCS elements. [SSS418] The object of portability for the TCS is to select or develop hardware which will readily host emerging software packages and software which will be as independent of host hardware as possible.

-- L0 spec

structure Input where
  hardware : String
  software : String
  deriving DecidableEq, Repr

structure Output where
  hardware : String
  software : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.hardware = "generic" ∨ i.software = "cross-platform"
  post := fun i o => o.hardware = "generic" ∧ o.software = "cross-platform"

example : Spec.pre { hardware := "generic", software := "cross-platform" } ∧
          Spec.post { hardware := "generic", software := "cross-platform" }
                    { hardware := "generic", software := "cross-platform" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { hardware := "generic",
    software := "cross-platform" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
