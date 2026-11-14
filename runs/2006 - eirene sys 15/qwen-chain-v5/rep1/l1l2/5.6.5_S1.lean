import ContractForge
open ContractForge

-- 5.6.5/S1: If directed network selection is implemented, the Cab radio application shall use the GSM "Manual" network selection procedure (through the AT interface [EN 301 515, Index [19]]) to instruct the MT to register with the required network.

-- L0 spec

structure Input where
  cabRadioConfig : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  network : String
  deriving DecidableEq, Repr

-- IMPL: EN 301 515, Index [19] - GSM "Manual" network selection procedure

def Spec : Contract Input Output where
  pre  := fun i => i.cabRadioConfig = "Manual"
  post := fun i o => o.registered = true ∧
                     o.network = "RequiredNetwork"

example : Spec.pre { cabRadioConfig := "Manual" } ∧
          Spec.post { cabRadioConfig := "Manual" }
                    { registered := true, network := "RequiredNetwork" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { registered := true,
    network := "RequiredNetwork" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
