import ContractForge
open ContractForge

-- 9.5.4/I2: 2) User Number (UN) The UN is variable in length and depends on the information on which it is based. The following formats are defined: Train Function Numbers (TFN) shall take one of the forms as defined in table 9-2. Leading zeros shall be used in those situations where the train number is less than five digits. Engine Function Numbers (EFN) shall take the format as defined in table 9-3. Coach Function Numbers (CFN) shall take the format as defined in table 9-4. Maintenance and Shunting Team Members. The UIN field format for calls to shunting teams and maintenance teams shall consist of a Location Number (LN), which identifies the location where the called party is registered, followed by a Function Code (FC). The Location Number shall consist of 5 digits and shall be assigned on a national basis. The Function Code shall consist of 4 digits. The first digit of the FC is related to the Team Type (TT) and is specified by table 9-5. The composition of the Function Code field for calls to shunting teams and maintenance teams shall be as defined in table 9-6. Train Controllers. The UIN field for calls to train controllers shall be a Location Number (LN) which identifies the location where the called party is registered. The Location Number shall consist of 5 digits and shall be assigned on a national basis. The FC field for calls to train controllers shall consist of two digits and be as defined in table 9-7. Mobile Subscriber Number (MSN). The UN of the MSN shall consist of the Subscriber Number. Group and broadcast calls. The UIN field format for group calls shall be a Service Area (SA) indicator, which identifies the area in which the group call is to be active. Each Service Area shall be allocated on a national basis. In network boundary areas, the Service Area shall be allocated on a bilateral basis. (See also subsection 9.9.) The FC field format for group calls shall consist of three digits and be as defined in table 9-8.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  un : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => true
  post := fun i o => 
    (i.un.toList.all Char.isDigit = true ∧ i.un.length ≤ 10) ↔
    (i.un.length = 5 ∧ i.un.toNat ≤ 99999 ∧ o.valid = true) ∧
    (i.un.length = 9 ∧ (i.un.substring 0 1 = "1" ∨ i.un.substring 0 1 = "2" ∨ i.un.substring 0 1 = "3") ∧ 
     (i.un.substring 1 5).toNat ≤ 99999 ∧ o.valid = true) ∧
    (i.un.length = 9 ∧ (i.un.substring 0 1 = "4" ∨ i.un.substring 0 1 = "5") ∧ 
     (i.un.substring 1 5).toNat ≤ 99999 ∧ o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "6" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "7" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "8" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "9" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true) ∧
    (i.un.length = 5 ∧ i.un.toNat ≤ 99999 ∧ o.valid = true) ∧
    (i.un.length = 9 ∧ (i.un.substring 0 1 = "1" ∨ i.un.substring 0 1 = "2" ∨ i.un.substring 0 1 = "3") ∧ 
     (i.un.substring 1 5).toNat ≤ 99999 ∧ o.valid = true) ∧
    (i.un.length = 9 ∧ (i.un.substring 0 1 = "4" ∨ i.un.substring 0 1 = "5") ∧ 
     (i.un.substring 1 5).toNat ≤ 99999 ∧ o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "6" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "7" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "8" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true) ∧
    (i.un.length = 9 ∧ i.un.substring 0 1 = "9" ∧ 
     ((i.un.substring 1 4).toNat = 1000 ∨ (i.un.substring 1 4).toNat = 2000 ∨ (i.un.substring 1 4).toNat = 3000 ∨ (i.un.substring 1 4).toNat = 4000 ∨ (i.un.substring 1 4).toNat = 5000) ∧ 
     o.valid = true)

example : Spec.pre { un := "12345" } ∧ Spec.post { un := "12345" } { valid := true } := by
  unfold Spec; decide
