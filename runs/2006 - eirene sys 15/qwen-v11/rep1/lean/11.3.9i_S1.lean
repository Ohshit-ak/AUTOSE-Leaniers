import ContractForge
open ContractForge

-- 11.3.9i/S1: In the event of a registration procedure failing owing to the functional number already being registered to another mobile, the Cab radio shall be capable of providing the user with the ability to perform automatically the forced de-registration of the previously registered mobile and the registration of this functional number to the user's mobile.
-- compiles: False · rejects_bad_example: None · checked: False

structure FunctionalNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Mobile where
  id : Nat
  functionalNumber : Option FunctionalNumber
  deriving DecidableEq, Repr

structure Input where
  functionalNumber : FunctionalNumber
  mobiles         : List Mobile
  deriving DecidableEq, Repr

structure Output where
  success         : Bool
  deRegisteredId : Nat
  registeredId    : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumber.number ≠ 0
  post := fun i o =>
    (o.success = true ↔
      ∃ m ∈ i.mobiles, m.functionalNumber = some i.functionalNumber ∧
      ∀ m' ∈ i.mobiles, m'.functionalNumber = some i.functionalNumber → m' = m) ∧
    (o.success = false →
      ∃ m ∈ i.mobiles, m.functionalNumber = some i.functionalNumber ∧
      o.deRegisteredId = m.id ∧
      o.registeredId = i.mobiles.count (fun m => m.functionalNumber = none) + 1)

example : Spec.pre { functionalNumber := { number := 123 }, mobiles := [{ id := 1, functionalNumber := some { number := 123 } },
                                                                       { id := 2, functionalNumber := none }] } ∧
          Spec.post { functionalNumber := { number := 123 }, mobiles := [{ id := 1, functionalNumber := some { number := 123 } },
                                                                          { id := 2, functionalNumber := none }] }
                    { success := true, deRegisteredId := 1, registeredId := 2 } := by
  unfold Spec; decide
