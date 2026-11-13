import ContractForge
open ContractForge

-- 2.2.3.1/S1: Travel history data should include information such as the method of transportation (e.g. bus, plane, boat, car), flight number, departure and arrival dates and times, and the origination and destination locations (city, state, and country).
-- compiles: True · rejects_bad_example: True · checked: True

structure Transport where
  method   : String
  flightNo : String
  departureDate : String
  departureTime : String
  arrivalDate : String
  arrivalTime : String
  origination : String
  destination : String
  deriving DecidableEq, Repr

structure Input where
  transports : List Transport
  deriving DecidableEq, Repr

structure Output where
  transports : List Transport
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.transports.Nodup
  post := fun i o => o.transports = i.transports ∧
                     ∀ t ∈ o.transports, t.method ≠ "" ∧
                     t.flightNo.toList.all (·.isAlphanum) = true ∧
                     t.departureDate.toList.all (·.isAlphanum) = true ∧
                     t.departureTime.toList.all (·.isAlphanum) = true ∧
                     t.arrivalDate.toList.all (·.isAlphanum) = true ∧
                     t.arrivalTime.toList.all (·.isAlphanum) = true ∧
                     t.origination.toList.all (·.isAlphanum) = true ∧
                     t.destination.toList.all (·.isAlphanum) = true

example : Spec.pre { transports := [] } ∧ Spec.post { transports := [] } { transports := [] } := by
  unfold Spec; decide
