import ContractForge
open ContractForge

-- 3.14/S5: The TCS system shall provide, for the operator and maintainer, an embedded or add-on interactive training courseware with self-paced instruction, duplicating UAV flight performance characteristics, capabilities, and limitations. [SSS492] The OUTRIDER TCS system shall be compatible with the U.S.

-- L0 spec

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

-- L1 architecture (mode=single-not-decomposable, success=True)

-- not split (not decomposable (every split was an identity)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { trainingCourseware := decide (x.operator ∨ x.maintainer),
    flightPerformance := trainingCourseware,
    capabilities := trainingCourseware,
    limitations := trainingCourseware }
