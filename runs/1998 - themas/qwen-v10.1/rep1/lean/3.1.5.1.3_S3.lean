import ContractForge
open ContractForge

-- 3.1.5.1.3/S3: When a request to turn on a heating or cooling unit is received, the system shall determine if the request can be honored.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  unitId : Nat
  request : Bool
  status : Bool
  deriving DecidableEq, Repr

structure Output where
  canHonor : Bool
  newStatus : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.request = true
  post := fun i o => (o.canHonor = true ↔ i.status = false) ∧
                     (o.canHonor = true → o.newStatus = true) ∧
                     (o.canHonor = false → o.newStatus = i.status)

example : Spec.pre { unitId := 1, request := true, status := false } ∧
          Spec.post { unitId := 1, request := true, status := false }
                    { canHonor := true, newStatus := true } := by
  unfold Spec; decide
