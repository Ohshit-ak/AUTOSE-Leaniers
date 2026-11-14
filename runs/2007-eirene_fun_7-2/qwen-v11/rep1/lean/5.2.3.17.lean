import ContractForge
open ContractForge

-- 5.2.3.17: 5.2.3.17 By default, the loudspeaker volume shall be set to a pre-determined level suitable for the operating environment (as stored within the system). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  volume : Nat
  deriving DecidableEq, Repr

structure Output where
  volume : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.volume = i.volume ∧
                     (o.volume = 5 ↔ i.volume = 5)

example : Spec.pre { volume := 5 } ∧ Spec.post { volume := 5 } { volume := 5 } := by
  unfold Spec; decide
