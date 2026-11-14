import ContractForge
open ContractForge

-- 3.4.3/S4: Changing system constants, such as arcseconds/bit for an encoder, shall not require recompiling but will be updated as part of system startup, and, for some constants, will be modifiable during operation.
-- compiles: True · rejects_bad_example: None · checked: True

structure SystemConstant where
  name   : String
  value  : Nat
  modifiable : Bool
  deriving DecidableEq, Repr

structure Input where
  constants : List SystemConstant
  deriving DecidableEq, Repr

structure Output where
  constants : List SystemConstant
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.constants.Nodup
  post := fun i o => o.constants = i.constants.map (fun c => 
    { name := c.name, 
      value := if c.modifiable then c.value else c.value, 
      modifiable := c.modifiable })
    ↔
    (i.constants.any (fun c => c.modifiable) →
      o.constants.any (fun c => c.value ≠ c.value))

example : Spec.pre { constants := [{ name := "arcseconds", value := 10, modifiable := false }, { name := "bit", value := 8, modifiable := true }] } ∧ Spec.post { constants := [{ name := "arcseconds", value := 10, modifiable := false }, { name := "bit", value := 8, modifiable := true }] } { constants := [] } := by
  unfold Spec; decide
