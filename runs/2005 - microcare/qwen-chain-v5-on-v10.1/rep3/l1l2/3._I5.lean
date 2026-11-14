import ContractForge
open ContractForge

-- 3./I5: The VSP will send the collected claim forms monthly and send it to MSIU field office.

-- L0 spec

structure ClaimForm where
  formNumber : Nat
  date       : String
  deriving DecidableEq, Repr

structure Input where
  forms : List ClaimForm
  date  : String
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  date : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.forms.length > 0
  post := fun i o => o.sent = true ∧
                     (o.date = i.date ∨ o.date = "N/A") ∧
                     (o.date = "N/A" ↔ i.forms.length = 0)

example : Spec.pre { forms := [{ formNumber := 1, date := "2023-10-01" },
                               { formNumber := 2, date := "2023-10-01" }],
                     date := "2023-10-01" } ∧
          Spec.post { forms := [{ formNumber := 1, date := "2023-10-01" },
                                 { formNumber := 2, date := "2023-10-01" }],
                      date := "2023-10-01" }
                    { sent := true, date := "2023-10-01" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { sent := true,
    date := if x.forms.length = 0 then "N/A" else x.date }
