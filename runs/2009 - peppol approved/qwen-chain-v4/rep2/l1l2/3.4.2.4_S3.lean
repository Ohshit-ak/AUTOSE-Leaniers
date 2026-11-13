import ContractForge
open ContractForge

-- 3.4.2.4/S3: In the public procurement business process, as in other electronic business processes, electronic identity is a key element for two main purposes: Avoiding unauthorized use of individuals identity Assuring to administrations that individuals are the persons they claim to be and have the mandate they claim to have" (Bausa O. and Boujraf A. 2009) Requirement Every party participating MUST be uniquely identifiable

-- L0 spec

structure Input where
  partyId : String
  deriving DecidableEq, Repr

structure Output where
  partyId : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.partyId ≠ ""
  post := fun i o => (o.partyId = i.partyId ↔ o.partyId ≠ "uniqueID123")

example : Spec.pre { partyId := "12345" } ∧ Spec.post { partyId := "12345" } { partyId := "12345" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { partyId := x.partyId }
