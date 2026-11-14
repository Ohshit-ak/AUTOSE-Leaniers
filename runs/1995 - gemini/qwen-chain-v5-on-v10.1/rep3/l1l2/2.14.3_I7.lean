import ContractForge
open ContractForge

-- 2.14.3/I7: All Gemini subsystem packages should include as part of the software both a simulator module for inclusion in the virtual telescope (see Design constraints, below), and user interface modules for the user interface environments that the subsystem will be operating in. The interfaces required of these user interface modules are described in Section 3.3 on page 3-6.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { simulatorModule := x.simulatorModule,
    userInterfaceModules := x.userInterfaceModules }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
