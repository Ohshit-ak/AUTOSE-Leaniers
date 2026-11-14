import ContractForge
open ContractForge

-- 9.2.2.2: 9.2.2.2 Every on-train function shall be identified by a unique standard number. (M)
-- compiles: True · rejects_bad_example: None · checked: True

structure Function where
  number : Nat
  name   : String
  deriving DecidableEq, Repr

structure Input where
  functions : List Function
  deriving DecidableEq, Repr

structure Output where
  functions : List Function
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functions.Nodup ∧ i.functions.all (fun f => 0 < f.number)
  post := fun i o => o.functions = i.functions.filter (fun f => 0 < f.number)

example : Spec.pre { functions := [{ number := 1, name := "Function1" },
                                    { number := 2, name := "Function2" }] } ∧
          Spec.post { functions := [{ number := 1, name := "Function1" },
                                     { number := 2, name := "Function2" }] }
                    { functions := [{ number := 1, name := "Function1" },
                                    { number := 2, name := "Function2" }] } := by
  unfold Spec; decide
