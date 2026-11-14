import ContractForge
open ContractForge

-- 7.3.3/S1: It shall be possible to register and deregister a functional number by the user entering his functional number, which is transmitted to the ground along with the subscriber's IMSI, using USSD (see section 11).

-- L0 spec

structure FunctionalNumber where
  number : String
  deriving DecidableEq, Repr

structure Input where
  functionalNumber : String
  subscriberIMSI   : String
  deregister      : Bool
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  message    : String
  deriving DecidableEq, Repr

-- A functional number is valid if it consists of exactly 10 digits
def ValidFunctionalNumber (fn : String) : Bool :=
  fn.length = 10 ∧ fn.toList.all Char.isDigit = true

def Spec : Contract Input Output where
  pre  := fun i => ValidFunctionalNumber i.functionalNumber
  post := fun i o =>
    (o.registered = true ↔
      (i.deregister = false →
        -- If not deregistering, the functional number is registered
        true
      ) ∧
      -- If deregistering, the functional number is unregistered
      (i.deregister = true →
        false
      )
    ) ∧
    (o.message = "Functional number registered." ↔ o.registered = true) ∧
    (o.message = "Functional number deregistered." ↔ o.registered = false)

example : Spec.pre { functionalNumber := "1234567890", subscriberIMSI := "IMSI123456789012345", deregister := false } ∧
          Spec.post { functionalNumber := "1234567890", subscriberIMSI := "IMSI123456789012345", deregister := false }
                    { registered := true, message := "Functional number registered." } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  registered : Bool
  message    : String
  deriving DecidableEq, Repr

def RegisterContract : Contract Input Mid where
  pre  := fun i => ValidFunctionalNumber i.functionalNumber
  post := fun i m => 
    (m.registered = true ↔
      (i.deregister = false →
        true
      ) ∧
      (i.deregister = true →
        false
      )
    ) ∧
    (m.message = "Functional number registered." ↔ m.registered = true)

def ShowMessageContract : Contract Mid Output where
  pre  := fun m => True
  post := fun m o => (o.registered = m.registered) ∧
    (o.message = m.message ∧ (o.message = "Functional number registered." ↔ m.registered = true))
    ∧
    (o.message = "Functional number deregistered." ↔ m.registered = false)



theorem po1 : Contract.Compatible RegisterContract ShowMessageContract := by
  discharge_po1 [RegisterContract, ShowMessageContract, Spec]

theorem po2 : Contract.Refines (RegisterContract.seq ShowMessageContract) Spec := by
  discharge_po2 [RegisterContract, ShowMessageContract, Spec]

-- L2 RegisterContract (success=True)

def RegisterContractImpl (x : Input) : Mid :=
  { registered := decide ((x.deregister = false →
        true
      ) ∧
      (x.deregister = true →
        false
      )),
    message := if (x.deregister = false → true) ∧ (x.deregister = true → false) then "Functional number registered." else "Functional number deregistered." }

theorem RegisterContractImpl_ok : RegisterContract.Satisfies RegisterContractImpl := by
  discharge_po3 [RegisterContract, RegisterContractImpl]

-- L2 ShowMessageContract (success=False)

def ShowMessageContractImpl (x : Mid) : Output :=
  { registered := x.registered,
    message := if x.registered then "Functional number registered." else "Functional number deregistered." }
