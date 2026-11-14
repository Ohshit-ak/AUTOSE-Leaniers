import ContractForge
open ContractForge

-- REQ-6#3: A results page will display 100 results.

-- L0 spec

structure Input where
  results : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.results.length = 100

example : Spec.pre { results := ["result1", "result2", "result3", "result4", "result5", "result6", "result7", "result8", "result9", "result10", "result11", "result12", "result13", "result14", "result15", "result16", "result17", "result18", "result19", "result20", "result21", "result22", "result23", "result24", "result25", "result26", "result27", "result28", "result29", "result30", "result31", "result32", "result33", "result34", "result35", "result36", "result37", "result38", "result39", "result40", "result41", "result42", "result43", "result44", "result45", "result46", "result47", "result48", "result49", "result50", "result51", "result52", "result53", "result54", "result55", "result56", "result57", "result58", "result59", "result60", "result61", "result62", "result63", "result64", "result65", "result66", "result67", "result68", "result69", "result70", "result71", "result72", "result73", "result74", "result75", "result76", "result77", "result78", "result79", "result80", "result81", "result82", "result83", "result84", "result85", "result86", "result87", "result88", "result89", "result90", "result91", "result92", "result93", "result94", "result95", "result96", "result97", "result98", "result99", "result100"] } ∧
  Spec.post { results := ["result1", "result2", "result3", "result4", "result5", "result6", "result7", "result8", "result9", "result10", "result11", "result12", "result13", "result14", "result15", "result16", "result17", "result18", "result19", "result20", "result21", "result22", "result23", "result24", "result25", "result26", "result27", "result28", "result29", "result30", "result31", "result32", "result33", "result34", "result35", "result36", "result37", "result38", "result39", "result40", "result41", "result42", "result43", "result44", "result45", "result46", "result47", "result48", "result49", "result50", "result51", "result52", "result53", "result54", "result55", "result56", "result57", "result58", "result59", "result60", "result61", "result62", "result63", "result64", "result65", "result66", "result67", "result68", "result69", "result70", "result71", "result72", "result73", "result74", "result75", "result76", "result77", "result78", "result79", "result80", "result81", "result82", "result83", "result84", "result85", "result86", "result87", "result88", "result89", "result90", "result91", "result92", "result93", "result94", "result95", "result96", "result97", "result98", "result99", "result100"] }
            { results := ["result1", "result2", "result3", "result4", "result5", "result6", "result7", "result8", "result9", "result10", "result11", "result12", "result13", "result14", "result15", "result16", "result17", "result18", "result19", "result20", "result21", "result22", "result23", "result24", "result25", "result26", "result27", "result28", "result29", "result30", "result31", "result32", "result33", "result34", "result35", "result36", "result37", "result38", "result39", "result40", "result41", "result42", "result43", "result44", "result45", "result46", "result47", "result48", "result49", "result50", "result51", "result52", "result53", "result54", "result55", "result56", "result57", "result58", "result59", "result60", "result61", "result62", "result63", "result64", "result65", "result66", "result67", "result68", "result69", "result70", "result71", "result72", "result73", "result74", "result75", "result76", "result77", "result78", "result79", "result80", "result81", "result82", "result83", "result84", "result85", "result86", "result87", "result88", "result89", "result90", "result91", "result92", "result93", "result94", "result95", "result96", "result97", "result98", "result99", "result100"] } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=False)

def SpecImpl (x : Input) : Output :=
  { results := x.results }
