import ContractForge
open ContractForge

-- 4.1.2: 4.1.2 Three distinct mobile radio types are required, based on the type of role they will perform and the environment in which they will operate, as follows: (I) a) Cab radio for use by the driver of a train and/or by other on-train systems, eg ERTMS/ETCS; b) General purpose radio for general use by railway personnel; c) Operational radio for use by railway personnel involved in train operations such as shunting and trackside maintenance. Note: It is possible that the General purpose and Operational radios may have a number of variants to meet railway requirements (eg handheld and vehicle mounted).

-- L0 spec

structure Input where
  cabRadio   : Bool
  generalRadio : Bool
  operationalRadio : Bool
  deriving DecidableEq, Repr

structure Output where
  cabRadio   : Bool
  generalRadio : Bool
  operationalRadio : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cabRadio ∨ i.generalRadio ∨ i.operationalRadio
  post := fun i o => o.cabRadio = i.cabRadio ∧
                     o.generalRadio = i.generalRadio ∧
                     o.operationalRadio = i.operationalRadio

example : Spec.pre { cabRadio := true, generalRadio := false, operationalRadio := false } ∧
          Spec.post { cabRadio := true, generalRadio := false, operationalRadio := false }
                    { cabRadio := true, generalRadio := false, operationalRadio := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { cabRadio := x.cabRadio,
    generalRadio := x.generalRadio,
    operationalRadio := x.operationalRadio }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
