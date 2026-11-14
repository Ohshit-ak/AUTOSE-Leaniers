import ContractForge
open ContractForge

-- 11.6.3/S2: The signalling system suite shall include the Mobile Application Part (MAP).

-- L0 spec

structure Input where
  deriving DecidableEq, Repr

structure Output where
  includesMAP : Bool
  deriving DecidableEq, Repr

-- IMPL: Inter EIRENE network interfacing

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun _ o => o.includesMAP = true

example : Spec.pre {} ∧ Spec.post {} { includesMAP := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { includesMAP := true }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
