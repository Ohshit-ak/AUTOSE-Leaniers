import ContractForge
open ContractForge

-- 3.1.2.1/S2: Requirement A list of recognized public authorities that are able to issue certain attestations in a particular Member State MUST be established.

-- L0 spec

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
                     o.recognizedList.Nodup

example : Spec.pre { authorities := [{ name := "Body A", issuingCountry := "Germany", attestationType := "Type X" },
                                      { name := "Body B", issuingCountry := "France", attestationType := "Type Y" }] } ∧
          Spec.post { authorities := [{ name := "Body A", issuingCountry := "Germany", attestationType := "Type X" },
                                       { name := "Body B", issuingCountry := "France", attestationType := "Type Y" }] }
                    { recognizedList := [{ name := "Body A", issuingCountry := "Germany", attestationType := "Type X" },
                                         { name := "Body B", issuingCountry := "France", attestationType := "Type Y" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { recognizedList := x.authorities }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
