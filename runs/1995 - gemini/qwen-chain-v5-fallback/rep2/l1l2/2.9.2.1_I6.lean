import ContractForge
open ContractForge

-- 2.9.2.1/I6: System-wide data capacity. The data capacity of the system is limited by transfer methods and technology, as well as archiving capacity on site. The system data capacity is capable of retaining 7 days of data produced by the largest instrument, the last 3 days of which must be available interactively from hard disk or similar medium.

-- L0 spec

structure Input where
  largestInstrumentData : Nat
  deriving DecidableEq, Repr

structure Output where
  retainedData : Nat
  interactiveData : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.retainedData = 7 * i.largestInstrumentData ∧
                     o.interactiveData = 3 * i.largestInstrumentData

example : Spec.pre { largestInstrumentData := 100 } ∧
          Spec.post { largestInstrumentData := 100 }
                    { retainedData := 700, interactiveData := 300 } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { retainedData := 7 * x.largestInstrumentData,
    interactiveData := 3 * x.largestInstrumentData }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
