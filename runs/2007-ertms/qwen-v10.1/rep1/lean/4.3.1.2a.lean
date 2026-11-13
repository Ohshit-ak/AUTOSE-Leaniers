import ContractForge
open ContractForge

-- 4.3.1.2a: ETCS shall calculate the permitted speed for the train for all locations of the authorised movement.
-- compiles: True · rejects_bad_example: True · checked: True

structure Location where
  id : Nat
  speedLimit : Nat
  deriving DecidableEq, Repr

structure Input where
  locations : List Location
  deriving DecidableEq, Repr

structure Output where
  permittedSpeeds : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.locations.Nodup
  post := fun i o => o.permittedSpeeds.length = i.locations.length ∧
                     (∀ j ∈ i.locations, o.permittedSpeeds.contains j.speedLimit = true)

example : Spec.pre { locations := [{ id := 1, speedLimit := 80 }, { id := 2, speedLimit := 120 }] } ∧
          Spec.post { locations := [{ id := 1, speedLimit := 80 }, { id := 2, speedLimit := 120 }] }
                    { permittedSpeeds := [80, 120] } := by
  unfold Spec; decide
