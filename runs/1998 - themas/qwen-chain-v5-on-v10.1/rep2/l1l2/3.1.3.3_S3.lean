import ContractForge
open ContractForge

-- 3.1.3.3/S3: A current temperature value that is received from an individual thermostat shall be compared to the valid temperature range values.

-- L0 spec

structure Input where
  temperature : Nat
  valid_min   : Nat
  valid_max   : Nat
  deriving DecidableEq, Repr

structure Output where
  valid         : Bool
  error_message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.temperature < 10000 && i.valid_min < 10000 && i.valid_max < 10000
  post := fun i o => (o.valid = true ↔ i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max) ∧
                     (o.valid = false → o.error_message ≠ "")

example : Spec.pre { temperature := 25, valid_min := 0, valid_max := 50 } ∧
          Spec.post { temperature := 25, valid_min := 0, valid_max := 50 }
                    { valid := true, error_message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  valid         : Bool
  error_message : String
  deriving DecidableEq, Repr

def TemperatureCheckContract : Contract Input Mid where
  pre  := fun i => i.temperature < 10000 && i.valid_min < 10000 && i.valid_max < 10000
  post := fun i m => m.valid = (i.temperature ≥ i.valid_min ∧ i.temperature ≤ i.valid_max) ∧
                     m.error_message = ""

def ErrorHandlingContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (m.valid = true ↔ o.valid = true) ∧
                     (m.valid = false → o.error_message ≠ "")

theorem po1 : Contract.Compatible TemperatureCheckContract ErrorHandlingContract := by
  discharge_po1 [TemperatureCheckContract, ErrorHandlingContract, Spec]

theorem po2 : Contract.Refines (TemperatureCheckContract.seq ErrorHandlingContract) Spec := by
  discharge_po2 [TemperatureCheckContract, ErrorHandlingContract, Spec]

-- L2 TemperatureCheckContract (success=True)

def TemperatureCheckContractImpl (x : Input) : Mid :=
  { valid := x.temperature ≥ x.valid_min ∧ x.temperature ≤ x.valid_max,
    error_message := "" }

theorem TemperatureCheckContractImpl_ok : TemperatureCheckContract.Satisfies TemperatureCheckContractImpl := by
  discharge_po3 [TemperatureCheckContract, TemperatureCheckContractImpl]

-- L2 ErrorHandlingContract (success=True)

def ErrorHandlingContractImpl (x : Mid) : Output :=
  { valid := decide (x.valid = true),
    error_message := if x.valid = true then "" else "Invalid temperature" }

theorem ErrorHandlingContractImpl_ok : ErrorHandlingContract.Satisfies ErrorHandlingContractImpl := by
  discharge_po3 [ErrorHandlingContract, ErrorHandlingContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (ErrorHandlingContractImpl ∘ TemperatureCheckContractImpl) :=
  Contract.system_sound po1 po2 TemperatureCheckContractImpl_ok ErrorHandlingContractImpl_ok
