import ContractForge
open ContractForge

-- 2.3.1/I1: Structural VCD package data: Data that describes the VCD-Package as a whole, e.g. VCD Unique Identifier, VCD issuing time, VCD service provider etc.

-- L0 spec

structure Input where
  vcdUniqueIdentifier : String
  vcdIssuingTime      : Nat
  vcdServiceProvider  : String
  deriving DecidableEq, Repr

structure Output where
  vcdUniqueIdentifier : String
  vcdIssuingTime      : Nat
  vcdServiceProvider  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vcdUniqueIdentifier ≠ "" ∧ i.vcdIssuingTime > 0 ∧ i.vcdServiceProvider ≠ ""
  post := fun i o => o.vcdUniqueIdentifier = i.vcdUniqueIdentifier ∧
                     o.vcdIssuingTime = i.vcdIssuingTime ∧
                     o.vcdServiceProvider = i.vcdServiceProvider

example : Spec.pre { vcdUniqueIdentifier := "VCD123", vcdIssuingTime := 1623456789, vcdServiceProvider := "ServiceX" } ∧
          Spec.post { vcdUniqueIdentifier := "VCD123", vcdIssuingTime := 1623456789, vcdServiceProvider := "ServiceX" }
                    { vcdUniqueIdentifier := "VCD123", vcdIssuingTime := 1623456789, vcdServiceProvider := "ServiceX" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { vcdUniqueIdentifier := x.vcdUniqueIdentifier,
    vcdIssuingTime := x.vcdIssuingTime,
    vcdServiceProvider := x.vcdServiceProvider }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
