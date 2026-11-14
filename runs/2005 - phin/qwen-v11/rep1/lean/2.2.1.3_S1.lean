import ContractForge
open ContractForge

-- 2.2.1.3/S1: Systems supporting OM must have the capability to capture data about locations involved in an OM investigation, including: name (if applicable), type (e.g., floor, building, room, store), street address, city, state, zip code, country, GPS coordinates, and other specific details (e.g., a specific building on a campus, a business branch location, a local chapter's meeting hall)
-- compiles: False · rejects_bad_example: None · checked: False

structure Location where
  name        : Option String
  locationType: String
  street      : Option String
  city        : Option String
  state       : Option String
  zipCode     : Option String
  country     : Option String
  gpsCoords   : Option (List Nat) -- GPS coordinates as a list of 4 Nats (lat, lon, alt, acc)
  otherDetails: Option String
  deriving DecidableEq, Repr

structure Input where
  locations : List Location
  deriving DecidableEq, Repr

structure Output where
  locations : List Location
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.locations.Nodup
  post := fun i o => o.locations = i.locations ∧
                     ∀ l ∈ o.locations, l.name.isSome ↔ l.name.isSome ∧
                     l.locationType ≠ "" ∧
                     l.street.isSome ↔ l.street.isSome ∧
                     l.city.isSome ↔ l.city.isSome ∧
                     l.state.isSome ↔ l.state.isSome ∧
                     l.zipCode.isSome ↔ l.zipCode.isSome ∧
                     l.country.isSome ↔ l.country.isSome ∧
                     l.gpsCoords.isSome ↔ l.gpsCoords.isSome ∧
                     l.otherDetails.isSome ↔ l.otherDetails.isSome

example : Spec.pre { locations := [{ name := none, locationType := "floor", street := none, city := none, state := none, zipCode := none, country := none, gpsCoords := none, otherDetails := none },
                                    { name := some "Building A", locationType := "building", street := some "123 Main St", city := some "Anytown", state := some "CA", zipCode := some "90210", country := some "USA", gpsCoords := some [34, -118, 0, 10], otherDetails := none }] } ∧
          Spec.post { locations := [{ name := none, locationType := "floor", street := none, city := none, state := none, zipCode := none, country := none, gpsCoords := none, otherDetails := none },
                                     { name := some "Building A", locationType := "building", street := some "123 Main St", city := some "Anytown", state := some "CA", zipCode := some "90210", country := some "USA", gpsCoords := some [34, -118, 0, 10], otherDetails := none }] }
                    { locations := [{ name := none, locationType := "floor", street := none, city := none, state := none, zipCode := none, country := none, gpsCoords := none, otherDetails := none },
                                    { name := some "Building A", locationType := "building", street := some "123 Main St", city := some "Anytown", state := some "CA", zipCode := some "90210", country := some "USA", gpsCoords := some [34, -118, 0, 10], otherDetails := none }] } := by
  unfold Spec; decide
