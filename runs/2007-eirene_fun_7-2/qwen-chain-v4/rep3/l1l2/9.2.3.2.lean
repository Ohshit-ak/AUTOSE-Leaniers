import ContractForge
open ContractForge

-- 9.2.3.2: 9.2.3.2 Every on-engine/coach function shall be identified by a unique standard number. (M)

-- L0 spec

structure Input where
  functionName : String
  number       : Nat
  deriving DecidableEq, Repr

structure Output where
  functionNumber : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionName ≠ ""
  post := fun i o => o.functionNumber = i.number

example : Spec.pre { functionName := "Brake System", number := 1234 } ∧
          Spec.post { functionName := "Brake System", number := 1234 }
                    { functionNumber := 1234 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { functionNumber := x.number }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
