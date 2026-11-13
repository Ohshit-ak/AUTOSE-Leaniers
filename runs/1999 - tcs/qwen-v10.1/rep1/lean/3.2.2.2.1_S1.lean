import ContractForge
open ContractForge

-- 3.2.2.2.1/S1: The TCS shall permit the operator to control the payload using all methods supported by the payload installed in the selected AV. [SSS152] The TCS shall provide a graphical user interface display for the purpose of controlling the payload. [SSS153] The TCS shall provide override of payload automated as well as preprogrammed inputs. [SSS154]
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  payloadMethods : List String
  override       : Bool
  deriving DecidableEq, Repr

structure Output where
  payloadControl : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.override = true
  post := fun i o => o.payloadControl ∈ i.payloadMethods ∧
                     (o.payloadControl = "override" ↔ i.override = true)

example : Spec.pre { payloadMethods := ["manual", "override"], override := true } ∧
          Spec.post { payloadMethods := ["manual", "override"], override := true }
                    { payloadControl := "override" } := by
  unfold Spec; decide
