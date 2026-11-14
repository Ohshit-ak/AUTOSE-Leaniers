import ContractForge
open ContractForge

-- 5.2.3.12: 5.2.3.12 It shall be possible to present radio related prompts and information in a number of different languages. (M)

-- L0 spec

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  prompt   : String
  language : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ ""
  post := fun i o => o.language = i.language ∧
                     (o.prompt = "Radio related prompt in " ++ i.language)

example : Spec.pre { language := "English" } ∧
          Spec.post { language := "English" }
                    { prompt := "Radio related prompt in English", language := "English" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { prompt := "Radio related prompt in " ++ x.language,
    language := x.language }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
