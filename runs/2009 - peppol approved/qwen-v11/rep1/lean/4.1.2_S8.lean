import ContractForge
open ContractForge

-- 4.1.2/S8: Even if a country hasn't defined a pilot implementation for a VCD it can receive and interpret a VCD according to the information provided by the pre-VCD mapping tool.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  countryDefinedPilot : Bool
  vcdInfo             : String
  deriving DecidableEq, Repr

structure Output where
  receivedVcd        : Bool
  interpretingVcd    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => (o.receivedVcd = true ↔ i.vcdInfo ≠ "") ∧
                     (o.interpretingVcd = true ↔ i.countryDefinedPilot ∨ i.vcdInfo ≠ "")

example : Spec.pre { countryDefinedPilot := false, vcdInfo := "some information" } ∧
          Spec.post { countryDefinedPilot := false, vcdInfo := "some information" }
                    { receivedVcd := true, interpretingVcd := true } := by
  unfold Spec; decide
