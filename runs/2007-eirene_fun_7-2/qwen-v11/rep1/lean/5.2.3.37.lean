import ContractForge
open ContractForge

-- 5.2.3.37: 5.2.3.37 There shall be a fixed relationship between the telephone numbers of radios installed in the locomotive/coach and the stock number, which shall remain even if the radio is changed. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Radio where
  stockNumber : Nat
  telephoneNumber : Nat
  deriving DecidableEq, Repr

structure Input where
  radios : List Radio
  deriving DecidableEq, Repr

structure Output where
  radios : List Radio
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => 
    o.radios.Nodup ∧
    ∀ r ∈ o.radios, 
      ∃ r' ∈ i.radios, 
        r.stockNumber = r'.stockNumber ∧ r.telephoneNumber = r'.telephoneNumber ∧
        (r' :: o.radios).Nodup ∧
        (r = r' → o.radios = i.radios) ∧
        (r ≠ r' → o.radios.length = i.radios.length)

example : Spec.pre { radios := [{ stockNumber := 1, telephoneNumber := 100 }, { stockNumber := 2, telephoneNumber := 200 }] } ∧ Spec.post { radios := [{ stockNumber := 1, telephoneNumber := 100 }, { stockNumber := 2, telephoneNumber := 200 }] } { radios := [] } := by
  unfold Spec; decide
