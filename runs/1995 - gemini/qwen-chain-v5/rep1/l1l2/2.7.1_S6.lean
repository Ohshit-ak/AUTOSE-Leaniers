import ContractForge
open ContractForge

-- 2.7.1/S6: The initial implementation of the automatic sequencer will operate in a "pass through"mode where all commands are accepted and transmitted with minimal checking and delay.

-- L0 spec

structure Input where
  command : String
  accepted : Bool
  transmitted : Bool
  deriving DecidableEq, Repr

structure Output where
  accepted : Bool
  transmitted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => True
  post := fun i o => o.accepted = true ∧
                     o.transmitted = true ∧
                     (o.accepted = i.accepted) ∧
                     (o.transmitted = i.transmitted)

example : Spec.pre { command := "start", accepted := true, transmitted := true } ∧
          Spec.post { command := "start", accepted := true, transmitted := true }
                    { accepted := true, transmitted := true } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { accepted := x.accepted,
    transmitted := x.transmitted }
