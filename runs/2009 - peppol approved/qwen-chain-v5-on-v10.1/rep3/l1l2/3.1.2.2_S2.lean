import ContractForge
open ContractForge

-- 3.1.2.2/S2: Requirement A list of recognized private entities that are able to issue certain attestations in a particular Member State SHOULD be established.

-- L0 spec

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
                     ∀ e ∈ o.recognizedEntities, e.memberState = i.memberState ∧
                     e.attestationType = i.attestationType

example : Spec.pre { entities := [{ name := "Entity A", memberState := "Germany", attestationType := "Type X" }],
                     memberState := "Germany", attestationType := "Type X" } ∧
          Spec.post { entities := [{ name := "Entity A", memberState := "Germany", attestationType := "Type X" }],
                      memberState := "Germany", attestationType := "Type X" }
                    { recognizedEntities := [{ name := "Entity A", memberState := "Germany", attestationType := "Type X" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { recognizedEntities := x.entities.filter (fun e => e.memberState = x.memberState ∧
                     e.attestationType = x.attestationType) }
