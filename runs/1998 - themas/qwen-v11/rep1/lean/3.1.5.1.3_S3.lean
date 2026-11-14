import ContractForge
open ContractForge

-- 3.1.5.1.3/S3: When a request to turn on a heating or cooling unit is received, the system shall determine if the request can be honored.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  unitId : Nat
  status : String
  deriving DecidableEq, Repr

structure Output where
  canHonor : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.status ∈ ["off", "error"]
  post := fun i o => o.canHonor = true ↔ i.status = "off"

example : Spec.pre { unitId := 1, status := "off" } ∧
          Spec.post { unitId := 1, status := "off" }
                    { canHonor := true } := by
  unfold Spec; decide
