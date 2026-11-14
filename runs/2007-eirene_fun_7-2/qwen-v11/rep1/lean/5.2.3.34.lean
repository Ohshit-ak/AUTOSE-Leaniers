import ContractForge
open ContractForge

-- 5.2.3.34: 5.2.3.34 The drivers functional number shall be automatically registered/deregistered when the train number is registered/deregistered. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Train where
  number : Nat
  deriving DecidableEq, Repr

structure Driver where
  number : Nat
  registered : Bool
  deriving DecidableEq, Repr

structure Input where
  trains : List Train
  drivers : List Driver
  deriving DecidableEq, Repr

structure Output where
  trains : List Train
  drivers : List Driver
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o =>
    (∀ t ∈ i.trains, ∃ t' ∈ o.trains, t.number = t'.number) ∧
    (∀ d ∈ i.drivers, d.registered ↔
      ∃ t ∈ o.trains, t.number = d.number)

example : Spec.pre { trains := [{ number := 101 }, { number := 102 }],
                     drivers := [{ number := 101, registered := true },
                                 { number := 103, registered := false }] } ∧
          Spec.post { trains := [{ number := 101 }, { number := 102 }],
                      drivers := [{ number := 101, registered := true },
                                  { number := 103, registered := false }] }
                    { trains := [{ number := 101 }, { number := 102 }],
                      drivers := [{ number := 101, registered := true },
                                  { number := 103, registered := false }] } := by
  unfold Spec; decide
