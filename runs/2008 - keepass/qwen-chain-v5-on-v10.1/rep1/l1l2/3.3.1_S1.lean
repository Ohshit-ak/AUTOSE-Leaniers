import ContractForge
open ContractForge

-- 3.3.1/S1: When a database is opened, the user can access his passwords, organize them into new groups and subgroups, delete and add entries and so much more.

-- L0 spec

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

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { entries := x.entries.filter (fun e => e.group ≠ "" ∧ e.subgroups.Nodup) }
