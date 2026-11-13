import ContractForge
open ContractForge

-- 5.2.3.40: 5.2.3.40 It shall be possible for the driver to find and display stored numbers and their information. (M)
-- compiles: False · rejects_bad_example: None · checked: False

structure StoredNumber where
  number : Nat
  info   : String
  deriving DecidableEq, Repr

structure Input where
  numbers : List StoredNumber
  deriving DecidableEq, Repr

structure Output where
  number  : Nat
  info    : String
  found   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.numbers.Nodup
  post := fun i o => (o.found = true ↔
    ∃ n ∈ i.numbers, n.number = o.number) ∧
    (o.found = true → o.number ∈ i.numbers.map (·.number) ∧
     o.info = (i.numbers.find? (·.number = o.number).get!).info)

example : Spec.pre { numbers := [{ number := 1, info := "Info 1" },
                                  { number := 2, info := "Info 2" }] } ∧
          Spec.post { numbers := [{ number := 1, info := "Info 1" },
                                  { number := 2, info := "Info 2" }] }
                    { number := 1, info := "Info 1", found := true } := by
  unfold Spec; decide
