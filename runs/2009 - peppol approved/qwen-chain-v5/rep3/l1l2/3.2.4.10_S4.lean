import ContractForge
open ContractForge

-- 3.2.4.10/S4: As it is quite complex to establish a common and unique classification scheme cross-border and cross-sector, business document instances should be carry metadata about classification schemes they use."

-- L0 spec

structure ClassificationScheme where
  id : Nat
  name : String
  deriving DecidableEq, Repr

structure Input where
  document : String
  schemesUsed : List ClassificationScheme
  deriving DecidableEq, Repr

structure Output where
  document : String
  schemesUsed : List ClassificationScheme
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.document ≠ ""
  post := fun i o => o.document = i.document ∧
                     o.schemesUsed.Nodup ∧
                     (∀ s ∈ o.schemesUsed, ∃ s' ∈ i.schemesUsed, s.id = s'.id ∧ s.name = s'.name) ∧
                     (o.document = i.document → o.schemesUsed = i.schemesUsed) ∧
                     (o.document = i.document ∧ o.schemesUsed ≠ i.schemesUsed → o.schemesUsed.Nodup)

example : Spec.pre { document := "Sample document", schemesUsed := [{ id := 1, name := "Scheme A" }] } ∧ Spec.post { document := "Sample document", schemesUsed := [{ id := 1, name := "Scheme A" }] } { document := "Sample document", schemesUsed := [{ id := 1, name := "Scheme A" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  document : String
  schemesUsed : List ClassificationScheme
  deriving DecidableEq, Repr

def ComputeSchemesContract : Contract Input Mid where
  pre  := fun i => i.document ≠ ""
  post := fun i m => m.document = i.document ∧
                     m.schemesUsed.Nodup ∧
                     (∀ s ∈ m.schemesUsed, ∃ s' ∈ i.schemesUsed, s.id = s'.id ∧ s.name = s'.name)

def ApplySchemesContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.document = m.document ∧
                     o.schemesUsed.Nodup ∧
                     (∀ s ∈ o.schemesUsed, ∃ s' ∈ m.schemesUsed, s.id = s'.id ∧ s.name = s'.name) ∧
                     (o.document = m.document → o.schemesUsed = m.schemesUsed) ∧
                     (o.document = m.document ∧ o.schemesUsed ≠ m.schemesUsed → o.schemesUsed.Nodup)
