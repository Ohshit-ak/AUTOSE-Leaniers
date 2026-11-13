import ContractForge
open ContractForge

-- 2.14.3/I7: All Gemini subsystem packages should include as part of the software both a simulator module for inclusion in the virtual telescope (see Design constraints, below), and user interface modules for the user interface environments that the subsystem will be operating in. The interfaces required of these user interface modules are described in Section 3.3 on page 3-6.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  simulatorModule : Bool
  userInterfaceModules : List String
  deriving DecidableEq, Repr

structure Output where
  simulatorModule : Bool
  userInterfaceModules : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.simulatorModule = true
  post := fun i o => o.simulatorModule = i.simulatorModule ∧
                     o.userInterfaceModules = i.userInterfaceModules

example : Spec.pre { simulatorModule := true, userInterfaceModules := ["GUI", "CLI"] } ∧
          Spec.post { simulatorModule := true, userInterfaceModules := ["GUI", "CLI"] }
                    { simulatorModule := true, userInterfaceModules := ["GUI", "CLI"] } := by
  unfold Spec; decide
