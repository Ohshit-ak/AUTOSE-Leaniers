import ContractForge
open ContractForge

-- 13.1.7: 13.1.7 The Shunting emergency call shall be sent to all users involved in shunting operations in the shunting area. (M)

-- L0 spec

structure User where
  name : String
  deriving DecidableEq, Repr

structure Input where
  shuntingAreaUsers : List User
  deriving DecidableEq, Repr

structure Output where
  emergencyCallSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.shuntingAreaUsers.Nodup ∧ i.shuntingAreaUsers.all (·.name ≠ "")
  post := fun i o => o.emergencyCallSent = true ∧
                     (∀ u ∈ i.shuntingAreaUsers, u.name ≠ "")

example : Spec.pre { shuntingAreaUsers := [{ name := "John" }, { name := "Jane" }] } ∧
          Spec.post { shuntingAreaUsers := [{ name := "John" }, { name := "Jane" }] }
                    { emergencyCallSent := true } := by
  unfold Spec; decide

def computeEmergencyCallSent (i : Input) : Bool :=
  i.shuntingAreaUsers.Nodup ∧ i.shuntingAreaUsers.all (·.name ≠ "")

example : computeEmergencyCallSent { shuntingAreaUsers := [{ name := "John" }, { name := "Jane" }] } = true := by
  decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { emergencyCallSent := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
