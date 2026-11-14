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

-- L1 architecture (mode=chain, success=False)

structure Mid where
  accepted : Bool
  message  : String
  deriving DecidableEq, Repr

def CheckFormsContract : Contract Input Mid where
  pre  := fun i => i.forms.Nodup
  post := fun i m => m.accepted = true ↔ i.forms.length > 0

def GenerateMessageContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => m.accepted = false → o.message = "No claim forms to process."
