import ContractForge
open ContractForge

-- 5.2.3.25: 5.2.3.25 A visual confirmation of the new network identity shall be given to the driver when a manually initiated network change has been completed successfully. (M) 5.2.3.25v Directed network selection is suitable for crossing international borders. (I) Automatic network selection 5.2.3.25vi The Cab radio should be capable of selecting the mobile radio network automatically from a list of suitable networks (see section 10.5). (O) 5.2.3.25vii If automatic network selection is implemented, it shall be possible for the driver to activate and deactivate automatic network selection. (M) 5.2.3.25viii Automatic network selection shall not be used for international border crossing. (M) 5.2.3.25x If directed network selection and/or automatic network selection are implemented, the driver shall be informed by means of an audible and visual indication of the new network identity whenever a network change takes place without user intervention. (M) Register and deregister train number
-- compiles: True · rejects_bad_example: True · checked: True

structure Input where
  networkIdentity : String
  networkList     : List String
  automaticSelection : Bool
  deriving DecidableEq, Repr

structure Output where
  networkIdentity : String
  indication      : Bool
  deriving DecidableEq, Repr

-- IMPL: Directed network selection is suitable for crossing international borders.
-- IMPL: Automatic network selection is capable of selecting a suitable network from a list.
-- IMPL: Driver can activate and deactivate automatic network selection.
-- IMPL: Automatic network selection is not used for international border crossing.
-- IMPL: Driver is informed of the new network identity whenever a network change takes place without user intervention.

def Spec : Contract Input Output where
  pre  := fun i => i.networkIdentity ≠ "" ∧ i.networkList.Nodup
  post := fun i o => (o.networkIdentity = i.networkIdentity ∧ o.indication = true) ↔
                     (i.automaticSelection = true ∧ ∃ n ∈ i.networkList, n ≠ i.networkIdentity)

example : Spec.pre { networkIdentity := "NewNet", networkList := ["OldNet", "NewNet"], automaticSelection := true } ∧
          Spec.post { networkIdentity := "NewNet", networkList := ["OldNet", "NewNet"], automaticSelection := true }
                    { networkIdentity := "NewNet", indication := true } := by
  unfold Spec; decide
