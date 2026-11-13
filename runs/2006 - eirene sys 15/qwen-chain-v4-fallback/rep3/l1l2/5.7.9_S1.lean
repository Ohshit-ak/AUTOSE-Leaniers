import ContractForge
open ContractForge

-- 5.7.9/S1: The "Subscriber Identity Module" (SIM card) shall be physically integrated with the radio set and shall not be able to be removed except by maintenance staff.

-- L0 spec

structure Input where
  simIntegrated : Bool
  simRemovable : Bool
  maintenanceStaff : Bool
  deriving DecidableEq, Repr

structure Output where
  simIntegrated : Bool
  simRemovable : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.simIntegrated = true ∧ i.simRemovable = false
  post := fun i o => o.simIntegrated = i.simIntegrated ∧
                     o.simRemovable = false ∧
                     (o.simRemovable = true ↔ i.maintenanceStaff = true)

example : Spec.pre { simIntegrated := true, simRemovable := false, maintenanceStaff := false } ∧
          Spec.post { simIntegrated := true, simRemovable := false, maintenanceStaff := false }
                    { simIntegrated := true, simRemovable := false } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { simIntegrated := x.simIntegrated, simRemovable := x.simRemovable }
