import ContractForge
open ContractForge

-- 3.2.5.2.1/S2: Create Tactical Communications Messages to include United States Message Text Format (USMTF), Tactical Fire (TACFIRE), Over The Horizon Gold (OTH-Gold), and Intelligence and Electronic Warfare Character Oriented Message Catalog (IEWCOMCAT) For Transmission (specific message types will be identified in the all applicable TCS to C4I IDDs) [SSS230] 2.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  messages : List String
  deriving DecidableEq, Repr

structure Output where
  usmtf    : List String
  tacfire  : List String
  othgold  : List String
  iewcomcat : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.messages.Nodup
  post := fun i o => 
    o.usmtf = i.messages.filter (fun m => m.all (fun c => c == 'U' ∨ c == 'S' ∨ c == 'M' ∨ c == 'T' ∨ c == 'F'))
    ∧ o.tacfire = i.messages.filter (fun m => m.all (fun c => c == 'T' ∨ c == 'A' ∨ c == 'C' ∨ c == 'F' ∨ c == 'I' ∨ c == 'R' ∨ c == 'E'))
    ∧ o.othgold = i.messages.filter (fun m => m.all (fun c => c == 'O' ∨ c == 'T' ∨ c == 'H' ∨ c == 'G' ∨ c == 'O' ∨ c == 'L' ∨ c == 'D'))
    ∧ o.iewcomcat = i.messages.filter (fun m => m.all (fun c => c == 'I' ∨ c == 'E' ∨ c == 'W' ∨ c == 'C' ∨ c == 'O' ∨ c == 'M' ∨ c == 'C' ∨ c == 'A' ∨ c == 'T'))

example : Spec.pre { messages := ["USMTF", "TACFIRE", "OTH-GOLD", "IEWCOMCAT"] } ∧
          Spec.post { messages := ["USMTF", "TACFIRE", "OTH-GOLD", "IEWCOMCAT"] }
                    { usmtf := ["USMTF"], tacfire := ["TACFIRE"], othgold := ["OTH-GOLD"], iewcomcat := ["IEWCOMCAT"] } := by
  unfold Spec; decide
