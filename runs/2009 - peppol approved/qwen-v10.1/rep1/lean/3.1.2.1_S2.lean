import ContractForge
open ContractForge

-- 3.1.2.1/S2: Requirement A list of recognized public authorities that are able to issue certain attestations in a particular Member State MUST be established.
-- compiles: True · rejects_bad_example: True · checked: True

structure RecognizedAuthority where
  name : String
  issuingCountry : String
  attestationType : String
  deriving DecidableEq, Repr

structure Input where
  authorities : List RecognizedAuthority
  deriving DecidableEq, Repr

structure Output where
  recognizedList : List RecognizedAuthority
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.authorities.Nodup
  post := fun i o => o.recognizedList = i.authorities ∧
                     (∀ a ∈ o.recognizedList, a.attestationType ≠ "" ∧ a.issuingCountry ≠ "")

example : Spec.pre { authorities := [{ name := "Body A", issuingCountry := "Country X", attestationType := "Type 1" },
                                      { name := "Body B", issuingCountry := "Country Y", attestationType := "Type 2" }] } ∧
          Spec.post { authorities := [{ name := "Body A", issuingCountry := "Country X", attestationType := "Type 1" },
                                       { name := "Body B", issuingCountry := "Country Y", attestationType := "Type 2" }] }
                    { recognizedList := [{ name := "Body A", issuingCountry := "Country X", attestationType := "Type 1" },
                                         { name := "Body B", issuingCountry := "Country Y", attestationType := "Type 2" }] } := by
  unfold Spec; decide
