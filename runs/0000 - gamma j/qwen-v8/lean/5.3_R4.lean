import ContractForge
open ContractForge

-- 5.3/R4: The system shall auto detect IP DOS attacks and block IP automatically.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  ipDOSCount : Nat
  ip          : String
  deriving DecidableEq, Repr

structure Output where
  ipDOSCount : Nat
  ip         : String
  blocked    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => 0 < i.ipDOSCount
  post := fun i o => (o.blocked = true ↔ i.ipDOSCount ≥ 5) ∧
                     (o.blocked = true → o.ipDOSCount = i.ipDOSCount + 1) ∧
                     (o.blocked = false ↔ i.ipDOSCount < 5) ∧
                     (o.ip = i.ip)

example : Spec.pre { ipDOSCount := 10, ip := "192.168.1.1" } ∧
          Spec.post { ipDOSCount := 10, ip := "192.168.1.1" }
                    { ipDOSCount := 11, ip := "192.168.1.1", blocked := true } := by
  unfold Spec; decide
