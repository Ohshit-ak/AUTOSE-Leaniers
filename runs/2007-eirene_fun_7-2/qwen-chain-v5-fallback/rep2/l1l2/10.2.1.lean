import ContractForge
open ContractForge

-- 10.2.1: 10.2.1 A number of levels of priority shall be required in order to offer different grades of service to different users and calls. Five levels of priority shall be defined: (M) Railway emergency; control-command (safety); public emergency and group calls between drivers in the same area; railway operation; railway information.

-- L0 spec

structure Input where
  priority : Nat
  deriving DecidableEq, Repr

structure Output where
  level    : Nat
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.priority ≤ 5
  post := fun i o => o.level = i.priority ∧
                     (o.message = "Railway emergency; control-command (safety)" ↔ i.priority = 1) ∧
                     (o.message = "Public emergency and group calls between drivers in the same area" ↔ i.priority = 2) ∧
                     (o.message = "Railway operation" ↔ i.priority = 3) ∧
                     (o.message = "Railway information" ↔ i.priority = 4) ∧
                     (o.message = "Invalid priority" ↔ (i.priority = 0 ∨ i.priority > 5))

example : Spec.pre { priority := 3 } ∧ Spec.post { priority := 3 } { level := 3, message := "Railway operation" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { level := x.priority,
    message := if x.priority = 1 then "Railway emergency; control-command (safety)" else if x.priority = 2 then "Public emergency and group calls between drivers in the same area" else if x.priority = 3 then "Railway operation" else if x.priority = 4 then "Railway information" else if (x.priority = 0 ∨ x.priority > 5) then "Invalid priority" else "Invalid priority" }
