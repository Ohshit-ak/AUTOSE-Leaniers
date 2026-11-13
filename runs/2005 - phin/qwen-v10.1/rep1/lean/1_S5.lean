import ContractForge
open ContractForge

-- 1/S5: The application should also allow for new objects to be defined and created during the course of an investigation.
-- compiles: True · rejects_bad_example: False · checked: False

structure Object where
  id    : Nat
  name  : String
  data  : String
  deriving DecidableEq, Repr

structure Input where
  objects : List Object
  deriving DecidableEq, Repr

structure Output where
  objects : List Object
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.objects.length = i.objects.length + 1 ∧
                     ∃ obj ∈ o.objects, obj.id = o.objects.length - 1 ∧
                     obj.name ≠ "" ∧ obj.data ≠ ""

example : Spec.pre { objects := [] } ∧
          Spec.post { objects := [] }
                     { objects := [{ id := 0, name := "New Object", data := "Some Data" }] } := by
  unfold Spec; decide
