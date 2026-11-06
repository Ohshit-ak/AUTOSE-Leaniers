import ContractForge
open ContractForge

-- CI-2: The WebOrder system shall send an e-mail to System Administrator regarding any technical queries from customers or sales people.

-- L0 spec

structure Input where
  queryFrom : String
  queryType : String
  deriving DecidableEq, Repr

structure Output where
  eMailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.queryType = "technical"
  post := fun i o => o.eMailSent = true

example : Spec.pre { queryFrom := "customer@example.com", queryType := "technical" } ∧
          Spec.post { queryFrom := "customer@example.com", queryType := "technical" }
                    { eMailSent := true } := by
  unfold Spec; decide

-- L1 architect (success=True)

structure Mid where
  queryFrom : String
  queryType : String
  deriving DecidableEq, Repr

def ValidateContract : Contract Input Mid where
  pre  := fun i => i.queryType = "technical"
  post := fun i m => m.queryType = i.queryType ∧ m.queryType = "technical"

def SendEmailContract : Contract Mid Output where
  pre  := fun m => m.queryType = "technical"
  post := fun m o => o.eMailSent = true

theorem po1 : Contract.Compatible ValidateContract SendEmailContract := by
  discharge_po [SendEmailContract, Spec, ValidateContract]

theorem po2 : Contract.Refines (ValidateContract.seq SendEmailContract) Spec := by
  discharge_po [SendEmailContract, Spec, ValidateContract]

-- L2 ValidateContract (success=True)

def ValidateContractImpl (i : Input) : Mid := 
  { queryFrom := i.queryFrom, queryType := i.queryType }

theorem ValidateContractImpl_ok : ValidateContract.Satisfies ValidateContractImpl := by
  discharge_po [SendEmailContract, Spec, ValidateContract, ValidateContractImpl]

-- L2 SendEmailContract (success=True)

def SendEmailContractImpl (m : Mid) : Output := { eMailSent := true }

theorem SendEmailContractImpl_ok : SendEmailContract.Satisfies SendEmailContractImpl := by
  discharge_po [SendEmailContract, SendEmailContractImpl, Spec, ValidateContract]