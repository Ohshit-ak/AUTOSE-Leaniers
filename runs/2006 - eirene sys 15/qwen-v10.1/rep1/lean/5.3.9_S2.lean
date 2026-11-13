import ContractForge
open ContractForge

-- 5.3.9/S2: Each of the other cabs on the train will be contacted using its functional number (registered by the other drivers prior to the establishment of the call).
-- compiles: True · rejects_bad_example: True · checked: True

structure FunctionalNumber where
  number : Nat
  deriving DecidableEq, Repr

structure Input where
  functionalNumbers : List FunctionalNumber
  deriving DecidableEq, Repr

structure Output where
  contacted : List FunctionalNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.functionalNumbers.Nodup
  post := fun i o => o.contacted = i.functionalNumbers ∧
                     o.contacted.length = i.functionalNumbers.length

example : Spec.pre { functionalNumbers := [{ number := 1 }, { number := 2 }] } ∧
          Spec.post { functionalNumbers := [{ number := 1 }, { number := 2 }] }
                    { contacted := [{ number := 1 }, { number := 2 }] } := by
  unfold Spec; decide
