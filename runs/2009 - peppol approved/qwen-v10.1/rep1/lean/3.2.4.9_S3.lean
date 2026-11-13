import ContractForge
open ContractForge

-- 3.2.4.9/S3: Validation values (e.g. certified "Yes/No" statements) should only be applied to networks where sufficient context specific data is available in order to approve this value.
-- compiles: True · rejects_bad_example: True · checked: True

structure Network where
  id        : Nat
  data      : String
  certified : Option Bool
  deriving DecidableEq, Repr

structure Input where
  networks : List Network
  deriving DecidableEq, Repr

structure Output where
  networks : List Network
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.networks.Nodup
  post := fun i o =>
    ∀ n ∈ o.networks, n.certified = some true ↔
      (n.data ≠ "" ∧ n.data.toList.all (fun c => c.isAlphanum || c == ' '))

example : Spec.pre { networks := [{ id := 1, data := "context1", certified := some true }, { id := 2, data := "context2", certified := some false }] } ∧ Spec.post { networks := [{ id := 1, data := "context1", certified := some true }, { id := 2, data := "context2", certified := some false }] } { networks := [] } := by
  unfold Spec; decide
