import ContractForge
open ContractForge

-- 3.4.2.6/S3: (Bausa O. and Boujraf A. 2009) Requirement In stage 4 it MUST be possible to discover the verified electronic address for an identified party.

-- L0 spec

structure Input where
  partyId : String
  verifiedAddresses : List String
  deriving DecidableEq, Repr

structure Output where
  electronicAddress : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.partyId ≠ "" ∧ i.verifiedAddresses.Nodup
  post := fun i o => o.electronicAddress ∈ i.verifiedAddresses ∧
                     (o.electronicAddress = i.verifiedAddresses.headD "" ↔
                      i.verifiedAddresses.length = 1)

example : Spec.pre { partyId := "12345", verifiedAddresses := ["addr1@example.com"] } ∧
          Spec.post { partyId := "12345", verifiedAddresses := ["addr1@example.com"] }
                    { electronicAddress := "addr1@example.com" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { electronicAddress := if x.verifiedAddresses.length = 1 then x.verifiedAddresses.headD "" else x.verifiedAddresses.headD "" }
