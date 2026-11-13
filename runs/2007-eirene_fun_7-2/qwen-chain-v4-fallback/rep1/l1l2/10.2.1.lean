import ContractForge
open ContractForge

-- 10.2.1: 10.2.1 A number of levels of priority shall be required in order to offer different grades of service to different users and calls. Five levels of priority shall be defined: (M) Railway emergency; control-command (safety); public emergency and group calls between drivers in the same area; railway operation; railway information.

-- L0 spec

structure Input where
  priorityLevel : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  priority : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 1 ≤ i.priorityLevel ∧ i.priorityLevel ≤ 5
  post := fun i o => o.valid = true ∧
                     (o.priority = "M" ↔ i.priorityLevel = 1) ∧
                     (o.priority = "Control-command" ↔ i.priorityLevel = 2) ∧
                     (o.priority = "Public emergency and group calls" ↔ i.priorityLevel = 3) ∧
                     (o.priority = "Railway operation" ↔ i.priorityLevel = 4) ∧
                     (o.priority = "Railway information" ↔ i.priorityLevel = 5)

example : Spec.pre { priorityLevel := 3 } ∧
          Spec.post { priorityLevel := 3 }
                    { valid := true, priority := "Public emergency and group calls" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { valid := true,
    priority := match x.priorityLevel with
      | 1 => "M"
      | 2 => "Control-command"
      | 3 => "Public emergency and group calls"
      | 4 => "Railway operation"
      | 5 => "Railway information"
      | _ => "Invalid priority level"
    }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
