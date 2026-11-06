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

-- L1 architect (success=False)

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

-- Decompose the spec into two components

def QueryTypeTechnicalContract : Contract Input Input where
  pre  := fun i => i.queryType = "technical"
  post := fun i i' => i' = i

def SendEmailContract : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.eMailSent = true

-- Prove PO1: each component's assumption follows from its predecessor's guarantee
example : Contract.Compatible QueryTypeTechnicalContract Spec := by
  unfold QueryTypeTechnicalContract Spec; discharge_po

example : Contract.Compatible SendEmailContract (QueryTypeTechnicalContract.seq Spec) := by
  unfold SendEmailContract QueryTypeTechnicalContract Spec; discharge_po

-- Prove PO2: the composition refines the spec
example : Contract.Refines (SendEmailContract.seq QueryTypeTechnicalContract) Spec := by
  unfold SendEmailContract QueryTypeTechnicalContract Spec; discharge_po

example : Spec.pre { queryFrom := "customer@example.com", queryType := "technical" } ∧
          Spec.post { queryFrom := "customer@example.com", queryType := "technical" }
                    { eMailSent := true } := by
  unfold Spec; decide