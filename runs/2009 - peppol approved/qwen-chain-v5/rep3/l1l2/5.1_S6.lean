import ContractForge
open ContractForge

-- 5.1/S6: The VCD should encompass this change.

-- L0 spec

structure ValueChange where
  value : Nat
  changeType : String
  deriving DecidableEq, Repr

structure Input where
  vcd : ValueChange
  changeType : String
  deriving DecidableEq, Repr

structure Output where
  vcd : ValueChange
  changeType : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.vcd.value ≥ 0
  post := fun i o => o.vcd = i.vcd ∧ o.changeType = i.changeType

example : Spec.pre { vcd := { value := 10, changeType := "add" }, changeType := "add" } ∧
          Spec.post { vcd := { value := 10, changeType := "add" }, changeType := "add" }
                    { vcd := { value := 10, changeType := "add" }, changeType := "add" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { vcd := x.vcd,
    changeType := x.changeType }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
