import ContractForge
open ContractForge

-- 5.2.3.29: 5.2.3.29 The driver shall be warned (by audible and visual indications) if a train with the same train number is already registered on the same network. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Train where
  number : String
  deriving DecidableEq, Repr

structure Network where
  trains : List Train
  deriving DecidableEq, Repr

structure Input where
  trainNumber : String
  network     : Network
  deriving DecidableEq, Repr

structure Output where
  warned : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.trainNumber ≠ ""
  post := fun i o => o.warned = true ↔
    ∃ t ∈ i.network.trains, t.number = i.trainNumber

example : Spec.pre { trainNumber := "12345", network := { trains := [] } } ∧
          Spec.post { trainNumber := "12345", network := { trains := [] } }
                    { warned := false } := by
  unfold Spec; decide
