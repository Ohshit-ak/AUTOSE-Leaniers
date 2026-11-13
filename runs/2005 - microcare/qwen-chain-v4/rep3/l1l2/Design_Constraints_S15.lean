import ContractForge
open ContractForge

-- Design Constraints/S15: The allowed users only can able to Add, Modify or delete the VSP master information including payment terms.

-- L0 spec

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
                      (o.action = "Add" → o.vsp.isSome ∧ o.vsp.getD { name := "", terms := "" } ≠ i.vsp.getD { name := "", terms := "" }) ∧
                      (o.action = "Modify" → o.vsp = i.vsp ∨ o.vsp.getD { name := "", terms := "" } ≠ i.vsp.getD { name := "", terms := "" }) ∧
                      (o.action = "Delete" → o.vsp = none))

example : Spec.pre { vsp := none, action := "Add" } ∧
          Spec.post { vsp := none, action := "Add" }
                    { vsp := some { name := "VSP1", terms := "30 days" }, action := "Add" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  vsp     : Option VSP
  deriving DecidableEq, Repr

def ComputeVSPContract : Contract Input Mid where
  pre  := fun i => i.action ∈ ["Add", "Modify", "Delete"]
  post := fun i m => m.vsp = i.vsp ∨
                     (i.action = "Add" → m.vsp.isSome ∧ m.vsp.getD { name := "", terms := "" } ≠ i.vsp.getD { name := "", terms := "" }) ∧
                     (i.action = "Modify" → m.vsp = i.vsp ∨ m.vsp.getD { name := "", terms := "" } ≠ i.vsp.getD { name := "", terms := "" }) ∧
                     (i.action = "Delete" → m.vsp = none)

def ApplyActionContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.action = m.action) ∧
                     (o.vsp = m.vsp)
