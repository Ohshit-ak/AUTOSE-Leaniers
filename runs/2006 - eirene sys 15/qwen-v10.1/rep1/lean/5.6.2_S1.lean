import ContractForge
open ContractForge

-- 5.6.2/S1: As a train approaches the limits of the coverage of the PLMN it is registered with, it will be necessary for it to register with the next PLMN providing coverage.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  currentPLMN : String
  nextPLMN    : String
  deriving DecidableEq, Repr

structure Output where
  registeredPLMN : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.currentPLMN ≠ "" ∧ i.nextPLMN ≠ ""
  post := fun i o => o.registeredPLMN = i.nextPLMN

example : Spec.pre { currentPLMN := "PLMN123", nextPLMN := "PLMN456" } ∧
          Spec.post { currentPLMN := "PLMN123", nextPLMN := "PLMN456" }
                    { registeredPLMN := "PLMN456" } := by
  unfold Spec; decide
