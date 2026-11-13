import ContractForge
open ContractForge

-- 3.3.1.4/S2: The TCS shall provide an interface between the TCS and external data storage systems. [SSS317] The TCS shall have the functionality to transfer digital data as well as digital imagery to and from external data storage systems. [SSS318] Details of the Tactical Control System (TCS) to external data storage interface will be defined in the TCS to External Data Storage IDD, TCS256.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  data : List String
  imagery : List String
  deriving DecidableEq, Repr

structure Output where
  transferred : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ [] ∨ i.imagery ≠ []
  post := fun i o => o.transferred = true ↔
    (i.data ≠ [] → ∃ d ∈ i.data, d ∈ o.transferredData) ∧
    (i.imagery ≠ [] → ∃ i ∈ i.imagery, i ∈ o.transferredImagery)

example : Spec.pre { data := ["data1", "data2"], imagery := ["img1", "img2"] } ∧
          Spec.post { data := ["data1", "data2"], imagery := ["img1", "img2"] }
                    { transferred := true, transferredData := ["data1", "data2"], transferredImagery := ["img1", "img2"] } := by
  unfold Spec; decide
