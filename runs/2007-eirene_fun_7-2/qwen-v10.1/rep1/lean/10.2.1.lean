import ContractForge
open ContractForge

-- 10.2.1: 10.2.1 A number of levels of priority shall be required in order to offer different grades of service to different users and calls. Five levels of priority shall be defined: (M) Railway emergency; control-command (safety); public emergency and group calls between drivers in the same area; railway operation; railway information.
-- compiles: True · rejects_bad_example: True · checked: True

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
