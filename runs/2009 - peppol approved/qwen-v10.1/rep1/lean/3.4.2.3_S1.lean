import ContractForge
open ContractForge

-- 3.4.2.3/S1: Description Work package 2 will use the PEPPOL infrastructure for discovering addressing information which is typically stored in a registry.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  identifier : String
  registry   : List String
  deriving DecidableEq, Repr

structure Output where
  found     : Bool
  address   : Option String
  deriving DecidableEq, Repr

-- IMPL: Linear search in the registry
def Spec : Contract Input Output where
  pre  := fun i => i.identifier ≠ ""
  post := fun i o => o.found ↔ ∃ a ∈ i.registry, a = i.identifier ∧
                     (o.found = true → o.address = some a)

example : Spec.pre { identifier := "ID123", registry := ["ID123", "ID456"] } ∧
          Spec.post { identifier := "ID123", registry := ["ID123", "ID456"] }
                    { found := true, address := some "ID123" } := by
  unfold Spec; decide
