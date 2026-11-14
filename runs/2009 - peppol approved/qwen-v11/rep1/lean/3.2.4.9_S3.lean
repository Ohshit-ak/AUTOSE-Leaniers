import ContractForge
open ContractForge

-- 3.2.4.9/S3: Validation values (e.g. certified "Yes/No" statements) should only be applied to networks where sufficient context specific data is available in order to approve this value.
-- compiles: True · rejects_bad_example: None · checked: False

structure Network where
  id         : Nat
  contextData : String
  certified  : Option Bool
  deriving DecidableEq, Repr

structure Input where
  networks : List Network
  deriving DecidableEq, Repr

structure Output where
  networks : List Network
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o =>
    ∀ n ∈ o.networks,
      n.certified = some true ↔
      n.contextData ≠ "" ∧
      ∃ n' ∈ i.networks, n' = n ∧ n'.contextData = n.contextData

example : Spec.pre { networks := [{ id := 1, contextData := "data1", certified := some true },
                                   { id := 2, contextData := "", certified := some false }] } ∧
          Spec.post { networks := [{ id := 1, contextData := "data1", certified := some true },
                                    { id := 2, contextData := "", certified := some false }] }
                    { networks := [{ id := 1, contextData := "data1", certified := some true },
                                   { id := 2, contextData := "", certified := some false }] } := by
  unfold Spec; decide
