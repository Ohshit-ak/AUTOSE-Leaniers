import ContractForge
open ContractForge

-- 1.2/S8: An Economic Operator can use means such as the TED system, existing tendering platforms or official national gazettes to search for contract notices (2) and to retrieve the relevant information about active tenders (3).
-- compiles: False · rejects_bad_example: None · checked: False

structure ContractNotice where
  title   : String
  details : String
  deriving DecidableEq, Repr

structure Input where
  query          : String
  sources        : List String
  activeTenders  : List ContractNotice
  deriving DecidableEq, Repr

structure Output where
  results        : List ContractNotice
  message        : String
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query and is an active tender
def Wanted (i : Input) (cn : ContractNotice) : Bool :=
  cn.title.contains i.query || cn.details.contains i.query && cn in i.activeTenders

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ "" ∧ i.sources.Nodup
  post := fun i o =>
    (∀ cn ∈ o.results, cn ∈ i.activeTenders ∧ Wanted i cn = true) ∧
    (o.results.length < 100 → ∀ cn ∈ i.activeTenders, Wanted i cn = true → cn ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.title.length ≤ b.title.length) o.results ∧
    (o.message = "No results were found." ↔ o.results = [])

example : Spec.pre { query := "construction", sources := ["TED", "platform1"], activeTenders := [{ title := "Construction project", details := "Details about construction" }, { title := "Other project", details := "Details about other" }] } ∧
          Spec.post { query := "construction", sources := ["TED", "platform1"], activeTenders := [{ title := "Construction project", details := "Details about construction" }, { title := "Other project", details := "Details about other" }] }
                    { results := [{ title := "Construction project", details := "Details about construction" }], message := "" } := by
  unfold Spec; decide
