import ContractForge
open ContractForge

-- 3.10.3/R11: An entry must belong to a group to be created

-- L0 spec

structure Group where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Entry where
  id : Nat
  name : String
  groupId : Nat
  deriving DecidableEq, Repr

structure Input where
  name : String
  groupId : Nat
  deriving DecidableEq, Repr

structure Output where
  id : Nat
  name : String
  groupId : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.groupId ≠ 0
  post := fun i o => o.groupId = i.groupId ∧ o.name = i.name ∧ o.id ≠ 0

example : Spec.pre { name := "New Entry", groupId := 1 } ∧
          Spec.post { name := "New Entry", groupId := 1 }
                    { id := 2, name := "New Entry", groupId := 1 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { id := x.id, name := x.name, groupId := x.groupId }
