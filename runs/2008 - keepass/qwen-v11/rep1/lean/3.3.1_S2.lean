import ContractForge
open ContractForge

-- 3.3.1/S2: But when it is time for the database to close or during his working on the database, he can save the changes made.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  changes : List String
  saving  : Bool
  deriving DecidableEq, Repr

structure Output where
  saved   : Bool
  changes : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.saving
  post := fun i o => (o.saved = true ↔ i.saving) ∧
                     (o.changes = i.changes)

example : Spec.pre { changes := ["change1", "change2"], saving := true } ∧
          Spec.post { changes := ["change1", "change2"], saving := true }
                    { saved := true, changes := ["change1", "change2"] } := by
  unfold Spec; decide

-- IMPL: Save changes when saving is true
def saveDatabase (i : Input) : Output :=
  { saved := i.saving, changes := i.changes }
