import ContractForge
open ContractForge

-- 4.3.1/S6: Based on the information retrieved, the Austrian VCD implementation will deliver a VCD package containing all the evidences that are necessary to prove the selection and qualification criteria requested by any contracting authority regardless of its nationality (i.e. in the case of the scenario example provided in Figure 22: all evidences and declarations to be provided by TSE1, TSE2 and TSE3 to fulfil the requests of the Norwegian contracting authority).

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { vcdPackage := x.evidences ++ x.declarations }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
