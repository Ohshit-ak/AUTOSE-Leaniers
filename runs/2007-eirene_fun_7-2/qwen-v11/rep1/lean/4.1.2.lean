import ContractForge
open ContractForge

-- 4.1.2: 4.1.2 Three distinct mobile radio types are required, based on the type of role they will perform and the environment in which they will operate, as follows: (I) a) Cab radio for use by the driver of a train and/or by other on-train systems, eg ERTMS/ETCS; b) General purpose radio for general use by railway personnel; c) Operational radio for use by railway personnel involved in train operations such as shunting and trackside maintenance. Note: It is possible that the General purpose and Operational radios may have a number of variants to meet railway requirements (eg handheld and vehicle mounted).
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  cabRadio   : String
  generalRadio : String
  operationalRadio : String
  distinctRadios : Bool
  deriving DecidableEq, Repr

structure Output where
  cabRadio   : String
  generalRadio : String
  operationalRadio : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => (o.cabRadio ≠ "" ∧ o.generalRadio ≠ "" ∧ o.operationalRadio ≠ "" ∧
                      (i.distinctRadios → o.cabRadio ≠ o.generalRadio ∧ o.cabRadio ≠ o.operationalRadio ∧ o.generalRadio ≠ o.operationalRadio))

example : Spec.pre { cabRadio := "Cab1", generalRadio := "Gen1", operationalRadio := "Oper1", distinctRadios := true } ∧ Spec.post { cabRadio := "Cab1", generalRadio := "Gen1", operationalRadio := "Oper1", distinctRadios := true } { cabRadio := "Cab1", generalRadio := "Gen1", operationalRadio := "Oper1" } := by
  unfold Spec; decide
