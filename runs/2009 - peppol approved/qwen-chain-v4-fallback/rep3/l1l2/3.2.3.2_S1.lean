import ContractForge
open ContractForge

-- 3.2.3.2/S1: Tagged records, information and data can be processed by independent systems and applications only if the constraining tags or metadata are recognized by the different processing parties.

-- L0 spec

structure Input where
  tags : List String
  deriving DecidableEq, Repr

structure Output where
  recognized : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.tags ≠ []
  post := fun i o => o.recognized = true ↔
    ∃ tag ∈ i.tags, tag = "constraining" -- assuming "constraining" is a specific tag

example : Spec.pre { tags := ["constraining", "other"] } ∧
          Spec.post { tags := ["constraining", "other"] }
                    { recognized := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { recognized := decide (exists fun tag => tag = "constraining" ∧ tag ∈ x.tags) }
