import ContractForge
open ContractForge

-- 5.2.3.38: 5.2.3.38 It shall be possible to register and deregister a stock number in one or both of the following ways: (M) automatically using information from on-board systems; automatically via a fixed interface between the locomotive/coach and the radio. Store/retrieve numbers and their details
-- compiles: True · rejects_bad_example: True · checked: True

structure StockNumber where
  number : Nat
  details : String
  deriving DecidableEq, Repr

structure Input where
  number : Nat
  details : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  deriving DecidableEq, Repr

-- IMPL: Automatically using information from on-board systems and a fixed interface

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.registered = true ↔
    (i.number > 5 ∧ i.details ≠ "")

example : Spec.pre { number := 10, details := "Details" } ∧
          Spec.post { number := 10, details := "Details" }
                    { registered := true } := by
  unfold Spec; decide
