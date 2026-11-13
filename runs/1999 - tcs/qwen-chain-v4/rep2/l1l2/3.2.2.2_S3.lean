import ContractForge
open ContractForge

-- 3.2.2.2/S3: The TCS shall receive, process, and present payload data to the operator so that the status of the payload can be determined. [SSS151]

-- L0 spec

structure PayloadData where
  status : String
  deriving DecidableEq, Repr

structure Input where
  payloadData : List PayloadData
  deriving DecidableEq, Repr

structure Output where
  presented : List PayloadData
  statusDetermined : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.payloadData.Nodup
  post := fun i o => o.statusDetermined = true ∧
                     (∀ pd ∈ o.presented, pd ∈ i.payloadData ∧
                      pd.status ≠ "" ∧
                      ∃ pdi ∈ i.payloadData, pdi = pd ∧ pdi.status = pd.status)

example : Spec.pre { payloadData := [{ status := "active" }, { status := "inactive" }] } ∧
          Spec.post { payloadData := [{ status := "active" }, { status := "inactive" }] }
                    { presented := [{ status := "active" }, { status := "inactive" }], statusDetermined := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { presented := x.payloadData.filter (fun pd => pd.status ≠ ""),
    statusDetermined := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
