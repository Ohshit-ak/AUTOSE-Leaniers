import ContractForge
open ContractForge

-- 5.2.2.15: 5.2.2.15 The call shall continue until terminated by the calling driver, an authorised controller or the network. (M)
-- compiles: True · rejects_bad_example: None · checked: False

structure Call where
  driverId   : Nat
  controllerId : Option Nat
  terminated : Bool
  deriving DecidableEq, Repr

structure Input where
  driverId   : Nat
  controllerId : Option Nat
  deriving DecidableEq, Repr

structure Output where
  terminated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.terminated ↔
    (i.driverId = i.driverId ∧ i.controllerId = i.controllerId) ∧
    (i.driverId = i.driverId → o.terminated = true) ∧
    (i.controllerId.getD i.driverId = i.driverId → o.terminated = true) ∧
    (o.terminated = false → i.driverId = i.driverId ∧ i.controllerId = i.controllerId)

example : Spec.pre { driverId := 1, controllerId := none } ∧
          Spec.post { driverId := 1, controllerId := none }
                    { terminated := false } := by
  unfold Spec; decide
