import ContractForge
open ContractForge

-- Design Constraints/S15: The allowed users only can able to Add, Modify or delete the VSP master information including payment terms.
-- compiles: False · rejects_bad_example: None · checked: False

structure VSP where
  name    : String
  terms   : String
  deriving DecidableEq, Repr

structure Input where
  vsp     : Option VSP
  action  : String
  deriving DecidableEq, Repr

structure Output where
  vsp     : Option VSP
  action  : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.action ∈ ["Add", "Modify", "Delete"]
  post := fun i o => (o.action = i.action) ∧
                     (o.vsp = i.vsp ∨
                      (o.action = "Add" → o.vsp.isSome ∧ o.vsp.getD none.name = i.vsp.getD none.name) ∧
                      (o.action = "Modify" → o.vsp.isSome ∧ o.vsp.getD none.terms = i.vsp.getD none.terms) ∧
                      (o.action = "Delete" → o.vsp = none))

example : Spec.pre { vsp := none, action := "Add" } ∧
          Spec.post { vsp := none, action := "Add" }
                    { vsp := some { name := "New VSP", terms := "30 days" }, action := "Add" } := by
  unfold Spec; decide
