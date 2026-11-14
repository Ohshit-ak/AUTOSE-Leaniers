import ContractForge
open ContractForge

-- 2.2.3.1/S1: Travel history data should include information such as the method of transportation (e.g. bus, plane, boat, car), flight number, departure and arrival dates and times, and the origination and destination locations (city, state, and country).

-- L0 spec

structure Transport where
  method   : String
  flight   : Option String
  departure: String
  arrival  : String
  origination: String
  destination: String
  deriving DecidableEq, Repr

structure Input where
  transport : Transport
  deriving DecidableEq, Repr

structure Output where
  method   : String
  flight   : Option String
  departure: String
  arrival  : String
  origination: String
  destination: String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.transport.departure ≠ "" ∧ i.transport.arrival ≠ "" ∧
                  i.transport.origination ≠ "" ∧ i.transport.destination ≠ ""
  post := fun i o => o.method = i.transport.method ∧
                     o.flight = i.transport.flight ∧
                     o.departure = i.transport.departure ∧
                     o.arrival = i.transport.arrival ∧
                     o.origination = i.transport.origination ∧
                     o.destination = i.transport.destination

example : Spec.pre { transport := { method := "plane", flight := some "AB123", departure := "2023-10-01 10:00", arrival := "2023-10-01 12:00", origination := "New York, NY, USA", destination := "Los Angeles, CA, USA" } } ∧
          Spec.post { transport := { method := "plane", flight := some "AB123", departure := "2023-10-01 10:00", arrival := "2023-10-01 12:00", origination := "New York, NY, USA", destination := "Los Angeles, CA, USA" } }
                    { method := "plane", flight := some "AB123", departure := "2023-10-01 10:00", arrival := "2023-10-01 12:00", origination := "New York, NY, USA", destination := "Los Angeles, CA, USA" } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { method := x.transport.method,
    flight := x.transport.flight,
    departure := x.transport.departure,
    arrival := x.transport.arrival,
    origination := x.transport.origination,
    destination := x.transport.destination }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
