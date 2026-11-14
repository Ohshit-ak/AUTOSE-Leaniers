import ContractForge
open ContractForge

-- 3.2.1.1.1/S2: A de-clutter capability shall be provided that allows the operator to display only a selected number of the most significant threats. [SSS063] The TCS shall provide the capability to modify the maximum number of threats displayed, when de-clutter is selected. [SSS064] The TCS shall provide the capability to display waypoint data in alphanumeric format. [SSS552] The TCS shall have the capability to load a map onto the display, to zoom in and out, to scroll, to print, and to clear a map on the map display. [SSS095] The TCS shall provide the operator with a clearly indicated map scale. [SSS535] Upon operator request, the following icons shall be displayed on the map display (when the coordinates reside on the displayed portion of the map).
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  maxThreats  : Nat
  threats     : List String
  waypoints   : List String
  mapData     : List String
  zoomLevel   : Nat
  scrollPos   : Nat
  mapScale    : String
  icons       : List String
  deriving DecidableEq, Repr

structure Output where
  threats     : List String
  waypoints   : List String
  mapData     : List String
  zoomLevel   : Nat
  scrollPos   : Nat
  mapScale    : String
  icons       : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.threats.Nodup ∧
                   i.icons.Nodup
  post := fun i o =>
    (o.threats = i.threats.filter (fun t => t ∈ i.threats.take i.maxThreats)) ∧
    (o.waypoints = i.waypoints) ∧
    (o.mapData = i.mapData) ∧
    (o.zoomLevel = i.zoomLevel) ∧
    (o.scrollPos = i.scrollPos) ∧
    (o.mapScale = i.mapScale) ∧
    (o.icons = i.icons)

example : Spec.pre { maxThreats := 5,
                     threats := ["Threat1", "Threat2", "Threat3", "Threat4", "Threat5", "Threat6"],
                     waypoints := ["WaypointA", "WaypointB"],
                     mapData := ["MapData1", "MapData2"],
                     zoomLevel := 10,
                     scrollPos := 5,
                     mapScale := "1:10000",
                     icons := ["Icon1", "Icon2", "Icon3"] } ∧
          Spec.post { maxThreats := 5,
                      threats := ["Threat1", "Threat2", "Threat3", "Threat4", "Threat5"],
                      waypoints := ["WaypointA", "WaypointB"],
                      mapData := ["MapData1", "MapData2"],
                      zoomLevel := 10,
                      scrollPos := 5,
                      mapScale := "1:10000",
                      icons := ["Icon1", "Icon2", "Icon3"] }
                    { threats := ["Threat1", "Threat2", "Threat3", "Threat4", "Threat5"],
                      waypoints := ["WaypointA", "WaypointB"],
                      mapData := ["MapData1", "MapData2"],
                      zoomLevel := 10,
                      scrollPos := 5,
                      mapScale := "1:10000",
                      icons := ["Icon1", "Icon2", "Icon3"] } := by
  unfold Spec; decide
