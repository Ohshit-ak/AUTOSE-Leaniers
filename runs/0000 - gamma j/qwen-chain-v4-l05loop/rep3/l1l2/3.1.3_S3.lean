import ContractForge
open ContractForge

-- 3.1.3/S3: Furthermore, Customer profiles will also include payment information, such as the ability to store credit card information, and address information.

-- L0 spec

structure CreditCard where
  number : String
  expire : String
  cvv    : Nat
  deriving DecidableEq, Repr

structure Address where
  street  : String
  city    : String
  state   : String
  zip     : Nat
  country : String
  deriving DecidableEq, Repr

structure Input where
  username   : String
  password   : String
  creditCard : Option CreditCard
  address    : Option Address
  storingCC  : Bool
  deriving DecidableEq, Repr

structure Output where
  username   : String
  password   : String
  creditCard : Option CreditCard
  address    : Option Address
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ ¬i.storingCC
  post := fun i o =>
    (o.creditCard = none ↔ ¬i.storingCC) ∧
    o.username   = i.username ∧
    o.password   = i.password ∧
    o.address    = i.address

example : Spec.pre { username := "testuser", password := "testpass", creditCard := none, address := none, storingCC := false } ∧
          Spec.post { username := "testuser", password := "testpass", creditCard := none, address := none, storingCC := false }
                    { username := "testuser", password := "testpass", creditCard := none, address := none } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (no intermediate result (no output field of `post` is stated in terms of another)): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { username := x.username, password := x.password, creditCard := none, address := x.address }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
