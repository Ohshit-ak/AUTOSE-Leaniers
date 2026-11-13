import ContractForge
open ContractForge

-- 5.2.1.2c: In ETCS with RBC this restriction on performance shall, if possible be transmitted to the RBC.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  equipmentFailure : Bool
  deriving DecidableEq, Repr

structure Output where
  transmittedToRBC : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.equipmentFailure = true
  post := fun i o => o.transmittedToRBC = true ↔
    (i.equipmentFailure = true)

example : Spec.pre { equipmentFailure := true } ∧
          Spec.post { equipmentFailure := true }
                    { transmittedToRBC := true } := by
  unfold Spec; decide
