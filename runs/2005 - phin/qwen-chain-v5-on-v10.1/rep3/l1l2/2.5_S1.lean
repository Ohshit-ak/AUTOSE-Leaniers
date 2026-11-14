import ContractForge
open ContractForge

-- 2.5/S1: SYSTEM INTEGRATION AND DATA EXCHANGE Systems integration requirements specific to systems supporting OM are included in the section below and describe the types of data that OM should be able to send and receive.

-- L0 spec

structure Input where
  outbreakData : String
  deriving DecidableEq, Repr

structure Output where
  receivedData : String
  status       : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.outbreakData ≠ ""
  post := fun i o => (o.status = "Data received successfully" ↔
    o.receivedData = i.outbreakData) ∧
    (o.status = "Data not received" → o.receivedData = "")

example : Spec.pre { outbreakData := "Outbreak details" } ∧
          Spec.post { outbreakData := "Outbreak details" }
                    { receivedData := "Outbreak details", status := "Data received successfully" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { receivedData := x.outbreakData, status := "Data received successfully" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
