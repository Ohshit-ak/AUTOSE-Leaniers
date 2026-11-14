import ContractForge
open ContractForge

-- 4.2.4.2/I4: Performance The performance of error-mode recovery is specific to the subsystem and is defined in the Functional specification for that subsystem. Normally, there is no recovery possible from a fatal error except to shut-down and then restart the subsystem. However, in the case of an instrument failure, it may be possible to continue operation by rescheduling to use observations that do not require that particular instrument For serious errors, it may be possible to continue operation with degraded performance. For example, failure of automatic tracking may require manual tracking; other errors may result in operation with a different instrument Under normal conditions, the number of warnings should be small. The system should monitor the rate of warning messages since an increase might indicate that some tuning or maintenance is appropriate. Ideally, such conditions should be noted by the subsystems before reaching the OCS level. Failure conditions should not cascade. That is, failure of one subsystem should not affect other, working, subsystems, including communication links.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  warnings : List String
  deriving DecidableEq, Repr

structure Output where
  warnings : List String
  degraded : Bool
  shutdown : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.warnings.length ≤ 10
  post := fun i o => (o.warnings.length = i.warnings.length) ∧
                     (o.degraded = true ↔ i.warnings.length > 0) ∧
                     (o.shutdown = true ↔ i.warnings.length > 0) ∧
                     (o.warnings.length ≤ 10 → o.degraded = false) ∧
                     (o.warnings.length > 0 → o.shutdown = false)

example : Spec.pre { warnings := ["error1", "error2"] } ∧
          Spec.post { warnings := ["error1", "error2"] }
                    { warnings := ["error1", "error2"], degraded := true, shutdown := false } := by
  unfold Spec; decide
