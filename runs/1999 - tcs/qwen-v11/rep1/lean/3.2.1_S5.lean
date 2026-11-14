import ContractForge
open ContractForge

-- 3.2.1/S5: As an objective, the TCS shall have the capability to import as well as create and modify map display overlays for fire support coordination measures [SSS547], airspace control measures [SSS548], and threat identification measures. [SSS060] Upon completion of radar cross section analysis and characterization by the Government for each UAV type, TCS shall utilize a UAV signature versus threat lookup table (database) that identities the lethality of the threat to the UAV [SSS065], and shall provide the capability of displaying aircraft signature versus threat, before and during flight. [SSS066] The TCS shall permit dynamic mission and payload retasking during all phases of operational mission execution. [SSS067] The TCS shall allow the operator to enter as well as review mission plan parameters, including AV flight parameters, payload control parameters, data link control parameters, AV VCR control parameters (if applicable to the selected AV), and AV loiter patterns. [SSS068] The TCS shall provide the capability to enter system configuration characteristics in the mission plan, to include selected AV type, AV identification number, selected payload type, ground control authorization information, and required communications pre-set for data links, tactical communications, and C4I data dissemination. [SSS069] The TCS shall provide the system functionality necessary to upload a flight route plan and payload plan (if applicable) to the AV via the selected system data link as well as direct ground connection. [SSS070] TCS shall provide the capability for the operator to retrieve a mission plan for viewing, modification, as well as deletion at the operator's discretion [SSS071], and allow the operator to save the mission plan under a different name, for future retrieval [SSS072].
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  missionPlanParams : String
  avType            : String
  avId              : String
  payloadType       : String
  gcaInfo           : String
  commPreSet        : String
  flightRoutePlan   : String
  payloadPlan       : String
  deriving DecidableEq, Repr

structure Output where
  missionPlanParams : String
  avType            : String
  avId              : String
  payloadType       : String
  gcaInfo           : String
  commPreSet        : String
  flightRoutePlan   : String
  payloadPlan       : String
  saved             : Bool
  deriving DecidableEq, Repr

-- IMPL: Uses a database and dynamic mission planning algorithms

def Spec : Contract Input Output where
  pre  := fun i => i.missionPlanParams ≠ "" ∧ i.avType ≠ "" ∧ i.avId ≠ "" ∧
                 i.payloadType ≠ "" ∧ i.gcaInfo ≠ "" ∧ i.commPreSet ≠ "" ∧
                 i.flightRoutePlan ≠ "" ∧ i.payloadPlan ≠ ""
  post := fun i o => o.missionPlanParams = i.missionPlanParams ∧
                     o.avType = i.avType ∧
                     o.avId = i.avId ∧
                     o.payloadType = i.payloadType ∧
                     o.gcaInfo = i.gcaInfo ∧
                     o.commPreSet = i.commPreSet ∧
                     o.flightRoutePlan = i.flightRoutePlan ∧
                     o.payloadPlan = i.payloadPlan ∧
                     o.saved = true

example : Spec.pre { missionPlanParams := "params", avType := "type", avId := "id",
                     payloadType := "payload", gcaInfo := "info", commPreSet := "pre",
                     flightRoutePlan := "route", payloadPlan := "plan" } ∧
          Spec.post { missionPlanParams := "params", avType := "type", avId := "id",
                      payloadType := "payload", gcaInfo := "info", commPreSet := "pre",
                      flightRoutePlan := "route", payloadPlan := "plan" }
                    { missionPlanParams := "params", avType := "type", avId := "id",
                      payloadType := "payload", gcaInfo := "info", commPreSet := "pre",
                      flightRoutePlan := "route", payloadPlan := "plan", saved := true } := by
  unfold Spec; decide
