import ContractForge
open ContractForge

-- 2.1.1.2.1.11/S1: The system shall generate a standard confirmation message after saving data and warning/caution messages after the cancel or close button is clicked.

-- L0 spec

structure Input where
  username : String
  password : String
  confirm  : Bool
  cancel   : Bool
  deriving DecidableEq, Repr

structure Output where
  message : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.message = "User data saved successfully." ↔ i.confirm) ∧
                     (o.message = "Operation cancelled." ↔ i.cancel)

example : Spec.pre { username := "test", password := "pass", confirm := true, cancel := false } ∧
          Spec.post { username := "test", password := "pass", confirm := true, cancel := false }
                    { message := "User data saved successfully." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { message := if x.confirm then "User data saved successfully." else if x.cancel then "Operation cancelled." else "Invalid operation." }
