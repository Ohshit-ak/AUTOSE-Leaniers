import ContractForge
open ContractForge

-- 3.2.3/S1: The capacity of the system can be expressed in terms of nodes, which is defined as the number of workstations, or in terms of users, which is defined as the sum total of users at all the nodes.
-- compiles: True · rejects_bad_example: False · checked: False

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
                     o.capacityUsers = (i.nodes.map (·.workstations)).sum

example : Spec.pre { nodes := [{ workstations := 5 }, { workstations := 3 }] } ∧
          Spec.post { nodes := [{ workstations := 5 }, { workstations := 3 }] }
                    { capacityNodes := 8, capacityUsers := 8 } := by
  unfold Spec; decide
