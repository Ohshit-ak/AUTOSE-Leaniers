import ContractForge
open ContractForge

-- 2.2.1.3/S1: Systems supporting OM must have the capability to capture data about locations involved in an OM investigation, including: name (if applicable), type (e.g., floor, building, room, store), street address, city, state, zip code, country, GPS coordinates, and other specific details (e.g., a specific building on a campus, a business branch location, a local chapter's meeting hall)
-- compiles: True · rejects_bad_example: None · checked: True

structure Location where
  name        : Option String
  locationType: String
  street      : Option String
  city        : Option String
  state       : Option String
  zipCode     : Option String
  country     : Option String
  gpsCoords   : Option String
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
                     ∀ l ∈ o.locations, l.name.isSome ∨ l.locationType ≠ "" ∨
                     l.street.isSome ∨ l.city.isSome ∨ l.state.isSome ∨
                     l.zipCode.isSome ∨ l.country.isSome ∨ l.gpsCoords.isSome ∨
                     l.otherDetails.isSome

example : Spec.pre { locations := [{ name := none, locationType := "floor", street := some "123 Main St",
                                      city := some "Anytown", state := some "CA", zipCode := some "90210",
                                      country := some "USA", gpsCoords := some "34.052237,-118.243685",
                                      otherDetails := some "Specific building on a campus" }] } ∧
          Spec.post { locations := [{ name := none, locationType := "floor", street := some "123 Main St",
                                      city := some "Anytown", state := some "CA", zipCode := some "90210",
                                      country := some "USA", gpsCoords := some "34.052237,-118.243685",
                                      otherDetails := some "Specific building on a campus" }] }
                    { locations := [{ name := none, locationType := "floor", street := some "123 Main St",
                                      city := some "Anytown", state := some "CA", zipCode := some "90210",
                                      country := some "USA", gpsCoords := some "34.052237,-118.243685",
                                      otherDetails := some "Specific building on a campus" }] } := by
  unfold Spec; decide
