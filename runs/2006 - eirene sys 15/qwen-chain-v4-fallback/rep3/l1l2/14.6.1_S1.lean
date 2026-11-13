import ContractForge
open ContractForge

-- 14.6.1/S1: Users shall be prevented from joining a dedicated shunting group by the EIRENE terminal application unless a valid functional number for the group has been successfully registered to the GSM-R network by their terminal.

-- L0 spec

structure Input where
  functionalNumber : String
  isRegistered     : Bool
  groupMembers     : List String
  deriving DecidableEq, Repr

structure Output where
  joinedGroup      : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.isRegistered
  post := fun i o => o.joinedGroup ↔
    (i.functionalNumber ≠ "" ∧
     ∃ gn ∈ i.groupMembers, gn = i.functionalNumber)

example : Spec.pre { functionalNumber := "123456", isRegistered := true,
                     groupMembers := ["123456", "654321"] } ∧
          Spec.post { functionalNumber := "123456", isRegistered := true,
                      groupMembers := ["123456", "654321"] }
                    { joinedGroup := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { joinedGroup := decide (x.functionalNumber ≠ "" ∧ ∃ gn ∈ x.groupMembers, gn = x.functionalNumber) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
