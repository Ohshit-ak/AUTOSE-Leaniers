import ContractForge
open ContractForge

-- 3.3.2.12/S6: Requirement A trust model and trust system MUST be defined from a legal point of view for every process which includes the roles and responsibilities of the entities involved.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  rolesResponsibilities : String
  deriving DecidableEq, Repr

structure Output where
  trustModel : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.rolesResponsibilities ≠ ""
  post := fun i o => o.trustModel = i.rolesResponsibilities

example : Spec.pre { rolesResponsibilities := "Entity A is responsible for data processing, Entity B for data storage." } ∧
          Spec.post { rolesResponsibilities := "Entity A is responsible for data processing, Entity B for data storage." }
                    { trustModel := "Entity A is responsible for data processing, Entity B for data storage." } := by
  unfold Spec; decide
