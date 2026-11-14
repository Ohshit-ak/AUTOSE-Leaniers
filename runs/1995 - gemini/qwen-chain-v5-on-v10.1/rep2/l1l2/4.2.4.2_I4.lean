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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { subsystemFailed := decide (¬ ((x.warnings = [] ∧ x.rate ≤ 100))),
    warnings := if x.warnings ≠ [] then x.warnings else x.warnings,
    rate := x.rate }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
