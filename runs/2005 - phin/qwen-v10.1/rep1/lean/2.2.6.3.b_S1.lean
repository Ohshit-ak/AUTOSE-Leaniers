import ContractForge
open ContractForge

-- 2.2.6.3.b/S1: Environmental sample data should include information about the collection method, location (geocoded if possible) from which the sample was taken, source (e.g., rain or well for water, radiation release, asbestos, chair or desk in a specified location), nature of the sample (e.g., soil, water, air), quality control data, collection begin and end date and time for air samples, and original volume and volume of concentrate tested for water samples.
-- compiles: True · rejects_bad_example: True · checked: True

structure CollectionMethod where
  name : String
  deriving DecidableEq, Repr

structure Location where
  geoCode : Option String
  deriving DecidableEq, Repr

structure Source where
  type : String
  deriving DecidableEq, Repr

structure Sample where
  collectionMethod : CollectionMethod
  location         : Location
  source           : Source
  nature           : String
  qualityControl   : String
  collectionBegin  : String
  collectionEnd    : Option String
  originalVolume   : Nat
  volumeConcentrate: Nat
  deriving DecidableEq, Repr

structure Input where
  collectionMethod : CollectionMethod
  location         : Location
  source           : Source
  nature           : String
  qualityControl   : String
  collectionBegin  : String
  collectionEnd    : Option String
  originalVolume   : Nat
  volumeConcentrate: Nat
  deriving DecidableEq, Repr

structure Output where
  collectionMethod : CollectionMethod
  location         : Location
  source           : Source
  nature           : String
  qualityControl   : String
  collectionBegin  : String
  collectionEnd    : Option String
  originalVolume   : Nat
  volumeConcentrate: Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => i.collectionMethod = o.collectionMethod ∧
                     i.location = o.location ∧
                     i.source = o.source ∧
                     i.nature = o.nature ∧
                     i.qualityControl = o.qualityControl ∧
                     i.collectionBegin = o.collectionBegin ∧
                     i.collectionEnd = o.collectionEnd ∧
                     i.originalVolume = o.originalVolume ∧
                     i.volumeConcentrate = o.volumeConcentrate

example : Spec.pre { collectionMethod := { name := "swab" },
                     location := { geoCode := some "1234567890" },
                     source := { type := "rain" },
                     nature := "water",
                     qualityControl := "pass",
                     collectionBegin := "2023-10-01 10:00",
                     collectionEnd := none,
                     originalVolume := 1000,
                     volumeConcentrate := 100 } ∧
          Spec.post { collectionMethod := { name := "swab" },
                      location := { geoCode := some "1234567890" },
                      source := { type := "rain" },
                      nature := "water",
                      qualityControl := "pass",
                      collectionBegin := "2023-10-01 10:00",
                      collectionEnd := none,
                      originalVolume := 1000,
                      volumeConcentrate := 100 }
                    { collectionMethod := { name := "swab" },
                      location := { geoCode := some "1234567890" },
                      source := { type := "rain" },
                      nature := "water",
                      qualityControl := "pass",
                      collectionBegin := "2023-10-01 10:00",
                      collectionEnd := none,
                      originalVolume := 1000,
                      volumeConcentrate := 100 } := by
  unfold Spec; decide
