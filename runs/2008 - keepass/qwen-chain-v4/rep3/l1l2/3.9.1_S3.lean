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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  found : List String
  deriving DecidableEq, Repr

def ComputeFoundContract : Contract Input Mid where
  pre  := fun _ => True
  post := fun i m => 
    (∀ r ∈ m.found, 
      (i.title.isSome → r = "title") ∧
      (i.username.isSome → r = "username") ∧
      (i.password.isSome → r = "password") ∧
      (i.url.isSome → r = "url") ∧
      (i.notes.isSome → r = "notes") ∧
      (i.groupName.isSome → r = "group name"))

def ShowResultsContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => 
    (∀ r ∈ o.results, r ∈ m.found) ∧
    o.results.length ≤ 6 ∧
    (o.message = "No results were found." ↔ o.results = [])

theorem po1 : Contract.Compatible ComputeFoundContract ShowResultsContract := by
  discharge_po1 [ComputeFoundContract, ShowResultsContract, Spec]

theorem po2 : Contract.Refines (ComputeFoundContract.seq ShowResultsContract) Spec := by
  discharge_po2 [ComputeFoundContract, ShowResultsContract, Spec]

-- L2 ComputeFoundContract (success=False)

def ComputeFoundContractImpl (x : Input) : Mid :=
  { found := 
    if x.title.isSome then ["title"]
    else if x.username.isSome then ["username"]
    else if x.password.isSome then ["password"]
    else if x.url.isSome then ["url"]
    else if x.notes.isSome then ["notes"]
    else if x.groupName.isSome then ["group name"]
    else [] }

-- L2 ShowResultsContract (success=True)

def ShowResultsContractImpl (x : Mid) : Output :=
  { results := x.found.take 6, message := if x.found.length = 0 then "No results were found." else "" }

theorem ShowResultsContractImpl_ok : ShowResultsContract.Satisfies ShowResultsContractImpl := by
  discharge_po3 [ShowResultsContract, ShowResultsContractImpl]
