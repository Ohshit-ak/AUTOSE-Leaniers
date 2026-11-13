import ContractForge
open ContractForge

-- 3.11.3/R15: ìWhen the password field is changed the repeat password field must be Changed and be identical with password field

-- L0 spec

structure Input where
  password  : String
  repeatPassword : String
  deriving DecidableEq, Repr

structure Output where
  password  : String
  repeatPassword : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.repeatPassword = i.repeatPassword ∧
                     o.repeatPassword = o.password

example : Spec.pre { password := "newpass", repeatPassword := "newpass" } ∧
          Spec.post { password := "newpass", repeatPassword := "newpass" }
                    { password := "newpass", repeatPassword := "newpass" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { password := x.password, repeatPassword := x.repeatPassword }
