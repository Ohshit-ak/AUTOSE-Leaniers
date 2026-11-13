import ContractForge
open ContractForge

-- 3.4.7/S1: The TCS shall be able to access data storage devices. [SSS339] The TCS shall have the functionality to transfer digital data as well as digital imagery to and from data storage devices. [SSS340]
-- compiles: True · rejects_bad_example: None · checked: True

structure Input where
  dataToTransfer : String
  imageryToTransfer : String
  dataStorageDevice : String
  deriving DecidableEq, Repr

structure Output where
  dataTransferred : Bool
  imageryTransferred : Bool
  dataStorageDevice : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.dataToTransfer ≠ "" ∨ i.imageryToTransfer ≠ ""
  post := fun i o =>
    (o.dataTransferred = true ↔ i.dataToTransfer ≠ "") ∧
    (o.imageryTransferred = true ↔ i.imageryToTransfer ≠ "") ∧
    (o.dataTransferred = false → i.dataToTransfer = "") ∧
    (o.imageryTransferred = false → i.imageryToTransfer = "") ∧
    o.dataStorageDevice = i.dataStorageDevice

example : Spec.pre { dataToTransfer := "1024 bytes of data", imageryToTransfer := "", dataStorageDevice := "device1" } ∧
          Spec.post { dataToTransfer := "1024 bytes of data", imageryToTransfer := "", dataStorageDevice := "device1" }
                    { dataTransferred := true, imageryTransferred := false, dataStorageDevice := "device1" } := by
  unfold Spec; decide
