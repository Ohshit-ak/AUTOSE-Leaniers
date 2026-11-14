import ContractForge
open ContractForge

-- 0/I6: The VCD services which will compile VCD packages in five pilot member states (after the PEPPOL enlargement procedure, three new pilots have been added to WP 2): These VCD services will implement a number of services to query and collect evidences from different issuing bodies and to pack the individual evidences into a full VCD package thereby also extracting certain metadata and context specific data which will facilitate machine-readability and quick evaluation of a VCD package.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  pilotStates : List String
  evidences   : List String
  metadata    : List String
  contextData : List String
  deriving DecidableEq, Repr

structure Output where
  vcdPackage : String
  metadata   : List String
  contextData : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.pilotStates.Nodup ∧ i.evidences.Nodup ∧ i.metadata.Nodup ∧ i.contextData.Nodup
  post := fun i o => o.vcdPackage = i.pilotStates.joinWith "," ++ " VCD package" ∧
                     o.metadata = i.metadata ∧
                     o.contextData = i.contextData

example : Spec.pre { pilotStates := ["DE", "FR", "IT", "ES", "PT"], evidences := ["e1", "e2", "e3"], metadata := ["m1", "m2"], contextData := ["c1", "c2"] } ∧
          Spec.post { pilotStates := ["DE", "FR", "IT", "ES", "PT"], evidences := ["e1", "e2", "e3"], metadata := ["m1", "m2"], contextData := ["c1", "c2"] }
                    { vcdPackage := "DE,FR,IT,ES,PT VCD package", metadata := ["m1", "m2"], contextData := ["c1", "c2"] } := by
  unfold Spec; decide
