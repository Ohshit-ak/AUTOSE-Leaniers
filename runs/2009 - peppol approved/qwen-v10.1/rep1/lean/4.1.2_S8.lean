import ContractForge
open ContractForge

-- 4.1.2/S8: Even if a country hasn't defined a pilot implementation for a VCD it can receive and interpret a VCD according to the information provided by the pre-VCD mapping tool.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  vcdInfo : String
  deriving DecidableEq, Repr

structure Output where
  valid   : Bool
  country : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => (o.valid = true ↔
    (i.vcdInfo ≠ "" ∧
     (o.country = "CountryA" ∨ o.country = "CountryB" ∨ o.country = "CountryC")))

example : Spec.pre { vcdInfo := "VCD data" } ∧
          Spec.post { vcdInfo := "VCD data" }
                    { valid := true, country := "CountryA" } := by
  unfold Spec; decide
