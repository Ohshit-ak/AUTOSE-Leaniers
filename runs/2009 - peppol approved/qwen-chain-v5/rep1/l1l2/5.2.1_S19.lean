import ContractForge
open ContractForge

-- 5.2.1/S19: Structural data of evidence will provide guidance for foreign contracting authorities to understand the evidences contained within a VCD and they can trust that general information since it is provided by national VCD service providers that take the role of trusted parties.

-- L0 spec

structure Input where
  vcdId    : String
  evidence : List String
  nationalVcdService : Bool
  deriving DecidableEq, Repr

structure Output where
  guidance : String
  trust    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.nationalVcdService = true
  post := fun i o => (o.guidance = "The VCD structural data provides clear guidance on the evidences." ↔
    i.evidence.length > 0) ∧
                     (o.trust = true ↔ i.nationalVcdService = true)

example : Spec.pre { vcdId := "VCD123", evidence := ["E1", "E2"], nationalVcdService := true } ∧
          Spec.post { vcdId := "VCD123", evidence := ["E1", "E2"], nationalVcdService := true }
                    { guidance := "The VCD structural data provides clear guidance on the evidences.",
                      trust := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { guidance := if x.evidence.length > 0 then "The VCD structural data provides clear guidance on the evidences." else "No clear guidance provided.",
    trust := decide (x.nationalVcdService = true) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
