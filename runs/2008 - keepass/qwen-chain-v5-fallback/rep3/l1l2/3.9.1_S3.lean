import ContractForge
open ContractForge

-- 3.9.1/S3: After that a menu of options to choose from appears and the user can select to search for: title, user name, password, URL, notes, group name.

-- L0 spec

structure Input where
  title     : Option String
  username  : Option String
  password  : Option String
  url      : Option String
  notes    : Option String
  groupName : Option String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => 
    (∀ r ∈ o.results, 
      (i.title.isSome → r = "title") ∧
      (i.username.isSome → r = "username") ∧
      (i.password.isSome → r = "password") ∧
      (i.url.isSome → r = "url") ∧
      (i.notes.isSome → r = "notes") ∧
      (i.groupName.isSome → r = "group name")) ∧
    (o.results = [] ↔ i.title.isNone ∧ i.username.isNone ∧ i.password.isNone ∧ i.url.isNone ∧ i.notes.isNone ∧ i.groupName.isNone)

example : Spec.pre { title := none, username := none, password := none, url := none, notes := none, groupName := none } ∧
          Spec.post { title := none, username := none, password := none, url := none, notes := none, groupName := none }
                    { results := [] } := by
  unfold Spec; decide

example : Spec.pre { title := some "title", username := none, password := none, url := none, notes := none, groupName := none } ∧
          Spec.post { title := some "title", username := none, password := none, url := none, notes := none, groupName := none }
                    { results := ["title"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := if x.title.isNone ∧ x.username.isNone ∧ x.password.isNone ∧ x.url.isNone ∧ x.notes.isNone ∧ x.groupName.isNone then [] else
      let results := List.filter (fun r => 
        (r = "title" ∧ x.title.isSome) ∨
        (r = "username" ∧ x.username.isSome) ∨
        (r = "password" ∧ x.password.isSome) ∨
        (r = "url" ∧ x.url.isSome) ∨
        (r = "notes" ∧ x.notes.isSome) ∨
        (r = "group name" ∧ x.groupName.isSome)) ["title", "username", "password", "url", "notes", "group name"]
      in results }
