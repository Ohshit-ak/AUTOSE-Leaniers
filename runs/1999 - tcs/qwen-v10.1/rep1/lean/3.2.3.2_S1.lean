import ContractForge
open ContractForge

-- 3.2.3.2/S1: The TCS shall display live and recorded imagery data, with as well as without annotation and overlay, upon operator request. [SSS195] Annotation includes operator generated comments as well as graphics which are superimposed on the imagery.
-- compiles: False · rejects_bad_example: None · checked: False

structure ImageryData where
  live : Bool
  annotation : Option String
  overlay : Option String
  deriving DecidableEq, Repr

structure Input where
  imagery : ImageryData
  annotation : Option String
  overlay : Option String
  deriving DecidableEq, Repr

structure Output where
  displayed : ImageryData
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.imagery.live ∨ i.imagery.annotation.isSome ∨ i.imagery.overlay.isSome
  post := fun i o => o.displayed.live = i.imagery.live ∧
                     o.displayed.annotation = i.imagery.annotation ∨ i.annotation ∨ o.displayed.annotation.isNone ∧
                     o.displayed.overlay = i.imagery.overlay ∨ i.overlay ∨ o.displayed.overlay.isNone

example : Spec.pre { imagery := { live := true, annotation := none, overlay := none },
                     annotation := some "Comment", overlay := some "Overlay" } ∧
          Spec.post { imagery := { live := true, annotation := none, overlay := none },
                      annotation := some "Comment", overlay := some "Overlay" }
                    { displayed := { live := true, annotation := some "Comment", overlay := some "Overlay" } } := by
  unfold Spec; decide
