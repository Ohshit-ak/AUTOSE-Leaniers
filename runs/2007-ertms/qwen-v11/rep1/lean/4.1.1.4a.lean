import ContractForge
open ContractForge

-- 4.1.1.4a: The trackside shall be able to send information for the calculation of speed profiles.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  speedData : List Nat
  deriving DecidableEq, Repr

structure Output where
  speedProfile : List Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.speedData.Nodup
  post := fun i o => o.speedProfile.length = i.speedData.length ∧
                     ∀ i j ∈ i.speedData, o.speedProfile[i] = o.speedProfile[j] ↔ i = j

example : Spec.pre { speedData := [30, 40, 50] } ∧
          Spec.post { speedData := [30, 40, 50] }
                    { speedProfile := [30, 40, 50] } := by
  unfold Spec; decide
