import ContractForge
open ContractForge

-- 5.6.5/S1: If directed network selection is implemented, the Cab radio application shall use the GSM "Manual" network selection procedure (through the AT interface [EN 301 515, Index [19]]) to instruct the MT to register with the required network.
-- compiles: True · rejects_bad_example: True · checked: True

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
