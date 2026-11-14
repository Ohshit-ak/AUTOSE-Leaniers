import ContractForge
open ContractForge

-- 2.1.1/I9: The filed office will validate the claim form manually and through system,
-- compiles: True · rejects_bad_example: None · checked: True

structure ClaimForm where
  formNumber : String
  patientName : String
  amount : Nat
  deriving DecidableEq, Repr

structure Input where
  forms : List ClaimForm
  deriving DecidableEq, Repr

structure Output where
  validatedForms : List ClaimForm
  rejectedForms : List ClaimForm
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.forms.Nodup
  post := fun i o => 
    o.validatedForms.length + o.rejectedForms.length = i.forms.length ∧
    ∀ f ∈ i.forms, f ∈ o.validatedForms ∨ f ∈ o.rejectedForms ∧
    (f ∈ o.validatedForms ↔ f.amount ≤ 1000) ∧
    (f ∈ o.rejectedForms ↔ f.amount > 1000) ∧
    o.validatedForms = i.forms.filter (fun f => f.amount ≤ 1000) ∧
    o.rejectedForms = i.forms.filter (fun f => f.amount > 1000)

example : Spec.pre { forms := [{ formNumber := "123", patientName := "Alice", amount := 500 },
                               { formNumber := "456", patientName := "Bob", amount := 1500 }] } ∧
          Spec.post { forms := [{ formNumber := "123", patientName := "Alice", amount := 500 },
                                 { formNumber := "456", patientName := "Bob", amount := 1500 }] }
                    { validatedForms := [{ formNumber := "123", patientName := "Alice", amount := 500 }],
                      rejectedForms := [{ formNumber := "456", patientName := "Bob", amount := 1500 }] } := by
  unfold Spec; decide
