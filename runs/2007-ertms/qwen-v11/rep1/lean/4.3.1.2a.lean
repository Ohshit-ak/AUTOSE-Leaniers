import ContractForge
open ContractForge

-- 4.3.1.2a: ETCS shall calculate the permitted speed for the train for all locations of the authorised movement.
-- compiles: False · rejects_bad_example: None · checked: False

structure Location where
  id : Nat
  speedLimit : Nat
  deriving DecidableEq, Repr

structure Input where
  locations : List Location
  deriving DecidableEq, Repr

structure Output where
  permittedSpeed : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.locations.Nodup
  post := fun i o => o.permittedSpeed = i.locations.max (·.speedLimit)

example : Spec.pre { locations := [{ id := 1, speedLimit := 60 },
                                    { id := 2, speedLimit := 80 },
                                    { id := 3, speedLimit := 70 }] } ∧
          Spec.post { locations := [{ id := 1, speedLimit := 60 },
                                     { id := 2, speedLimit := 80 },
                                     { id := 3, speedLimit := 70 }] }
                    { permittedSpeed := 80 } := by
  unfold Spec; decide
