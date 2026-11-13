import ContractForge
open ContractForge

-- 2.5/I4: When the KeePass is active, all passwords are stored encrypted in process memory so in order for them to be completely safe the ARC4 encryption algorithm is used, using a random 12 bytes long key.
-- compiles: True · rejects_bad_example: False · checked: False

structure Input where
  passwords : List String
  active    : Bool
  deriving DecidableEq, Repr

structure Output where
  passwords : List String
  active    : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.active
  post := fun i o => o.active = i.active ∧
                     (o.passwords.length = i.passwords.length ∧
                      ∀ p ∈ o.passwords, p ≠ "")

-- IMPL: ARC4 encryption algorithm is used with a random 12 bytes long key
example : Spec.pre { passwords := ["pass1", "pass2"], active := true } ∧
          Spec.post { passwords := ["pass1", "pass2"], active := true }
                    { passwords := ["pass1", "pass2"], active := true } := by
  unfold Spec; decide
