import ContractForge
open ContractForge

-- 4.14.7/I4: COE Chief Engineer's Role. The COE Chief Engineer will approve a single Point of Contact (POC) for a COI to manage the tags within that COI. The COE Chief Engineer will reserve ultimate authority to mediate any unresolved disputes within all COIs.

-- L0 spec

structure Input where
  coeChiefEngineerApproval : Bool
  pocForCOI               : String
  disputesMediation       : Bool
  deriving DecidableEq, Repr

structure Output where
  pocForCOI               : String
  disputesMediation       : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.coeChiefEngineerApproval = true
  post := fun i o => o.pocForCOI = i.pocForCOI ∧
                     o.disputesMediation = i.disputesMediation

example : Spec.pre { coeChiefEngineerApproval := true, pocForCOI := "John Doe", disputesMediation := true } ∧
          Spec.post { coeChiefEngineerApproval := true, pocForCOI := "John Doe", disputesMediation := true }
                     { pocForCOI := "John Doe", disputesMediation := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { pocForCOI := x.pocForCOI, disputesMediation := x.disputesMediation }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
