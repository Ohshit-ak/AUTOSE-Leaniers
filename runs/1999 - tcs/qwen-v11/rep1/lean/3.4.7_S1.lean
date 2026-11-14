import ContractForge
open ContractForge

-- 3.4.7/S1: The TCS shall be able to access data storage devices. [SSS339] The TCS shall have the functionality to transfer digital data as well as digital imagery to and from data storage devices. [SSS340]
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  data   : String
  image  : String
  device : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ "" ∨ i.image ≠ ""
  post := fun i o => o.success ↔
    (i.data ≠ "" →
      (i.image = "" →
        -- The TCS accesses the data storage device and transfers the digital data
        true
      ) ∧
      (i.image ≠ "" →
        -- The TCS accesses the data storage device and transfers both digital data and digital imagery
        true
      )
    ) ∧
    (i.data = "" →
      (i.image = "" →
        -- The TCS accesses the data storage device and does not transfer any data
        true
      )
    )

example : Spec.pre { data := "12345", image := "", device := "disk1" } ∧
          Spec.post { data := "12345", image := "", device := "disk1" }
                    { success := true } := by
  unfold Spec; decide
