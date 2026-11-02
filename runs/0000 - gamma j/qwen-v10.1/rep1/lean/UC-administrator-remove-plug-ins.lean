import ContractForge
open ContractForge

-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.
-- compiles: True · rejects_bad_example: True · checked: True

structure PlugIn where
  name : String
  active : Bool
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  name    : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.Nodup
  post := fun i o => 
    (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
    o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
    o.plugIns.Nodup

example : Spec.pre { plugIns := [{ name := "plug1", active := true },
                                  { name := "plug2", active := true }],
                     name := "plug1" } ∧
          Spec.post { plugIns := [{ name := "plug1", active := true },
                                  { name := "plug2", active := true }],
                      name := "plug1" }
                    { plugIns := [{ name := "plug2", active := true }] } := by
  unfold Spec; decide
