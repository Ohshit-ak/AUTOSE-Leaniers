import ContractForge
open ContractForge

-- 4.2.4.2/I4: Performance The performance of error-mode recovery is specific to the subsystem and is defined in the Functional specification for that subsystem. Normally, there is no recovery possible from a fatal error except to shut-down and then restart the subsystem. However, in the case of an instrument failure, it may be possible to continue operation by rescheduling to use observations that do not require that particular instrument For serious errors, it may be possible to continue operation with degraded performance. For example, failure of automatic tracking may require manual tracking; other errors may result in operation with a different instrument Under normal conditions, the number of warnings should be small. The system should monitor the rate of warning messages since an increase might indicate that some tuning or maintenance is appropriate. Ideally, such conditions should be noted by the subsystems before reaching the OCS level. Failure conditions should not cascade. That is, failure of one subsystem should not affect other, working, subsystems, including communication links.

-- L0 spec

structure Input where
  warnings : List String
  rate     : Nat
  deriving DecidableEq, Repr

structure Output where
  subsystemFailed : Bool
  warnings        : List String
  rate            : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.rate ≤ 100
  post := fun i o => 
    (o.subsystemFailed = false ↔ (i.warnings = [] ∧ i.rate ≤ 100)) ∧
    (o.subsystemFailed = true → o.warnings = i.warnings ∧ o.rate = i.rate) ∧
    (i.warnings ≠ [] → o.warnings = i.warnings) ∧
    o.rate = i.rate

example : Spec.pre { warnings := [], rate := 50 } ∧ Spec.post { warnings := [], rate := 50 } { subsystemFailed := false, warnings := [], rate := 50 } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  warnings : List String
  rate     : Nat
  isSafe   : Bool
  deriving DecidableEq, Repr

def ComputeMidContract : Contract Input Mid where
  pre  := fun i => i.rate ≤ 100
  post := fun i m => m.warnings = i.warnings ∧ m.rate = i.rate ∧ m.isSafe = (i.warnings = [])

def FinalizeOutputContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    (o.subsystemFailed = false ↔ (m.warnings = [] ∧ m.rate ≤ 100 ∧ m.isSafe)) ∧
    (o.subsystemFailed = true → o.warnings = m.warnings ∧ o.rate = m.rate) ∧
    (m.warnings ≠ [] → o.warnings = m.warnings) ∧
    o.rate = m.rate

theorem po1 : Contract.Compatible ComputeMidContract FinalizeOutputContract := by
  discharge_po1 [ComputeMidContract, FinalizeOutputContract, Spec]

theorem po2 : Contract.Refines (ComputeMidContract.seq FinalizeOutputContract) Spec := by
  discharge_po2 [ComputeMidContract, FinalizeOutputContract, Spec]

-- L2 ComputeMidContract (success=True)

def ComputeMidContractImpl (x : Input) : Mid :=
  { warnings := x.warnings, rate := x.rate, isSafe := x.warnings = [] }

theorem ComputeMidContractImpl_ok : ComputeMidContract.Satisfies ComputeMidContractImpl := by
  discharge_po3 [ComputeMidContract, ComputeMidContractImpl]

-- L2 FinalizeOutputContract (success=False)

def FinalizeOutputContractImpl (x : Mid) : Output :=
  { subsystemFailed := false,
    warnings := x.warnings,
    rate := x.rate }
