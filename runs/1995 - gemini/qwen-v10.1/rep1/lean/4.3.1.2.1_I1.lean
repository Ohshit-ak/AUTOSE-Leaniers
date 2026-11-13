import ContractForge
open ContractForge

-- 4.3.1.2.1/I1: Database The heart of an IOC is a memory resident database together with various memory resident structures describing the contents of the database. EPICS supports a large and extensible set of record types, e.g. ai (Analog Input), ao (Analog Output), etc. Each record type has a fixed set of fields. Some fields are common to all record types and others are specific to particular record types. Every record has a record name and every field has a field name. The first field of every database record holds the record name, which must be unique across all IOCs attached to the same TCP/IP subnet. A number of data structures are provided so that the database can be accessed efficiently. Most software components, because they access the database via database access routines, do not need to be aware of these structures.
-- compiles: True · rejects_bad_example: True · checked: True

structure Record where
  name   : String
  field1 : String
  field2 : String
  -- Add other fields as necessary
  deriving DecidableEq, Repr

structure Input where
  records : List Record
  uniqueName : Bool
  deriving DecidableEq, Repr

structure Output where
  records : List Record
  deriving DecidableEq, Repr

-- IMPL: Each record has a unique name and a fixed set of fields. The first field is the record name.
def Spec : Contract Input Output where
  pre  := fun i => i.records.all (fun r => r.name ≠ "" ∧ r.field1 ≠ "")
  post := fun i o => (o.records = i.records ↔ i.uniqueName) ∧
                     (¬i.uniqueName → o.records.length < i.records.length)

example : Spec.pre { records := [{ name := "record1", field1 := "value1", field2 := "value2" }, { name := "record2", field1 := "value3", field2 := "value4" }], uniqueName := true } ∧ Spec.post { records := [{ name := "record1", field1 := "value1", field2 := "value2" }, { name := "record2", field1 := "value3", field2 := "value4" }], uniqueName := true } { records := [{ name := "record1", field1 := "value1", field2 := "value2" }, { name := "record2", field1 := "value3", field2 := "value4" }] } := by
  unfold Spec; decide
