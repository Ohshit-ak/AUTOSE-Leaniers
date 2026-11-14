import ContractForge
open ContractForge

-- 3.21.1/S2: They can be added to user's database by using TAN wizard and can contain all letters and numbers.

-- L0 spec

structure TAN where
  value : String
  deriving DecidableEq, Repr

structure Input where
  tans : List TAN
  deriving DecidableEq, Repr

structure Output where
  tans : List TAN
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.tans.all (fun t => t.value.toList.all Char.isAlphanum = true)
  post := fun i o => o.tans = i.tans

example : Spec.pre { tans := [{ value := "AB12" }, { value := "CD34" }] } ∧
          Spec.post { tans := [{ value := "AB12" }, { value := "CD34" }] }
                    { tans := [{ value := "AB12" }, { value := "CD34" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { tans := x.tans }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
