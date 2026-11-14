import ContractForge
open ContractForge

-- 5.2.2.15: 5.2.2.15 The call shall continue until terminated by the calling driver, an authorised controller or the network. (M)
-- compiles: True · rejects_bad_example: True · checked: True

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
    (i.controllerId.isSome → o.terminated = true) ∧
    (i.controllerId.isNone → o.terminated = false)

example : Spec.pre { driverId := 1, controllerId := none } ∧
          Spec.post { driverId := 1, controllerId := none }
                    { terminated := false } := by
  unfold Spec; decide
