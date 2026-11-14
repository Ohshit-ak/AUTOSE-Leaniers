import ContractForge
open ContractForge

-- 3.3.2.12/S6: Requirement A trust model and trust system MUST be defined from a legal point of view for every process which includes the roles and responsibilities of the entities involved.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  roles : List String
  responsibilities : List String
  deriving DecidableEq, Repr

structure Output where
  trustModelDefined : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.roles ≠ [] ∧ i.responsibilities ≠ []
  post := fun i o => o.trustModelDefined = true ∧
                     (o.trustModelDefined = true ↔ i.roles ≠ [] ∧ i.responsibilities ≠ [])

example : Spec.pre { roles := ["Entity A", "Entity B"], responsibilities := ["Role 1", "Role 2"] } ∧
          Spec.post { roles := ["Entity A", "Entity B"], responsibilities := ["Role 1", "Role 2"] }
                    { trustModelDefined := true } := by
  unfold Spec; decide
