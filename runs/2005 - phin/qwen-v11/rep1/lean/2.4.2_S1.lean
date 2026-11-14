import ContractForge
open ContractForge

-- 2.4.2/S1: Systems supporting OM should have the ability to produce charts, maps, and graphs that illustrate OM data, such as epi-curves and the effect of vaccination or prophylaxis on the number of new cases (demonstrating the effectiveness in containing the health event) or maps that illustrate the number of cases by zip code.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  casesByZip : List (ZipCode : String, Cases : Nat)
  vaccinations : List (ZipCode : String, Vaccinated : Nat)
  deriving DecidableEq, Repr

structure Output where
  epiCurve : List (Day : Nat, NewCases : Nat)
  mapData : List (ZipCode : String, Cases : Nat)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.casesByZip.Nodup && i.vaccinations.Nodup
  post := fun i o => 
    (∀ ⟨d, nc⟩ ∈ o.epiCurve, 0 ≤ d ∧ 0 ≤ nc) ∧
    (∀ ⟨zc, c⟩ ∈ o.mapData, 0 ≤ c) ∧
    (o.epiCurve.length = i.casesByZip.length) ∧
    (o.mapData.length = i.casesByZip.length) ∧
    (∀ ⟨d, nc⟩ ∈ o.epiCurve, ∃ ⟨zc, c⟩ ∈ i.casesByZip, c > 0 ∧
      (nc = (i.casesByZip.filter (fun ⟨zc', c'⟩ => zc' = zc).map (fun ⟨_, c'⟩ => c').sum))) ∧
    (∀ ⟨zc, c⟩ ∈ o.mapData, ∃ ⟨zc', c'⟩ ∈ i.casesByZip, zc' = zc ∧ c' = c)

example : Spec.pre { casesByZip := [{ ZipCode := "12345", Cases := 10 },
                                     { ZipCode := "67890", Cases := 20 }],
                     vaccinations := [{ ZipCode := "12345", Vaccinated := 50 },
                                     { ZipCode := "67890", Vaccinated := 100 }] } ∧
          Spec.post { casesByZip := [{ ZipCode := "12345", Cases := 10 },
                                      { ZipCode := "67890", Cases := 20 }],
                      vaccinations := [{ ZipCode := "12345", Vaccinated := 50 },
                                      { ZipCode := "67890", Vaccinated := 100 }] }
                    { epiCurve := [{ Day := 0, NewCases := 10 },
                                   { Day := 1, NewCases := 20 }],
                      mapData := [{ ZipCode := "12345", Cases := 10 },
                                  { ZipCode := "67890", Cases := 20 }] } := by
  unfold Spec; decide
