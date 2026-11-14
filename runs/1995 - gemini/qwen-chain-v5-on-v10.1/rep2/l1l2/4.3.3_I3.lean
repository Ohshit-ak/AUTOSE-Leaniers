import ContractForge
open ContractForge

-- 4.3.3/I3: Applications work would then include any of: IOC Database IOC or OPI SNC programs Files associated with OPI Channel Access Tools

-- L0 spec

structure Input where
  applicationType : String
  deriving DecidableEq, Repr

structure Output where
  workIncluded : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.workIncluded = true ↔
    (i.applicationType = "IOC Database" ∨
     i.applicationType = "IOC" ∨
     i.applicationType = "OPI SNC" ∨
     i.applicationType = "Files associated with OPI" ∨
     i.applicationType = "Channel Access Tools")

example : Spec.pre { applicationType := "IOC" } ∧
          Spec.post { applicationType := "IOC" }
                    { workIncluded := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { workIncluded := decide ((x.applicationType = "IOC Database" ∨
     x.applicationType = "IOC" ∨
     x.applicationType = "OPI SNC" ∨
     x.applicationType = "Files associated with OPI" ∨
     x.applicationType = "Channel Access Tools")) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
