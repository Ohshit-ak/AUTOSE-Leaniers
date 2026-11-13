import ContractForge
open ContractForge

-- 3.9.1/S3: After that a menu of options to choose from appears and the user can select to search for: title, user name, password, URL, notes, group name.
-- compiles: True · rejects_bad_example: True · checked: True

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
  message : String
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
    o.results.length ≤ 6 ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { title := some "title", username := none, password := none, url := none, notes := none, groupName := none } ∧
          Spec.post { title := some "title", username := none, password := none, url := none, notes := none, groupName := none }
                    { results := ["title"], message := "" } := by
  unfold Spec; decide
