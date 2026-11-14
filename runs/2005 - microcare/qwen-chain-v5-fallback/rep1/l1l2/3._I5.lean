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
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.forms.Nodup
  post := fun i o => (o.accepted = true ↔ i.forms.length > 0) ∧
                     (o.accepted = false → o.message = "No claim forms to process.")

example : Spec.pre { forms := [{ formNumber := 1, date := "2023-10-01" }] } ∧
          Spec.post { forms := [{ formNumber := 1, date := "2023-10-01" }] }
                    { accepted := true, message := "" } := by
  unfold Spec; decide

-- L1 architecture (mode=single-fallback, success=True)

-- not split (the two-component split failed): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { accepted := decide (x.forms.length > 0),
    message := if x.forms.length = 0 then "No claim forms to process." else "" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
