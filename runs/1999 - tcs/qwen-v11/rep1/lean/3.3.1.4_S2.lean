import ContractForge
open ContractForge

-- 3.3.1.4/S2: The TCS shall provide an interface between the TCS and external data storage systems. [SSS317] The TCS shall have the functionality to transfer digital data as well as digital imagery to and from external data storage systems. [SSS318] Details of the Tactical Control System (TCS) to external data storage interface will be defined in the TCS to External Data Storage IDD, TCS256.
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  data : List String
  deriving DecidableEq, Repr

structure Output where
  transferred : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ []
  post := fun i o => o.transferred = true ↔
    (i.data.length = 0 → o.transferred = false) ∧
    (i.data.length > 0 →
      ∃ transferredData ∈ i.data, transferredData ∈ i.data ∧
      (transferredData = "digital data" ∨ transferredData = "digital imagery"))

example : Spec.pre { data := ["digital data", "digital imagery"] } ∧
          Spec.post { data := ["digital data", "digital imagery"] }
                    { transferred := true } := by
  unfold Spec; decide
