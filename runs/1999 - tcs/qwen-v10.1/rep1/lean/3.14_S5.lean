import ContractForge
open ContractForge

-- 3.14/S5: The TCS system shall provide, for the operator and maintainer, an embedded or add-on interactive training courseware with self-paced instruction, duplicating UAV flight performance characteristics, capabilities, and limitations. [SSS492] The OUTRIDER TCS system shall be compatible with the U.S.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  operator : Bool
  maintainer : Bool
  deriving DecidableEq, Repr

structure Output where
  trainingCourseware : Bool
  flightPerformance : Bool
  capabilities : Bool
  limitations : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.operator ∨ i.maintainer
  post := fun i o => (o.trainingCourseware = true ↔ i.operator ∨ i.maintainer) ∧
                     (o.flightPerformance = true ↔ o.trainingCourseware) ∧
                     (o.capabilities = true ↔ o.trainingCourseware) ∧
                     (o.limitations = true ↔ o.trainingCourseware)

example : Spec.pre { operator := true, maintainer := false } ∧
          Spec.post { operator := true, maintainer := false }
                    { trainingCourseware := true, flightPerformance := true, capabilities := true, limitations := true } := by
  unfold Spec; decide
