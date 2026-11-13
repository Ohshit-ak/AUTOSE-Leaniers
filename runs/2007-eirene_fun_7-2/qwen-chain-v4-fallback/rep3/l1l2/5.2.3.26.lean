import ContractForge
open ContractForge

-- 5.2.3.26: 5.2.3.26 It shall be possible for the driver to register and deregister a train number in the following ways: 1) enter train number; (M) 2) initiate automated request (applicable only for leading driver). (O)

-- L0 spec

structure TrainNumber where
  number : String
  deriving DecidableEq, Repr

structure Driver where
  name    : String
  isLeading : Bool
  deriving DecidableEq, Repr

structure Input where
  trainNumbers : List TrainNumber
  driver       : Driver
  deriving DecidableEq, Repr

structure Output where
  registeredNumbers : List TrainNumber
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.driver.name ≠ ""
  post := fun i o => 
    (o.registeredNumbers.length = i.trainNumbers.length + (if i.driver.isLeading then 1 else 0) ∧
     ∀ tn ∈ i.trainNumbers, tn ∈ o.registeredNumbers) ∧
    (o.registeredNumbers.length ≤ i.trainNumbers.length + (if i.driver.isLeading then 1 else 0))

example : Spec.pre { trainNumbers := [], driver := { name := "John", isLeading := true } } ∧ Spec.post { trainNumbers := [], driver := { name := "John", isLeading := true } } { registeredNumbers := [{ number := "12345" }] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { registeredNumbers := x.trainNumbers ++ (if x.driver.isLeading then [x.trainNumbers.head] else []) }
