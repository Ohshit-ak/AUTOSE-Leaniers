import ContractForge
open ContractForge

-- 5.2.3.13: 5.2.3.13 By default, prompts and information shall be displayed in the language selected by the train owner (as stored within the system). (M)

-- L0 spec

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  prompt  : String
  info    : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ ""
  post := fun i o => o.prompt = i.language ∧ o.info = i.language

example : Spec.pre { language := "English" } ∧
          Spec.post { language := "English" }
                    { prompt := "English", info := "English" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { prompt := x.language,
    info := x.language }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
