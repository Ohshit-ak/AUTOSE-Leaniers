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

structure Mid where
  plugIns : List PlugIn
  name    : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.Nodup
  post := fun i m => 
    (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
    m.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
    m.plugIns.Nodup

def FilterContract : Contract Mid Output where
  pre  := fun m => m.plugIns.Nodup
  post := fun m o => 
    o.plugIns = m.plugIns.filter (fun p => p.name ≠ m.name) ∧
    o.plugIns.Nodup

theorem po1 : Contract.Compatible ValidateContract FilterContract := by
  unfold Contract.Compatible ValidateContract FilterContract
  intro i m _ h
  simp only [h.2.1, h.2.2]
  exact h.1

theorem po2 : Contract.Refines (ValidateContract.seq FilterContract) Spec := by
  unfold Contract.Refines Contract.seq ValidateContract FilterContract Spec
  refine ⟨fun i h => h, ?_⟩
  intro i o _ ⟨m, ⟨hp, hq, _⟩, ho⟩
  simp only at *
  rw [ho, hp, hq]
  exact m