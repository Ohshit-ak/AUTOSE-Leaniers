import ContractForge
open ContractForge

-- 7.3.9: 7.3.9 It shall be possible to change the battery without losing data stored in the radio. (M)
-- compiles: True · rejects_bad_example: True · checked: True

structure Battery where
  data : String
  deriving DecidableEq, Repr

structure Radio where
  battery : Battery
  data    : String
  deriving DecidableEq, Repr

structure Input where
  radio : Radio
  deriving DecidableEq, Repr

structure Output where
  radio : Radio
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.radio.data = i.radio.data ∧
                     o.radio.battery = i.radio.battery

example : Spec.pre { radio := { battery := { data := "storedData" }, data := "storedData" } } ∧
          Spec.post { radio := { battery := { data := "storedData" }, data := "storedData" } }
                    { radio := { battery := { data := "storedData" }, data := "storedData" } } := by
  unfold Spec; decide
