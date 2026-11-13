import ContractForge
open ContractForge

-- 13.5.10i/S1: Confirmation centres shall be capable of decoding messages in either format A or B.

-- L0 spec

structure Input where
  message : String
  format  : String
  deriving DecidableEq, Repr

structure Output where
  decoded : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.format = "A" ∨ i.format = "B"
  post := fun i o => o.decoded = if i.format = "A" then "Decoded format A" else "Decoded format B"

example : Spec.pre { message := "", format := "A" } ∧
          Spec.post { message := "", format := "A" }
                    { decoded := "Decoded format A" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { decoded := if x.format = "A" then "Decoded format A" else "Decoded format B" }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
