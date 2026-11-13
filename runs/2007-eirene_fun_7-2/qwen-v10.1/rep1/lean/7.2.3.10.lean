import ContractForge
open ContractForge

-- 7.2.3.10: 7.2.3.10 It shall be possible to register and deregister a functional number in the following way: Initiated by the user and transmitted to the ground: user enters functional number which is transmitted to the network. (M)
-- compiles: True · rejects_bad_example: None · checked: False

structure FunctionalNumber where
  number : String
  deriving DecidableEq, Repr

structure Input where
  functionalNumber : FunctionalNumber
  registered      : Bool
  deriving DecidableEq, Repr

structure Output where
  registered      : Bool
  functionalNumber : FunctionalNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber.number ≠ ""
  post := fun i o => (o.registered = true ↔ i.registered = false) ∧
                     (o.registered = false → i.functionalNumber.number = o.functionalNumber.number)

example : Spec.pre { functionalNumber := { number := "12345" }, registered := false } ∧
          Spec.post { functionalNumber := { number := "12345" }, registered := false }
                    { registered := true, functionalNumber := { number := "12345" } } := by
  unfold Spec; decide
