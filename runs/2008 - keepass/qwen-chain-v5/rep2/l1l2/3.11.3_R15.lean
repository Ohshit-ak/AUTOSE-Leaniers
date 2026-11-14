import ContractForge
open ContractForge

-- 3.11.3/R15: ìWhen the password field is changed the repeat password field must be Changed and be identical with password field

-- L0 spec

structure Input where
  password  : String
  repeatPassword : String
  changeRepeatPassword : Bool
  deriving DecidableEq, Repr

structure Output where
  password  : String
  repeatPassword : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.password = i.password ∧
                     (if i.changeRepeatPassword then
                        o.repeatPassword = i.password
                      else
                        o.repeatPassword = i.repeatPassword)

example : Spec.pre { password := "newpass", repeatPassword := "newpass", changeRepeatPassword := true } ∧
          Spec.post { password := "newpass", repeatPassword := "newpass", changeRepeatPassword := true }
                    { password := "newpass", repeatPassword := "newpass" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { password := x.password,
    repeatPassword := if x.changeRepeatPassword then x.password else x.repeatPassword }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
