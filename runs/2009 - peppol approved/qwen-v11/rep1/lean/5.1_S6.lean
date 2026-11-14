import ContractForge
open ContractForge

-- 5.1/S6: The VCD should encompass this change.
-- compiles: True · rejects_bad_example: True · checked: True

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
