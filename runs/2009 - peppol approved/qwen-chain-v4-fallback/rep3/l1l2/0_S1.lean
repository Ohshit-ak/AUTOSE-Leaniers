import ContractForge
open ContractForge

-- 0/S1: This preface provides a short overview about the comments received from the EC and other sources and how these comments and remarks will be taken into consideration in future/ongoing work.

-- L0 spec

structure Input where
  commentsReceived : List String
  deriving DecidableEq, Repr

structure Output where
  remarksConsidered : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.commentsReceived ≠ []
  post := fun i o => o.remarksConsidered = i.commentsReceived

example : Spec.pre { commentsReceived := ["EC comment 1", "EC comment 2"] } ∧
          Spec.post { commentsReceived := ["EC comment 1", "EC comment 2"] }
                    { remarksConsidered := ["EC comment 1", "EC comment 2"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { remarksConsidered := x.commentsReceived }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
