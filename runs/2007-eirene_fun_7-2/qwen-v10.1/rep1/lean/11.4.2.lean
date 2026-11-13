import ContractForge
open ContractForge

-- 11.4.2: 11.4.2 The functions to which calls shall be routed based upon the location of the mobile shall include: (M) Primary controller; Secondary controller; Power supply controller; Train management centre (eg RBC, CTS).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  location : String
  deriving DecidableEq, Repr

structure Output where
  controller : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.location ≠ ""
  post := fun i o => o.controller = "Primary controller" ∨
                     o.controller = "Secondary controller" ∨
                     o.controller = "Power supply controller" ∨
                     o.controller = "Train management centre (eg RBC, CTS)"

example : Spec.pre { location := "primary" } ∧
          Spec.post { location := "primary" }
                    { controller := "Primary controller" } := by
  unfold Spec; decide
