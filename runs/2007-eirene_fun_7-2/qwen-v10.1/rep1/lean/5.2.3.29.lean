import ContractForge
open ContractForge

-- 5.2.3.29: 5.2.3.29 The driver shall be warned (by audible and visual indications) if a train with the same train number is already registered on the same network. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Train where
  number : String
  network : String
  deriving DecidableEq, Repr

structure Input where
  number   : String
  trains   : List Train
  network  : String
  deriving DecidableEq, Repr

structure Output where
  warned   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.number ≠ ""
  post := fun i o => o.warned = true ↔
    ∃ t ∈ i.trains, t.number = i.number ∧ t.network = i.network

example : Spec.pre { number := "12345", trains := [{ number := "12345", network := "network1" }],
                     network := "network1" } ∧
          Spec.post { number := "12345", trains := [{ number := "12345", network := "network1" }],
                      network := "network1" }
                    { warned := true } := by
  unfold Spec; decide
