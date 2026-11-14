import ContractForge
open ContractForge

-- 3.2.3.2/S1: The TCS shall display live and recorded imagery data, with as well as without annotation and overlay, upon operator request. [SSS195] Annotation includes operator generated comments as well as graphics which are superimposed on the imagery.

-- L0 spec

structure ImageryData where
  live  : Bool
  image : String
  annotation : Option String
  deriving DecidableEq, Repr

structure Input where
  imageryData : ImageryData
  annotation  : Option String
  overlay     : Option String
  deriving DecidableEq, Repr

structure Output where
  imageryData : ImageryData
  annotation  : Option String
  overlay     : Option String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.imageryData.live ∨ i.imageryData.image ≠ ""
  post := fun i o => (o.imageryData.live = i.imageryData.live ∧
                      o.imageryData.image = i.imageryData.image ∧
                      o.annotation = i.annotation ∨
                      (o.annotation = none ∧ i.annotation = some "")
                     ) ∧
                     (o.overlay = i.overlay ∨
                      (o.overlay = none ∧ i.overlay = some "")
                     ) ∧
                     (o.imageryData.live = true → o.annotation = i.annotation) ∧
                     (o.imageryData.live = false → o.annotation = none) ∧
                     (o.imageryData.live = true → o.overlay = i.overlay) ∧
                     (o.imageryData.live = false → o.overlay = none)

example : Spec.pre { imageryData := { live := true, image := "img1", annotation := none },
                     annotation := some "comment", overlay := some "overlay1" } ∧
          Spec.post { imageryData := { live := true, image := "img1", annotation := none },
                      annotation := some "comment", overlay := some "overlay1" }
                    { imageryData := { live := true, image := "img1", annotation := none },
                      annotation := some "comment", overlay := some "overlay1" } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=False)

structure Mid where
  annotation : Option String
  imageryData : ImageryData
  overlay : Option String
  deriving DecidableEq, Repr

def ComputeAnnotationContract : Contract Input Mid where
  pre  := fun i => i.imageryData.live ∨ i.imageryData.image ≠ ""
  post := fun i m => (m.annotation = i.annotation ∨ (m.annotation = none ∧ i.annotation = some "") ∧
                     (m.imageryData.live = true → m.annotation = i.annotation) ∧
                     (m.imageryData.live = false → m.annotation = none)) ∧ m.imageryData = i.imageryData ∧ m.overlay = i.overlay

def ApplyAnnotationContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => o.imageryData.live = m.imageryData.live ∧
                     o.imageryData.image = m.imageryData.image ∧
                     o.annotation = m.annotation ∨ (o.annotation = none ∧ m.annotation = some "") ∧
                     o.overlay = m.overlay ∨ (o.overlay = none ∧ m.overlay = some "")


