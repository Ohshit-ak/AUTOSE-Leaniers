import ContractForge
open ContractForge

-- 2.5.4/S1: Systems supporting OM should be able to receive, parse and process messages for laboratory test request responses, in accordance with PHIN Laboratory Test Order Response Message Implementation Guide, available at www.cdc.gov/phin.

-- L0 spec

structure Input where
  message : String
  deriving DecidableEq, Repr

structure Output where
  parsed   : Option String
  response : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.message ≠ ""
  post := fun i o => (o.parsed = some "Lab test request response" ↔
    i.message.toList.all Char.isAlpha = true ∧ i.message.length = 30) ∧
                     (o.response = true ↔ o.parsed = some "Lab test request response")

example : Spec.pre { message := "Lab test request response" } ∧ Spec.post { message := "Lab test request response" } { parsed := none, response := false } := by
  unfold Spec; decide

-- L1 architecture (mode=chain, success=True)

structure Mid where
  isAlpha : Bool
  length  : Nat
  deriving DecidableEq, Repr

def CheckMessageContract : Contract Input Mid where
  pre  := fun i => i.message ≠ ""
  post := fun i m => m.isAlpha = (i.message.toList.all Char.isAlpha) ∧ m.length = i.message.length

def GenerateResponseContract : Contract Mid Output where
  pre  := fun _ => True
  post := fun m o => (o.parsed = some "Lab test request response" ↔
    m.isAlpha ∧ m.length = 30) ∧
                     (o.response = true ↔ o.parsed = some "Lab test request response")

theorem po1 : Contract.Compatible CheckMessageContract GenerateResponseContract := by
  discharge_po1 [CheckMessageContract, GenerateResponseContract, Spec]

theorem po2 : Contract.Refines (CheckMessageContract.seq GenerateResponseContract) Spec := by
  discharge_po2 [CheckMessageContract, GenerateResponseContract, Spec]

-- L2 CheckMessageContract (success=True)

def CheckMessageContractImpl (x : Input) : Mid :=
  { isAlpha := x.message.toList.all Char.isAlpha,
    length := x.message.length }

theorem CheckMessageContractImpl_ok : CheckMessageContract.Satisfies CheckMessageContractImpl := by
  discharge_po3 [CheckMessageContract, CheckMessageContractImpl]

-- L2 GenerateResponseContract (success=True)

def GenerateResponseContractImpl (x : Mid) : Output :=
  { parsed := if x.isAlpha ∧ x.length = 30 then some "Lab test request response" else none,
    response := x.isAlpha ∧ x.length = 30 }

theorem GenerateResponseContractImpl_ok : GenerateResponseContract.Satisfies GenerateResponseContractImpl := by
  discharge_po3 [GenerateResponseContract, GenerateResponseContractImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies (GenerateResponseContractImpl ∘ CheckMessageContractImpl) :=
  Contract.system_sound po1 po2 CheckMessageContractImpl_ok GenerateResponseContractImpl_ok
