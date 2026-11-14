import ContractForge
open ContractForge

-- 4.4.1.2: Information received shall not influence the traction unit(s) with in-operative cabs.
-- compiles: True · rejects_bad_example: None · checked: True

structure TractionUnit where
  cabStatus : Bool
  deriving DecidableEq, Repr

structure Input where
  units : List TractionUnit
  information : String
  deriving DecidableEq, Repr

structure Output where
  units : List TractionUnit
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.units.all (fun u => u.cabStatus)
  post := fun i o => o.units = i.units ∧
                     (o.units.all (fun u => u.cabStatus ↔ i.units.any (fun u' => u' = u)))

example : Spec.pre { units := [{ cabStatus := true }, { cabStatus := true }],
                     information := "some data" } ∧
          Spec.post { units := [{ cabStatus := true }, { cabStatus := true }],
                      information := "some data" }
                    { units := [{ cabStatus := true }, { cabStatus := true }] } := by
  unfold Spec; decide
