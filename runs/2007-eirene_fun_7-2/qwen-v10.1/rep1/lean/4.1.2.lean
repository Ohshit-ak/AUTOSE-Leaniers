import ContractForge
open ContractForge

-- 4.1.2: 4.1.2 Three distinct mobile radio types are required, based on the type of role they will perform and the environment in which they will operate, as follows: (I) a) Cab radio for use by the driver of a train and/or by other on-train systems, eg ERTMS/ETCS; b) General purpose radio for general use by railway personnel; c) Operational radio for use by railway personnel involved in train operations such as shunting and trackside maintenance. Note: It is possible that the General purpose and Operational radios may have a number of variants to meet railway requirements (eg handheld and vehicle mounted).
-- compiles: True · rejects_bad_example: True · checked: True

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
