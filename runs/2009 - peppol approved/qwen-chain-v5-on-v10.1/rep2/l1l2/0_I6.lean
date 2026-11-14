import ContractForge
open ContractForge

-- 0/I6: The VCD services which will compile VCD packages in five pilot member states (after the PEPPOL enlargement procedure, three new pilots have been added to WP 2): These VCD services will implement a number of services to query and collect evidences from different issuing bodies and to pack the individual evidences into a full VCD package thereby also extracting certain metadata and context specific data which will facilitate machine-readability and quick evaluation of a VCD package.

-- L0 spec

structure Input where
  pilotStates : List String
  issuingBodies : List String
  evidences : List String
  metadata : List String
  contextData : List String
  deriving DecidableEq, Repr

structure Output where
  vcdPackages : List String
  metadataExtracted : Bool
  contextDataExtracted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.pilotStates.Nodup ∧ i.issuingBodies.Nodup ∧
                  i.evidences.Nodup ∧ i.metadata.Nodup ∧ i.contextData.Nodup
  post := fun i o => o.vcdPackages.length = i.pilotStates.length ∧
                     o.metadataExtracted = true ∧
                     o.contextDataExtracted = true ∧
                     ∀ p ∈ o.vcdPackages, ∃ e ∈ i.evidences, ∃ m ∈ i.metadata, ∃ c ∈ i.contextData,
                     p = e ++ m ++ c

example : Spec.pre { pilotStates := ["state1", "state2"], issuingBodies := ["body1", "body2"],
                     evidences := ["ev1", "ev2"], metadata := ["m1", "m2"], contextData := ["c1", "c2"] } ∧
          Spec.post { pilotStates := ["state1", "state2"], issuingBodies := ["body1", "body2"],
                      evidences := ["ev1", "ev2"], metadata := ["m1", "m2"], contextData := ["c1", "c2"] }
                    { vcdPackages := ["ev1m1c1", "ev2m2c2"], metadataExtracted := true, contextDataExtracted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { vcdPackages := x.pilotStates.filter (fun p => ∃ e ∈ x.evidences, ∃ m ∈ x.metadata, ∃ c ∈ x.contextData,
                     p = e ++ m ++ c),
    metadataExtracted := true,
    contextDataExtracted := true }
