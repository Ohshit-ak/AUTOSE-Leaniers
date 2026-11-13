import ContractForge
open ContractForge

-- 5.2.3.34: 5.2.3.34 The drivers functional number shall be automatically registered/deregistered when the train number is registered/deregistered. (M)
-- compiles: False · rejects_bad_example: None · checked: False

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
    (∀ t ∈ i.trains, t.number ∈ o.trains.number) ∧
    (∀ d ∈ i.drivers, d.registered = true ↔
      ∃ t ∈ i.trains, t.number = d.number ∧ t.number ∈ o.trains.number) ∧
    (∀ d ∈ i.drivers, d.registered = false ↔
      ¬∃ t ∈ i.trains, t.number = d.number ∧ t.number ∈ o.trains.number)

example : Spec.pre { trains := [{ number := 1 }, { number := 2 }],
                     drivers := [{ number := 1, registered := true },
                                 { number := 2, registered := false }] } ∧
          Spec.post { trains := [{ number := 1 }, { number := 2 }],
                      drivers := [{ number := 1, registered := true },
                                  { number := 2, registered := false }] }
                    { trains := [{ number := 1 }, { number := 2 }],
                      drivers := [{ number := 1, registered := true },
                                  { number := 2, registered := false }] } := by
  unfold Spec; decide
