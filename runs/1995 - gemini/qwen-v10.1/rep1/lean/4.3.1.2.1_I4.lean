import ContractForge
open ContractForge

-- 4.3.1.2.1/I4: Record Support, Device Support, and Device Drivers In order to remove record specific knowledge from database access, each record type has an associated record support module. Similarly, in order to remove device specific knowledge from record support, each record type can have a set of device support modules. If the method of accessing hardware is complicated, a device driver can be provided to shield the device support modules. Many record types, in particular all types not associated with hardware, do not have device support or drivers. The IOC software is designed so that the database access layer knows nothing about the record support layer other than how to call it. The record support layer in turn knows nothing about it's device support layer other than how to call it. Similarly the only thing a device support layer knows about it's associated driver is how to call it. This design allows a particular installation and even a particular IOC within an installation to choose the set of record types, device types, and drivers it wishes to use. The remainder of the IOC system software is unaffected. Every record support module must provide a record processing routine. It is this routine that is called by the database scanners. Record processing consists of some combination of a standard set of functions.
-- compiles: False · rejects_bad_example: None · checked: False

structure RecordSupport where
  recordType : String
  recordProcessingRoutine : String → Prop
  deriving DecidableEq, Repr

structure DeviceSupport where
  deviceType : String
  recordType : String
  deriving DecidableEq, Repr

structure DeviceDriver where
  deviceType : String
  recordType : String
  hardwareAccessMethod : String
  deriving DecidableEq, Repr

structure Input where
  recordSupports : List RecordSupport
  deviceSupports : List DeviceSupport
  deviceDrivers : List DeviceDriver
  deriving DecidableEq, Repr

structure Output where
  recordProcessingRoutineCalled : Bool
  hardwareAccessMethodUsed : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.recordSupports.Nodup && i.deviceSupports.Nodup && i.deviceDrivers.Nodup
  post := fun i o =>
    (∃ rs ∈ i.recordSupports, rs.recordType = "some_record_type" ∧
      rs.recordProcessingRoutine "some_input" = true) ∧
    (o.recordProcessingRoutineCalled = true ↔
      ∃ ds ∈ i.deviceSupports, ds.recordType = "some_record_type" ∧
      ∃ dd ∈ i.deviceDrivers, dd.deviceType = ds.deviceType ∧ dd.recordType = ds.recordType) ∧
    (o.hardwareAccessMethodUsed = "some_method" ↔
      ∃ dd ∈ i.deviceDrivers, dd.hardwareAccessMethod = "some_method" ∧
      ∃ ds ∈ i.deviceSupports, ds.deviceType = dd.deviceType ∧ ds.recordType = dd.recordType)

example : Spec.pre { recordSupports := [{ recordType := "some_record_type", recordProcessingRoutine := fun _ => true }],
                     deviceSupports := [{ deviceType := "some_device_type", recordType := "some_record_type" }],
                     deviceDrivers := [{ deviceType := "some_device_type", recordType := "some_record_type", hardwareAccessMethod := "some_method" }] } ∧
          Spec.post { recordSupports := [{ recordType := "some_record_type", recordProcessingRoutine := fun _ => true }],
                      deviceSupports := [{ deviceType := "some_device_type", recordType := "some_record_type" }],
                      deviceDrivers := [{ deviceType := "some_device_type", recordType := "some_record_type", hardwareAccessMethod := "some_method" }] }
                    { recordProcessingRoutineCalled := true, hardwareAccessMethodUsed := "some_method" } := by
  unfold Spec; decide
