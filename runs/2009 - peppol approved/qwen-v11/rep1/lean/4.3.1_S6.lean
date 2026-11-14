import ContractForge
open ContractForge

-- 4.3.1/S6: Based on the information retrieved, the Austrian VCD implementation will deliver a VCD package containing all the evidences that are necessary to prove the selection and qualification criteria requested by any contracting authority regardless of its nationality (i.e. in the case of the scenario example provided in Figure 22: all evidences and declarations to be provided by TSE1, TSE2 and TSE3 to fulfil the requests of the Norwegian contracting authority).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  evidences : List String
  declarations : List String
  deriving DecidableEq, Repr

structure Output where
  vcdPackage : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.evidences.Nodup ∧ i.declarations.Nodup
  post := fun i o => o.vcdPackage = i.evidences ++ i.declarations

example : Spec.pre { evidences := ["e1", "e2"], declarations := ["d1", "d2"] } ∧
          Spec.post { evidences := ["e1", "e2"], declarations := ["d1", "d2"] }
                    { vcdPackage := ["e1", "e2", "d1", "d2"] } := by
  unfold Spec; decide
