import ContractForge
open ContractForge

-- 2.4.2/S1: Systems supporting OM should have the ability to produce charts, maps, and graphs that illustrate OM data, such as epi-curves and the effect of vaccination or prophylaxis on the number of new cases (demonstrating the effectiveness in containing the health event) or maps that illustrate the number of cases by zip code.
-- compiles: False · rejects_bad_example: None · checked: False

structure Input where
  casesByZipCode : List (String × Nat)
  vaccinations : List (String × Nat)
  deriving DecidableEq, Repr

structure Output where
  epiCurve : List (Nat × Nat)
  mapCases : List (String × Nat)
  mapVaccinations : List (String × Nat)
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.casesByZipCode.Nodup && i.vaccinations.Nodup
  post := fun i o => 
    (∀ (day cases) ∈ o.epiCurve, 0 ≤ day ∧ 0 ≤ cases) ∧
    (∀ (zip cases) ∈ o.mapCases, 0 ≤ cases) ∧
    (∀ (zip vacc) ∈ o.mapVaccinations, 0 ≤ vacc) ∧
    (o.epiCurve.length = i.casesByZipCode.length) ∧
    (o.mapCases.length = i.casesByZipCode.length) ∧
    (o.mapVaccinations.length = i.vaccinations.length) ∧
    (o.epiCurve = List.zipWith (fun day cases => (day, cases)) (List.range o.epiCurve.length) (List.map (fun (zip cases) => cases) i.casesByZipCode)) ∧
    (o.mapCases = List.map (fun (zip cases) => (zip, cases)) i.casesByZipCode) ∧
    (o.mapVaccinations = List.map (fun (zip vacc) => (zip, vacc)) i.vaccinations)

example : Spec.pre { casesByZipCode := [("12345", 10), ("67890", 20)], vaccinations := [("12345", 5)] } ∧
          Spec.post { casesByZipCode := [("12345", 10), ("67890", 20)], vaccinations := [("12345", 5)] }
                    { epiCurve := [(0, 10), (1, 20)], mapCases := [("12345", 10), ("67890", 20)], mapVaccinations := [("12345", 5)] } := by
  unfold Spec; decide
