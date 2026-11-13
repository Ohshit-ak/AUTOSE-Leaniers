import ContractForge
open ContractForge

-- 3.3.1/S1: When a database is opened, the user can access his passwords, organize them into new groups and subgroups, delete and add entries and so much more.
-- compiles: True · rejects_bad_example: None · checked: True

structure Entry where
  name   : String
  group  : String
  subgroups : List String
  deriving DecidableEq, Repr

structure Input where
  entries : List Entry
  deriving DecidableEq, Repr

structure Output where
  entries : List Entry
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.entries.Nodup
  post := fun i o => o.entries = i.entries ∧
                     (∀ e ∈ o.entries, e.group ≠ "" ∧ e.subgroups.Nodup)

example : Spec.pre { entries := [{ name := "password1", group := "Finance", subgroups := ["Credit Cards"] },
                                  { name := "password2", group := "Finance", subgroups := ["Banking"] }] } ∧
          Spec.post { entries := [{ name := "password1", group := "Finance", subgroups := ["Credit Cards"] },
                                   { name := "password2", group := "Finance", subgroups := ["Banking"] }] }
                    { entries := [{ name := "password1", group := "Finance", subgroups := ["Credit Cards"] },
                                  { name := "password2", group := "Finance", subgroups := ["Banking"] }] } := by
  unfold Spec; decide
