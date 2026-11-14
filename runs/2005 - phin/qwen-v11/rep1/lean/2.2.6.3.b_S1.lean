import ContractForge
open ContractForge

-- 2.2.6.3.b/S1: Environmental sample data should include information about the collection method, location (geocoded if possible) from which the sample was taken, source (e.g., rain or well for water, radiation release, asbestos, chair or desk in a specified location), nature of the sample (e.g., soil, water, air), quality control data, collection begin and end date and time for air samples, and original volume and volume of concentrate tested for water samples.
-- compiles: False · rejects_bad_example: None · checked: False

structure CollectionMethod where
  method : String
  deriving DecidableEq, Repr

structure Location where
  geocode : Option String
  deriving DecidableEq, Repr

structure Source where
  kind : String
  deriving DecidableEq, Repr

structure Sample where
  nature : String
  qualityControl : String
  beginDateTime : Option String
  endDateTime : Option String
  originalVolume : Option String
  concentrateVolume : Option String
  deriving DecidableEq, Repr

structure Input where
  collectionMethod : CollectionMethod
  location : Location
  source : Source
  sample : Sample
  deriving DecidableEq, Repr

structure Output where
  collectionMethod : String
  location : String
  source : String
  sample : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.collectionMethod.method ≠ "" ∧
                   i.location.geocode.isSome ∨ i.location.geocode.isNone ∧
                   i.source.kind ≠ "" ∧
                   i.sample.nature ≠ "" ∧
                   i.sample.qualityControl ≠ "" ∧
                   (i.sample.beginDateTime = none ∨ i.sample.beginDateTime ≠ none) ∧
                   (i.sample.endDateTime = none ∨ i.sample.endDateTime ≠ none) ∧
                   (i.sample.originalVolume = none ∨ i.sample.originalVolume ≠ none) ∧
                   (i.sample.concentrateVolume = none ∨ i.sample.concentrateVolume ≠ none)
  post := fun i o => o.collectionMethod = i.collectionMethod.method ∧
                      o.location = i.location.geocode.getD "" ∧
                      o.source = i.source.kind ∧
                      o.sample = i.sample.nature ++ " " ++ i.sample.qualityControl ++ " " ++
                                (if i.sample.beginDateTime = none then "" else " " ++ i.sample.beginDateTime.getD "") ++ " " ++
                                (if i.sample.endDateTime = none then "" else " " ++ i.sample.endDateTime.getD "") ++ " " ++
                                (if i.sample.originalVolume = none then "" else " " ++ i.sample.originalVolume.getD "") ++ " " ++
                                (if i.sample.concentrateVolume = none then "" else " " ++ i.sample.concentrateVolume.getD "")

example : Spec.pre { collectionMethod := { method := "swab" },
                     location := { geocode := some "1234567890" },
                     source := { kind := "rain" },
                     sample := { nature := "water", qualityControl := "pass", beginDateTime := none, endDateTime := none, originalVolume := none, concentrateVolume := none } } ∧
          Spec.post { collectionMethod := "swab",
                      location := "1234567890",
                      source := "rain",
                      sample := "water pass" } := by
  unfold Spec; decide
