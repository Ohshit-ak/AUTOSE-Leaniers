import ContractForge
open ContractForge

-- 5.2.3.17: 5.2.3.17 By default, the loudspeaker volume shall be set to a pre-determined level suitable for the operating environment (as stored within the system). (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  volumeLevel : Nat
  deriving DecidableEq, Repr

structure Output where
  volumeLevel : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => o.volumeLevel = i.volumeLevel

example : Spec.pre { volumeLevel := 70 } ∧
          Spec.post { volumeLevel := 70 } { volumeLevel := 70 } := by
  unfold Spec; decide
