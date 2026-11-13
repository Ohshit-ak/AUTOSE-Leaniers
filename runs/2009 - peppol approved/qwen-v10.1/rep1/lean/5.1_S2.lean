import ContractForge
open ContractForge

-- 5.1/S2: The requirements and contents contained in chapters 2, 3 and 4 can be aggregated according to the following aspects: Level of support: The different levels of support address the maturity of the service and the maturity of the VCD package, where the former correspond to the functionalities (e.g. compilation support vs. recompilation support) provided and the latter corresponds to the semantic richness of the provided information (e.g. information support vs. decision support).
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  chapters : List String
  deriving DecidableEq, Repr

structure Output where
  levelsOfSupport : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.chapters.length ≥ 3
  post := fun i o => 
    (∀ ch ∈ i.chapters, ch ∈ o.levelsOfSupport) ∧
    o.levelsOfSupport.length = 3 ∧
    o.levelsOfSupport.contains "Level of support" ∧
    o.levelsOfSupport.contains "Maturity of the service" ∧
    o.levelsOfSupport.contains "Maturity of the VCD package"

example : Spec.pre { chapters := ["Level of support", "Maturity of the service", "Maturity of the VCD package"] } ∧
          Spec.post { chapters := ["Level of support", "Maturity of the service", "Maturity of the VCD package"] }
                    { levelsOfSupport := ["Level of support", "Maturity of the service", "Maturity of the VCD package"] } := by
  unfold Spec; decide
