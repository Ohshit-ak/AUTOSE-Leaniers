import ContractForge
open ContractForge

-- 5.7.9/S1: The "Subscriber Identity Module" (SIM card) shall be physically integrated with the radio set and shall not be able to be removed except by maintenance staff.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  simIntegrated : Bool
  maintenanceStaff : Bool
  deriving DecidableEq, Repr

structure Output where
  simIntegrated : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.simIntegrated = true ∧ i.maintenanceStaff = false
  post := fun i o => o.simIntegrated = i.simIntegrated ∧
                     (o.simIntegrated = false ↔ i.maintenanceStaff = true)

example : Spec.pre { simIntegrated := true, maintenanceStaff := false } ∧
          Spec.post { simIntegrated := true, maintenanceStaff := false }
                    { simIntegrated := true } := by
  unfold Spec; decide
