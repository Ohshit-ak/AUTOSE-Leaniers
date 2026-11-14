import ContractForge
open ContractForge

-- 2.3.1.1/S1: Electronic questionnaires must be developed and validated.

-- L0 spec

structure Questionnaire where
  title   : String
  fields  : List String
  answers : List String
  deriving DecidableEq, Repr

structure Input where
  questions : List Questionnaire
  deriving DecidableEq, Repr

structure Output where
  validatedQuestions : List Questionnaire
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.questions.length > 0
  post := fun i o =>
    o.validatedQuestions.length = i.questions.length ∧
    ∀ q ∈ i.questions, q ∈ o.validatedQuestions ∧
    (q.fields.length > 0 ∧ q.answers.length = q.fields.length)

example : Spec.pre { questions := [{ title := "Symptoms", fields := ["fever", "cough"], answers := ["yes", "no"] },
                                    { title := "Travel History", fields := ["country"], answers := ["none"] }] } ∧
          Spec.post { questions := [{ title := "Symptoms", fields := ["fever", "cough"], answers := ["yes", "no"] },
                                     { title := "Travel History", fields := ["country"], answers := ["none"] }] }
                    { validatedQuestions := [{ title := "Symptoms", fields := ["fever", "cough"], answers := ["yes", "no"] },
                                              { title := "Travel History", fields := ["country"], answers := ["none"] }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { validatedQuestions := x.questions }
