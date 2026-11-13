import ContractForge
open ContractForge

-- 3.2.1.1.1/S2: A de-clutter capability shall be provided that allows the operator to display only a selected number of the most significant threats. [SSS063] The TCS shall provide the capability to modify the maximum number of threats displayed, when de-clutter is selected. [SSS064] The TCS shall provide the capability to display waypoint data in alphanumeric format. [SSS552] The TCS shall have the capability to load a map onto the display, to zoom in and out, to scroll, to print, and to clear a map on the map display. [SSS095] The TCS shall provide the operator with a clearly indicated map scale. [SSS535] Upon operator request, the following icons shall be displayed on the map display (when the coordinates reside on the displayed portion of the map).

-- L0 spec

structure Input where
  maxThreats : Nat
  deClutter  : Bool
  waypointData : String
  mapData    : String
  zoomLevel  : Nat
  scrollX    : Nat
  scrollY    : Nat
  print      : Bool
  clear      : Bool
  scale      : String
  coordinates : List String
  deriving DecidableEq, Repr

structure Output where
  maxThreats : Nat
  deClutter  : Bool
  waypointData : String
  mapData    : String
  zoomLevel  : Nat
  scrollX    : Nat
  scrollY    : Nat
  print      : Bool
  clear      : Bool
  scale      : String
  icons      : List String
  coordinates : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.deClutter = true ∧ i.maxThreats > 0
  post := fun i o => (o.maxThreats = i.maxThreats) ∧
                     (o.deClutter = i.deClutter) ∧
                     (o.waypointData = i.waypointData) ∧
                     (o.mapData = i.mapData) ∧
                     (o.zoomLevel = i.zoomLevel) ∧
                     (o.scrollX = i.scrollX) ∧
                     (o.scrollY = i.scrollY) ∧
                     (o.print = i.print) ∧
                     (o.clear = i.clear) ∧
                     (o.scale = i.scale) ∧
                     (o.icons.length ≤ i.maxThreats) ∧
                     (∀ ic ∈ o.icons, ic ∈ i.coordinates) ∧
                     (List.Pairwise (fun a b => a.length ≤ b.length) o.icons)

example : Spec.pre { maxThreats := 5, deClutter := true, waypointData := "W1", mapData := "M1", zoomLevel := 10, scrollX := 0, scrollY := 0, print := false, clear := false, scale := "1:10000", coordinates := ["C1", "C2", "C3", "C4", "C5"] } ∧
          Spec.post { maxThreats := 5, deClutter := true, waypointData := "W1", mapData := "M1", zoomLevel := 10, scrollX := 0, scrollY := 0, print := false, clear := false, scale := "1:10000", coordinates := ["C1", "C2", "C3", "C4", "C5"] }
                    { maxThreats := 5, deClutter := true, waypointData := "W1", mapData := "M1", zoomLevel := 10, scrollX := 0, scrollY := 0, print := false, clear := false, scale := "1:10000", icons := ["C1", "C2", "C3"], coordinates := ["C1", "C2", "C3", "C4", "C5"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { maxThreats := x.maxThreats,
    deClutter := x.deClutter,
    waypointData := x.waypointData,
    mapData := x.mapData,
    zoomLevel := x.zoomLevel,
    scrollX := x.scrollX,
    scrollY := x.scrollY,
    print := x.print,
    clear := x.clear,
    scale := x.scale,
    icons := x.coordinates.take x.maxThreats,
    coordinates := x.coordinates }
