import ContractForge
open ContractForge

-- 2.1.1/I9: The filed office will validate the claim form manually and through system,

-- L0 spec

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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  validatedForms : List ClaimForm
  rejectedForms : List ClaimForm
  forms : List ClaimForm
  deriving DecidableEq, Repr

def ValidateFormsContract : Contract Input Mid where
  pre  := fun i => i.forms.Nodup
  post := fun i m => (m.validatedForms = i.forms.filter (fun f => f.amount ≤ 1000) ∧
                     m.rejectedForms = i.forms.filter (fun f => f.amount > 1000) ∧
                     m.validatedForms.length + m.rejectedForms.length = i.forms.length) ∧ m.forms = i.forms

def RejectedFormsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.validatedForms = m.validatedForms ∧
                     o.rejectedForms = m.rejectedForms ∧
                     o.validatedForms.length + o.rejectedForms.length = m.forms.length

theorem po1 : Contract.Compatible ValidateFormsContract RejectedFormsContract := by
  discharge_po1 [ValidateFormsContract, RejectedFormsContract, Spec]

theorem po2 : Contract.Refines (ValidateFormsContract.seq RejectedFormsContract) Spec := by
  discharge_po2 [ValidateFormsContract, RejectedFormsContract, Spec]

-- L2 ValidateFormsContract (success=False)

def ValidateFormsContractImpl (x : Input) : Mid :=
  { validatedForms := x.forms.filter (fun f => f.amount ≤ 1000),
    rejectedForms := x.forms.filter (fun f => f.amount > 1000),
    forms := x.forms }

-- L2 RejectedFormsContract (success=False)

def RejectedFormsContractImpl (x : Mid) : Output :=
  { validatedForms := x.validatedForms,
    rejectedForms := x.rejectedForms }
