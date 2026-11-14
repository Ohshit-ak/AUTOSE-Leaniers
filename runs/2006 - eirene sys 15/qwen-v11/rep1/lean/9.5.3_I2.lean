import ContractForge
open ContractForge

-- 9.5.3/I2: 2) User Identifier Number: The User Identifier Number (UIN) shall be one of the following numbers (as identified by the CT): (M) Train Number (TN): a number given to a train by operational staff for a particular journey. This number shall be unique for the duration of the journey. Note. For certain Train Numbers (e.g. 1234 and 123), a risk exists when dialling a number by keying in individual digits e.g. by the dispatcher. In this circumstance the risk of connecting to an un-intended train exists if there is a delay between keyed-in digits. There is no risk of ambiguity if block dialling is employed. Engine Number (EN): a unique number given to a tractive unit to identify it permanently. The UIC has introduced a uniform identification marking system for tractive stock crossing frontiers [UIC 438-3]. In order to call a particular locomotive, it shall be possible to call a number associated with the tractive unit's stock number. The actual number of the unit, which shall be used as the EN, is based on the complete identification number. Coach Number (CN): a unique number given to a coach (which is not a tractive unit) to identify it permanently. The UIC has introduced a uniform identification marking for passenger rolling stock [UIC 438-1]. In order to call a particular coach it shall be possible to call a number associated with the vehicle marking. The total vehicle marking consists of 12 digits. The actual number of the coach is denoted by seven digits (positions 5 to 11 of the complete vehicle marking), which shall be used as the CN7. Shunting Team Location Number (STLN) Maintenance Team Location Number (MTLN) Train Controller Location Number (TCLN) Group Location Number (GLN) Mobile Subscriber Number (MSN)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  uin : String
  deriving DecidableEq, Repr

structure Output where
  uinType : String
  uinValue : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.uin.length = 4 && i.uin.toList.all Char.isDigit
  post := fun i o => 
    (o.uinType = "TN" ↔ i.uin = "TN" && 1000 ≤ i.uinValue && i.uinValue < 10000) ∧
    (o.uinType = "EN" ↔ i.uin = "EN" && 1000000 ≤ i.uinValue && i.uinValue < 10000000) ∧
    (o.uinType = "CN7" ↔ i.uin = "CN" && 1000000 ≤ i.uinValue && i.uinValue < 10000000) ∧
    (o.uinType = "STLN" ↔ i.uin = "STLN" && 1000000 ≤ i.uinValue && i.uinValue < 10000000) ∧
    (o.uinType = "MTLN" ↔ i.uin = "MTLN" && 1000000 ≤ i.uinValue && i.uinValue < 10000000) ∧
    (o.uinType = "TCLN" ↔ i.uin = "TCLN" && 1000000 ≤ i.uinValue && i.uinValue < 10000000) ∧
    (o.uinType = "GLN" ↔ i.uin = "GLN" && 1000000 ≤ i.uinValue && i.uinValue < 10000000) ∧
    (o.uinType = "MSN" ↔ i.uin = "MSN" && 100000000000 ≤ i.uinValue && i.uinValue < 1000000000000)

example : Spec.pre { uin := "1234" } ∧
          Spec.post { uin := "1234", uinType := "TN", uinValue := 1234 } := by
  unfold Spec; decide
