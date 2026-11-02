import ContractForge
open ContractForge

-- UC-administrator-manage-plug-in-options: Manage Plug-in Options: Make changes to an installed plug-in.
-- compiles: False · rejects_bad_example: None · checked: False

structure PlugInOption where
  name : String
  value : String
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugInOption
  changes : List PlugInOption
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugInOption
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.changes.all (fun c => ∃ p ∈ i.plugIns, p.name = c.name)
  post := fun i o => o.plugIns.length = i.plugIns.length ∧
                     (∀ p ∈ o.plugIns, p.name = i.plugIns.find? (fun p' => p'.name = p.name).get.name ∧
                      (p.value = i.plugIns.find? (fun p' => p'.name = p.name).get.value ↔
                       ∃ c ∈ i.changes, c.name = p.name))

example : Spec.pre { plugIns := [{ name := "option1", value := "value1" },
                                  { name := "option2", value := "value2" }],
                     changes := [{ name := "option1", value := "newvalue1" }] } ∧
          Spec.post { plugIns := [{ name := "option1", value := "newvalue1" },
                                   { name := "option2", value := "value2" }],
                      changes := [{ name := "option1", value := "newvalue1" }] }
                    { plugIns := [{ name := "option1", value := "newvalue1" },
                                  { name := "option2", value := "value2" }] } := by
  unfold Spec; decide
