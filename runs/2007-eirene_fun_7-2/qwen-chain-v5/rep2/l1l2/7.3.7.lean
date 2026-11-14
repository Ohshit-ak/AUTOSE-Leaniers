import ContractForge
open ContractForge

-- 7.3.7: 7.3.7 It should be possible for a user to change the battery without the use of tools. (O)

-- L0 spec

structure Battery where
  model : String
  voltage : Nat
  deriving DecidableEq, Repr

structure User where
  toolsAvailable : Bool
  deriving DecidableEq, Repr

structure Input where
  battery : Battery
  user    : User
  deriving DecidableEq, Repr

structure Output where
  battery : Battery
  user    : User
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.user.toolsAvailable = false
  post := fun i o => o.success = true ∧
                     o.battery = i.battery ∧
                     o.user.toolsAvailable = i.user.toolsAvailable

example : Spec.pre { battery := { model := "model1", voltage := 3 }, user := { toolsAvailable := false } } ∧
          Spec.post { battery := { model := "model1", voltage := 3 }, user := { toolsAvailable := false } }
                     { success := true, battery := { model := "model1", voltage := 3 }, user := { toolsAvailable := false } } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { battery := x.battery,
    user := { toolsAvailable := x.user.toolsAvailable },
    success := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
