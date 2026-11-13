import ContractForge
open ContractForge

-- 1./I11: Each voucher slip should contain the bar code of the Voucher with two identifications one for the client and the other for the partner.
-- compiles: True · rejects_bad_example: True · checked: True

structure Voucher where
  barcode : String
  clientID : String
  partnerID : String
  deriving DecidableEq, Repr

structure Input where
  barcode : String
  clientID : String
  partnerID : String
  deriving DecidableEq, Repr

structure Output where
  voucher : Voucher
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.barcode ≠ "" ∧ i.clientID ≠ "" ∧ i.partnerID ≠ ""
  post := fun i o => o.voucher = { barcode := i.barcode, clientID := i.clientID, partnerID := i.partnerID }

example : Spec.pre { barcode := "1234567890", clientID := "C001", partnerID := "P001" } ∧
          Spec.post { barcode := "1234567890", clientID := "C001", partnerID := "P001" }
                    { voucher := { barcode := "1234567890", clientID := "C001", partnerID := "P001" } } := by
  unfold Spec; decide
