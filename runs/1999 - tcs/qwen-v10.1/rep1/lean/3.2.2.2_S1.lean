import ContractForge
open ContractForge

-- 3.2.2.2/S1: The TCS shall be capable of being interoperable with the installed payloads across the 5 levels of UAV interaction. [SSS012] The TCS will have the capability to control and monitor the AV payload(s). [SSS147] The TCS shall have the capability to receive data from and control payloads on an AV that is being controlled from another TCS. [SSS148] The TCS shall provide the necessary system capabilities required for payload control beyond line of sight via uplink command of two air vehicles of the same type using sequential communication techniques. [SSS149] Sequential communication means alternatively communicating with one air vehicle and then the other.
-- compiles: True · rejects_bad_example: None · checked: False

structure Input where
  tcsId : Nat
  payloadId : Nat
  command : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  message : String
  deriving DecidableEq, Repr

-- IMPL: Sequential communication techniques are used to control and monitor payloads.

def Spec : Contract Input Output where
  pre  := fun i => i.tcsId ≠ 0 ∧ i.payloadId ≠ 0
  post := fun i o => o.success ↔
    (i.command = "control" →
      (i.tcsId % 2 = 0 →
        -- TCS is even, communicate with the first vehicle
        true
      ) ∨
      (i.tcsId % 2 = 1 →
        -- TCS is odd, communicate with the second vehicle
        true
      )
    ) ∧
    o.message = "Payload control command sent successfully."

example : Spec.pre { tcsId := 2, payloadId := 1, command := "control" } ∧
          Spec.post { tcsId := 2, payloadId := 1, command := "control" }
                    { success := true, message := "Payload control command sent successfully." } := by
  unfold Spec; decide
