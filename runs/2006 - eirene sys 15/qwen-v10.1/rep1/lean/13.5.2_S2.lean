import ContractForge
open ContractForge

-- 13.5.2/S2: The application must be able to deduce that a confirmation is necessary from the call priority, as all calls of 'Railway emergency' priority must be confirmed.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  priority : Nat
  deriving DecidableEq, Repr

structure Output where
  confirmed : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.priority = 1 -- Assume 1 is the 'Railway emergency' priority
  post := fun i o => o.confirmed = true

example : Spec.pre { priority := 1 } ∧ Spec.post { priority := 1 } { confirmed := true } := by
  unfold Spec; decide
