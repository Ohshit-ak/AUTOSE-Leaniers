import ContractForge
open ContractForge

-- 3.11.6/S1: Hardware and software shall be selected for use in the TCS with the goal of providing ease of future changes to the TCS elements. [SSS418] The object of portability for the TCS is to select or develop hardware which will readily host emerging software packages and software which will be as independent of host hardware as possible.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  software : String
  hardware : String
  deriving DecidableEq, Repr

structure Output where
  compatible : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.compatible ↔
    (i.software = "" ∨ i.hardware.contains "Linux" ∨ i.hardware.contains "x86_64")

example : Spec.pre { software := "", hardware := "Linux" } ∧ Spec.post { software := "", hardware := "Linux" } { compatible := true } := by
  unfold Spec; decide
