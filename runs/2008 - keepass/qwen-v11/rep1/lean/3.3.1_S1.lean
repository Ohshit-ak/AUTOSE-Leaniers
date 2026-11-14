import ContractForge
open ContractForge

-- 3.3.1/S1: When a database is opened, the user can access his passwords, organize them into new groups and subgroups, delete and add entries and so much more.
-- compiles: True · rejects_bad_example: None · checked: True

structure Entry where
  name   : String
  password: String
  group  : String
  subgroups : List String
  deriving DecidableEq, Repr

structure Group where
  name : String
  subgroups : List String
  deriving DecidableEq, Repr

structure Input where
  entries : List Entry
  groups  : List Group
  deriving DecidableEq, Repr

structure Output where
  entries : List Entry
  groups  : List Group
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.entries.Nodup ∧ i.groups.Nodup
  post := fun i o => o.entries = i.entries ∧
                     o.groups = i.groups ∧
                     (o.entries.length = i.entries.length ∧
                      o.groups.length = i.groups.length)

example : Spec.pre { entries := [{ name := "a", password := "p1", group := "g1", subgroups := [] },
                                  { name := "b", password := "p2", group := "g2", subgroups := [] }],
                     groups := [{ name := "g1", subgroups := [] },
                                { name := "g2", subgroups := [] }] } ∧
          Spec.post { entries := [{ name := "a", password := "p1", group := "g1", subgroups := [] },
                                   { name := "b", password := "p2", group := "g2", subgroups := [] }],
                      groups := [{ name := "g1", subgroups := [] },
                                 { name := "g2", subgroups := [] }] }
                    { entries := [{ name := "a", password := "p1", group := "g1", subgroups := [] },
                                  { name := "b", password := "p2", group := "g2", subgroups := [] }],
                      groups := [{ name := "g1", subgroups := [] },
                                 { name := "g2", subgroups := [] }] } := by
  unfold Spec; decide
