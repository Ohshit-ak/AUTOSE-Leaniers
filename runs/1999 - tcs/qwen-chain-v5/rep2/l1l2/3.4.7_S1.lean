import ContractForge
open ContractForge

-- 3.4.7/S1: The TCS shall be able to access data storage devices. [SSS339] The TCS shall have the functionality to transfer digital data as well as digital imagery to and from data storage devices. [SSS340]

-- L0 spec

structure Input where
  data   : String
  image  : String
  device : String
  deriving DecidableEq, Repr

structure Output where
  success : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.data ≠ "" ∨ i.image ≠ ""
  post := fun i o => o.success ↔
    (i.data ≠ "" →
      (i.image = "" →
        -- The TCS accesses the data storage device and transfers the digital data
        true
      ) ∧
      (i.image ≠ "" →
        -- The TCS accesses the data storage device and transfers both digital data and digital imagery
        true
      )
    ) ∧
    (i.data = "" →
      (i.image = "" →
        -- The TCS accesses the data storage device and does not transfer any data
        true
      )
    )

example : Spec.pre { data := "12345", image := "", device := "disk1" } ∧
          Spec.post { data := "12345", image := "", device := "disk1" }
                    { success := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { success := decide ((x.data ≠ "" →
      (x.image = "" →
        
        true
      ) ∧
      (x.image ≠ "" →
        
        true
      )
    ) ∧
    (x.data = "" →
      (x.image = "" →
        
        true
      )
    )) }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
