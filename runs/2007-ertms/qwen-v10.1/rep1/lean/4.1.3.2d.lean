import ContractForge
open ContractForge

-- 4.1.3.2d: Permission received shall be indicated to the driver.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  permissionReceived : Bool
  deriving DecidableEq, Repr

structure Output where
  indicatedToDriver : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.permissionReceived = true
  post := fun i o => o.indicatedToDriver = true

example : Spec.pre { permissionReceived := true } ∧
          Spec.post { permissionReceived := true }
                    { indicatedToDriver := true } := by
  unfold Spec; decide
