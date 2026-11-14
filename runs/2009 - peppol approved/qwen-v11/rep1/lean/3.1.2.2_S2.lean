import ContractForge
open ContractForge

-- 3.1.2.2/S2: Requirement A list of recognized private entities that are able to issue certain attestations in a particular Member State SHOULD be established.
-- compiles: True · rejects_bad_example: True · checked: True

structure RecognizedEntity where
  name : String
  memberState : String
  attestationType : String
  deriving DecidableEq, Repr

structure Input where
  entities : List RecognizedEntity
  memberState : String
  attestationType : String
  deriving DecidableEq, Repr

structure Output where
  recognizedEntities : List RecognizedEntity
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.memberState ≠ "" ∧ i.attestationType ≠ ""
  post := fun i o => o.recognizedEntities.length > 0 ∧
                     (∀ e ∈ o.recognizedEntities, e.memberState = i.memberState ∧
                      e.attestationType = i.attestationType)

example : Spec.pre { entities := [{ name := "Entity A", memberState := "Germany", attestationType := "Type X" }],
                     memberState := "Germany", attestationType := "Type X" } ∧
          Spec.post { entities := [{ name := "Entity A", memberState := "Germany", attestationType := "Type X" }],
                      memberState := "Germany", attestationType := "Type X" }
                    { recognizedEntities := [{ name := "Entity A", memberState := "Germany", attestationType := "Type X" }] } := by
  unfold Spec; decide
