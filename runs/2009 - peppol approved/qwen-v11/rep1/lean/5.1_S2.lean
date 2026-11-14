import ContractForge
open ContractForge

-- 5.1/S2: The requirements and contents contained in chapters 2, 3 and 4 can be aggregated according to the following aspects: Level of support: The different levels of support address the maturity of the service and the maturity of the VCD package, where the former correspond to the functionalities (e.g. compilation support vs. recompilation support) provided and the latter corresponds to the semantic richness of the provided information (e.g. information support vs. decision support).
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  chapters : List String
  deriving DecidableEq, Repr

structure Output where
  levelsOfSupport : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.chapters.length ≥ 3
  post := fun i o => 
    (∀ ch ∈ i.chapters, ch = "2" ∨ ch = "3" ∨ ch = "4") ∧
    o.levelsOfSupport.length = i.chapters.length ∧
    (∀ ch ∈ i.chapters, ∃ l ∈ o.levelsOfSupport, l = "Level of support: The different levels of support address the maturity of the service and the maturity of the VCD package, where the former correspond to the functionalities (e.g. compilation support vs. recompilation support) provided and the latter corresponds to the semantic richness of the provided information (e.g. information support vs. decision support).")

example : Spec.pre { chapters := ["2", "3", "4"] } ∧
          Spec.post { chapters := ["2", "3", "4"] }
                    { levelsOfSupport := ["Level of support: The different levels of support address the maturity of the service and the maturity of the VCD package, where the former correspond to the functionalities (e.g. compilation support vs. recompilation support) provided and the latter corresponds to the semantic richness of the provided information (e.g. information support vs. decision support).", "Level of support: The different levels of support address the maturity of the service and the maturity of the VCD package, where the former correspond to the functionalities (e.g. compilation support vs. recompilation support) provided and the latter corresponds to the semantic richness of the provided information (e.g. information support vs. decision support).", "Level of support: The different levels of support address the maturity of the service and the maturity of the VCD package, where the former correspond to the functionalities (e.g. compilation support vs. recompilation support) provided and the latter corresponds to the semantic richness of the provided information (e.g. information support vs. decision support)."] } := by
  unfold Spec; decide
