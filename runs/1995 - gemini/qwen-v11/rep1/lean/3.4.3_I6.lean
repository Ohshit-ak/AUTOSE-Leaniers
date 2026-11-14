import ContractForge
open ContractForge

-- 3.4.3/I6: The number of main packages of software must be kept to a minimum to facilitate maintenance, but compatibly with the need to have the right degree of modularity.
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  mainPackages : List String
  deriving DecidableEq, Repr

structure Output where
  mainPackages : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.mainPackages.Nodup
  post := fun i o => o.mainPackages = i.mainPackages ∧ o.mainPackages.Nodup

example : Spec.pre { mainPackages := ["pkg1", "pkg2", "pkg3"] } ∧
          Spec.post { mainPackages := ["pkg1", "pkg2", "pkg3"] }
                    { mainPackages := ["pkg1", "pkg2", "pkg3"] } := by
  unfold Spec; decide
