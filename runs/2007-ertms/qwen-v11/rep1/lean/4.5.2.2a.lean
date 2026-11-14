import ContractForge
open ContractForge

-- 4.5.2.2a: The driver shall select an override control according to the permission received.
-- compiles: True · rejects_bad_example: True · checked: True

structure OverrideControl where
  id : Nat
  permission : String
  deriving DecidableEq, Repr

structure Input where
  overrideControls : List OverrideControl
  permissionReceived : String
  deriving DecidableEq, Repr

structure Output where
  selectedControl : OverrideControl
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.overrideControls.Nodup ∧ i.permissionReceived ≠ ""
  post := fun i o => o.selectedControl.permission = i.permissionReceived ∧
                     ∃ c ∈ i.overrideControls, c.permission = i.permissionReceived ∧
                     o.selectedControl = c

example : Spec.pre { overrideControls := [{ id := 1, permission := "A" },
                                           { id := 2, permission := "B" }],
                     permissionReceived := "A" } ∧
          Spec.post { overrideControls := [{ id := 1, permission := "A" },
                                            { id := 2, permission := "B" }],
                      permissionReceived := "A" }
                    { selectedControl := { id := 1, permission := "A" } } := by
  unfold Spec; decide
