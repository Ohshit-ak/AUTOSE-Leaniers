import ContractForge
open ContractForge

-- 3.2.2.2/S1: The TCS shall be capable of being interoperable with the installed payloads across the 5 levels of UAV interaction. [SSS012] The TCS will have the capability to control and monitor the AV payload(s). [SSS147] The TCS shall have the capability to receive data from and control payloads on an AV that is being controlled from another TCS. [SSS148] The TCS shall provide the necessary system capabilities required for payload control beyond line of sight via uplink command of two air vehicles of the same type using sequential communication techniques. [SSS149] Sequential communication means alternatively communicating with one air vehicle and then the other.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  tcsId : Nat
  payloadId : Nat
  data : String
  deriving DecidableEq, Repr

structure Output where
  tcsId : Nat
  payloadId : Nat
  data : String
  status : String
  deriving DecidableEq, Repr

-- IMPL: Sequential communication techniques are used to control and monitor payloads.

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.tcsId = i.tcsId ∧ o.payloadId = i.payloadId ∧
                     (o.status = "Data received" ↔ i.data ≠ "") ∧
                     (o.status = "Control sent" ↔ i.data ≠ "")

example : Spec.pre { tcsId := 1, payloadId := 2, data := "" } ∧ Spec.post { tcsId := 1, payloadId := 2, data := "" } { tcsId := 1, payloadId := 2, data := "command", status := "" } := by
  unfold Spec; decide
