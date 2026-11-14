import ContractForge
open ContractForge

-- 11.2.1.10: 11.2.1.10It shall be possible to call EIRENE users by functional numbers from a wide range of terminals (EIRENE and non-EIRENE). Examples include EIRENE mobiles, controller terminals, railway fixed network telephones and public telephones. (All such calls will be subject to any access restrictions see section 10.3.) (M)

-- L0 spec

structure Input where
  functionalNumber : String
  terminalType     : String
  deriving DecidableEq, Repr

structure Output where
  callSuccessful : Bool
  accessRestricted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber ≠ "" ∧ i.terminalType ≠ ""
  post := fun i o =>
    o.callSuccessful = true ↔
    (i.terminalType = "EIRENE" ∨ i.terminalType = "non-EIRENE") ∧
    (o.accessRestricted = true → o.callSuccessful = false) ∧
    o.accessRestricted = (i.functionalNumber = "restricted")

example : Spec.pre { functionalNumber := "F123", terminalType := "EIRENE" } ∧
          Spec.post { functionalNumber := "F123", terminalType := "EIRENE" }
                    { callSuccessful := true, accessRestricted := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { callSuccessful := (x.terminalType = "EIRENE" ∨ x.terminalType = "non-EIRENE"),
    accessRestricted := (x.functionalNumber = "restricted") }
