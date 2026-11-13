import ContractForge
open ContractForge

-- 7.2.1.2: 7.2.1.2 The following functions will be provided: Call related functions call authorised users; (M) call controller; (M) send Railway emergency calls; (M) receive Railway emergency calls; (M) receive incoming calls; (M) group and broadcast calls; (M) terminate calls; (M) shunting mode communications; (O) enter/leave direct mode; (O) Other functions switch radio on/off; (M) select language; (M) select mobile radio network; (M) adjust loudspeaker volume; (M) register and deregister functional number; (M) store/retrieve numbers and their details; (M) computer interface. (O)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  authorisedUsers : List String
  controller : String
  railwayEmergencyCall : String
  incomingCalls : List String
  groupBroadcastCalls : String
  terminateCalls : String
  shuntingMode : String
  directMode : Bool
  radioOnOff : Bool
  language : String
  mobileRadioNetwork : String
  loudspeakerVolume : Nat
  functionalNumber : Option String
  numbersDetails : List (String × String)
  computerInterface : String
  deriving DecidableEq, Repr

structure Output where
  authorisedUsers : List String
  controller : String
  railwayEmergencyCall : String
  incomingCalls : List String
  groupBroadcastCalls : String
  terminateCalls : String
  shuntingMode : String
  directMode : Bool
  radioOnOff : Bool
  language : String
  mobileRadioNetwork : String
  loudspeakerVolume : Nat
  functionalNumber : Option String
  numbersDetails : List (String × String)
  computerInterface : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.authorisedUsers ≠ [] ∧ i.controller ≠ "" ∧
                   i.railwayEmergencyCall ≠ "" ∧ i.incomingCalls ≠ [] ∧
                   i.groupBroadcastCalls ≠ "" ∧ i.terminateCalls ≠ "" ∧
                   i.shuntingMode ≠ "" ∧ i.functionalNumber.isSome →
                   i.functionalNumber.getD "" ∈ i.authorisedUsers
  post := fun i o => o.authorisedUsers = i.authorisedUsers ∧
                     o.controller = i.controller ∧
                     o.railwayEmergencyCall = i.railwayEmergencyCall ∧
                     o.incomingCalls = i.incomingCalls ∧
                     o.groupBroadcastCalls = i.groupBroadcastCalls ∧
                     o.terminateCalls = i.terminateCalls ∧
                     o.shuntingMode = i.shuntingMode ∧
                     o.directMode = i.directMode ∧
                     o.radioOnOff = i.radioOnOff ∧
                     o.language = i.language ∧
                     o.mobileRadioNetwork = i.mobileRadioNetwork ∧
                     o.loudspeakerVolume = i.loudspeakerVolume ∧
                     o.functionalNumber = i.functionalNumber ∧
                     o.numbersDetails = i.numbersDetails ∧
                     o.computerInterface = i.computerInterface

example : Spec.pre { authorisedUsers := ["user1", "user2"], controller := "ctrl1",
                     railwayEmergencyCall := "call1", incomingCalls := ["call2", "call3"],
                     groupBroadcastCalls := "gb1", terminateCalls := "tc1",
                     shuntingMode := "sm1", directMode := true, radioOnOff := false,
                     language := "en", mobileRadioNetwork := "nr1",
                     loudspeakerVolume := 5, functionalNumber := some "fn1",
                     numbersDetails := [("dn1", "detail1"), ("dn2", "detail2")],
                     computerInterface := "ci1" } ∧
          Spec.post { authorisedUsers := ["user1", "user2"], controller := "ctrl1",
                      railwayEmergencyCall := "call1", incomingCalls := ["call2", "call3"],
                      groupBroadcastCalls := "gb1", terminateCalls := "tc1",
                      shuntingMode := "sm1", directMode := true, radioOnOff := false,
                      language := "en", mobileRadioNetwork := "nr1",
                      loudspeakerVolume := 5, functionalNumber := some "fn1",
                      numbersDetails := [("dn1", "detail1"), ("dn2", "detail2")],
                      computerInterface := "ci1" } := by
  unfold Spec; decide
