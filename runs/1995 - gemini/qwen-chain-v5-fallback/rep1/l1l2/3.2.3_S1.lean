import ContractForge
open ContractForge

-- 3.2.3/S1: The capacity of the system can be expressed in terms of nodes, which is defined as the number of workstations, or in terms of users, which is defined as the sum total of users at all the nodes.

-- L0 spec

structure Node where
  workstations : Nat
  deriving DecidableEq, Repr

structure Input where
  nodes : List Node
  deriving DecidableEq, Repr

structure Output where
  capacityNodes : Nat
  capacityUsers : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.nodes.Nodup
  post := fun i o => o.capacityNodes = (i.nodes.map (·.workstations)).sum ∧
                     (o.capacityUsers = (i.nodes.map (·.workstations)).sum ↔
                      i.nodes.length = 1)

example : Spec.pre { nodes := [{ workstations := 5 }, { workstations := 3 }] } ∧ Spec.post { nodes := [{ workstations := 5 }, { workstations := 3 }] } { capacityNodes := 8, capacityUsers := 0 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { capacityNodes := (x.nodes.map (·.workstations)).sum,
    capacityUsers := if x.nodes.length = 1 then (x.nodes.map (·.workstations)).sum else 0 }
