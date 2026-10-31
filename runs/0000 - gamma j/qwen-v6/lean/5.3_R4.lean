import ContractForge
open ContractForge

-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  ips : List String
  deriving DecidableEq, Repr

structure Output where
  blocked : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.ips.Nodup
  post := fun i o => o.blocked = true ↔
    (∃ ip ∈ i.ips, i.ips.count ip > 10) -- IMPL: Auto detect IP DOS attacks and block IP

example : Spec.pre { ips := ["192.168.1.1", "192.168.1.2"] } ∧ Spec.post { ips := ["192.168.1.1", "192.168.1.2"] } { blocked := false } := by
  unfold Spec; decide
