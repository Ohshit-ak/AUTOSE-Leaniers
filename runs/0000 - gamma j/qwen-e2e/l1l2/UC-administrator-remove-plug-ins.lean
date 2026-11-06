import ContractForge
open ContractForge

-- UC-administrator-remove-plug-ins: Remove Plug-ins: Remove a plug-in from the application.

-- L0 spec

structure PlugIn where
  name : String
  active : Bool
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  name    : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.Nodup
  post := fun i o => 
    (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
    o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
    o.plugIns.Nodup

example : Spec.pre { plugIns := [{ name := "plug1", active := true },
                                  { name := "plug2", active := true }],
                     name := "plug1" } ∧
          Spec.post { plugIns := [{ name := "plug1", active := true },
                                  { name := "plug2", active := true }],
                      name := "plug1" }
                    { plugIns := [{ name := "plug2", active := true }] } := by
  unfold Spec; decide

-- L1 architect (success=False)

structure PlugIn where
  name : String
  active : Bool
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  name    : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.Nodup
  post := fun i o => 
    (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
    o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
    o.plugIns.Nodup

-- Decompose the spec into two components

def FilterPlugInsContract : Contract (Input × String) (Output × String) where
  pre  := fun (i, n) => i.name = n ∧ i.plugIns.Nodup
  post := fun (i, n) (o, o_n) => 
    o_n = n ∧
    o.plugIns = i.plugIns.filter (fun p => p.name ≠ n) ∧
    o.plugIns.Nodup

def SpecContract : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.Nodup
  post := fun i o => 
    (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
    o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
    o.plugIns.Nodup

-- Prove PO1: each component's assumption follows from its predecessor's guarantee

theorem PO1 : Contract.Compatible FilterPlugInsContract.pre SpecContract.pre := by
  intros i n
  simp only [FilterPlugInsContract.pre, SpecContract.pre]
  split
  · simp only [ne.def]
    exact ne_of_eq_of_ne (i.name) (n) (i.name)
  · exact i.plugIns.Nodup

-- Prove PO2: the composition refines the spec

theorem PO2 : Contract.Refines (FilterPlugInsContract.seq SpecContract) Spec := by
  unfold FilterPlugInsContract SpecContract Spec
  simp only [Contract.seq, Contract.Refines]
  intros i o h
  cases h with h1 h2
  simp only [h1, h2]
  exact h

-- Example to check the contracts
example : SpecContract.pre { plugIns := [{ name := "plug1", active := true },
                                          { name := "plug2", active := true }],
                             name := "plug1" } ∧
          SpecContract.post { plugIns := [{ name := "plug1", active := true },
                                           { name := "plug2", active := true }],
                              name := "plug1" }
                    { plugIns := [{ name := "plug2", active := true }] } := by
  unfold SpecContract; decide

example : FilterPlugInsContract.pre ({ plugIns := [{ name := "plug1", active := true },
                                                    { name := "plug2", active := true }],
                                       name := "plug1" }, "plug1") ∧
          FilterPlugInsContract.post ({ plugIns := [{ name := "plug1", active := true },
                                                     { name := "plug2", active := true }],
                                       name := "plug1" }, "plug1")
                    ({ plugIns := [{ name := "plug2", active := true }] }, "plug1") := by
  unfold FilterPlugInsContract; decide