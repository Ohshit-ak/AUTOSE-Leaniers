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

-- L1 architecture (mode=chain, success=True)

structure Mid where
  annotation : Option String
  imageryData : ImageryData
  overlay : Option String
  deriving DecidableEq, Repr

def ComputeAnnotationContract : Contract Input Mid where
  pre  := fun i => i.imageryData.live ∨ i.imageryData.image ≠ ""
  post := fun i m => ((m.annotation = i.annotation ∨
                       (m.annotation = none ∧ i.annotation = some ""))
                      ∧
                      (i.imageryData.live = true → m.annotation = i.annotation) ∧
                      (i.imageryData.live = false → m.annotation = none)) ∧
                     m.imageryData = i.imageryData ∧
                     m.overlay = i.overlay

def ApplyAnnotationContract : Contract Mid Output where
  pre  := fun m => m.imageryData.live ∨ m.imageryData.image ≠ ""
  post := fun m o => (o.imageryData.live = m.imageryData.live) ∧
                     (o.imageryData.image = m.imageryData.image) ∧
                     (o.annotation = m.annotation) ∧
                     (o.overlay = m.overlay ∨
                      (o.overlay = none ∧ m.overlay = some "")) ∧
                     (m.imageryData.live = true → o.overlay = m.overlay) ∧
                     (m.imageryData.live = false → o.overlay = none)

theorem po1 : Contract.Compatible ComputeAnnotationContract ApplyAnnotationContract := by
  discharge_po1 [ComputeAnnotationContract, ApplyAnnotationContract, Spec]

theorem po2 : Contract.Refines (ComputeAnnotationContract.seq ApplyAnnotationContract) Spec := by
  discharge_po2 [ComputeAnnotationContract, ApplyAnnotationContract, Spec]

-- L2 ComputeAnnotationContract (success=False)

def ComputeAnnotationContractImpl (x : Input) : Mid :=
  { annotation := if x.imageryData.live = true then x.annotation else if x.imageryData.live = false then none else if x.annotation = some "" then none else x.annotation,
    imageryData := x.imageryData,
    overlay := x.overlay }

-- L2 ApplyAnnotationContract (success=False)

def ApplyAnnotationContractImpl (x : Mid) : Output :=
  { imageryData := x.imageryData,
    annotation := x.annotation,
    overlay := if x.imageryData.live = true then x.overlay else if x.imageryData.live = false then none else none }
