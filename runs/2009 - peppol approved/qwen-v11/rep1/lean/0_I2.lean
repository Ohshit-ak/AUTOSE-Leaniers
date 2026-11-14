import ContractForge
open ContractForge

-- 0/I2: The goals of chapter 3 will be described in more detail. The term "framework" thereby seems to be misleading and will be replaced by a more suitable expression. The general descriptions and structure of chapter 3 will be maintained. Responding to criticism from the review, strong interconnections will be added to the subsequent deliverable D2.2, which will give a more detailed description of the organisational, semantic, technical and legal specifications of the VCD concept. In D2.2., the requirements stated in D 2.1 will be reconsidered and transformed into a tabular collection of functional and non-functional requirements grouped for different components of the overall VCD concept (see subsequent contents of D 2.2)
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  goals : String
  interconnections : List String
  deriving DecidableEq, Repr

structure Output where
  description : String
  requirements : List String
  components : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.goals ≠ "" ∧ i.interconnections.Nodup
  post := fun i o => o.description = "The goals of chapter 3 will be described in more detail. The term 'framework' thereby seems to be misleading and will be replaced by a more suitable expression. The general descriptions and structure of chapter 3 will be maintained. Responding to criticism from the review, strong interconnections will be added to the subsequent deliverable D2.2, which will give a more detailed description of the organisational, semantic, technical and legal specifications of the VCD concept. In D2.2., the requirements stated in D 2.1 will be reconsidered and transformed into a tabular collection of functional and non-functional requirements grouped for different components of the overall VCD concept (see subsequent contents of D 2.2)" ∧
    o.requirements.Nodup ∧
    o.components.Nodup

example : Spec.pre { goals := "The goals of chapter 3 will be described in more detail.", interconnections := ["goal1", "goal2"] } ∧
          Spec.post { goals := "The goals of chapter 3 will be described in more detail.", interconnections := ["goal1", "goal2"], description := "The goals of chapter 3 will be described in more detail. The term 'framework' thereby seems to be misleading and will be replaced by a more suitable expression. The general descriptions and structure of chapter 3 will be maintained. Responding to criticism from the review, strong interconnections will be added to the subsequent deliverable D2.2, which will give a more detailed description of the organisational, semantic, technical and legal specifications of the VCD concept. In D2.2., the requirements stated in D 2.1 will be reconsidered and transformed into a tabular collection of functional and non-functional requirements grouped for different components of the overall VCD concept (see subsequent contents of D 2.2)", requirements := ["req1", "req2"], components := ["comp1", "comp2"] } := by
  unfold Spec; decide
