import ContractForge
open ContractForge

-- Assumptions/I2#2: The user will not alter any information about treatment, which is populating from the system
-- compiles: True · rejects_bad_example: None · checked: True

structure Treatment where
  id     : Nat
  name   : String
  details: String
  deriving DecidableEq, Repr

structure Input where
  treatments : List Treatment
  deriving DecidableEq, Repr

structure Output where
  treatments : List Treatment
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.treatments = i.treatments

example : Spec.pre { treatments := [{ id := 1, name := "Treatment A", details := "Details A" },
                                     { id := 2, name := "Treatment B", details := "Details B" }] } ∧
          Spec.post { treatments := [{ id := 1, name := "Treatment A", details := "Details A" },
                                      { id := 2, name := "Treatment B", details := "Details B" }] }
                    { treatments := [{ id := 1, name := "Treatment A", details := "Details A" },
                                     { id := 2, name := "Treatment B", details := "Details B" }] } := by
  unfold Spec; decide
