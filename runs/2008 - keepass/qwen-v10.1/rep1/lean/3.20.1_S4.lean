import ContractForge
open ContractForge

-- 3.20.1/S4: The generation can be based on character sets, patterns or can be created according by rules.
-- compiles: False · rejects_bad_example: None · checked: False

structure CharacterSet where
  digits   : Bool
  lower    : Bool
  upper    : Bool
  symbols  : Bool
  deriving DecidableEq, Repr

structure Pattern where
  sequence : String
  repeat   : Nat
  deriving DecidableEq, Repr

structure Rule where
  minDigits   : Nat
  minLower    : Nat
  minUpper    : Nat
  minSymbols  : Nat
  minLength   : Nat
  maxLength   : Nat
  deriving DecidableEq, Repr

structure Input where
  characterSets : List CharacterSet
  patterns      : List Pattern
  rules         : List Rule
  minLength     : Nat
  maxLength     : Nat
  deriving DecidableEq, Repr

structure Output where
  password : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.minLength ≤ i.maxLength
  post := fun i o => o.password.length = i.minLength ∧
                     (o.password.toList.all (fun c => i.characterSets.any (fun cs => cs.digits = true ∧ c.isDigit) ∨
                                               i.characterSets.any (fun cs => cs.lower = true ∧ c.isLower) ∨
                                               i.characterSets.any (fun cs => cs.upper = true ∧ c.isUpper) ∨
                                               i.characterSets.any (fun cs => cs.symbols = true ∧ c.isSymbol)) = true) ∧
                     (i.patterns.any (fun p => o.password = (o.password.take p.repeat).repeat p.sequence.length) = true) ∧
                     (i.rules.any (fun r => o.password.length ≥ r.minLength ∧ o.password.length ≤ r.maxLength ∧
                                            o.password.count (fun c => c.isDigit) ≥ r.minDigits ∧
                                            o.password.count (fun c => c.isLower) ≥ r.minLower ∧
                                            o.password.count (fun c => c.isUpper) ≥ r.minUpper ∧
                                            o.password.count (fun c => c.isSymbol) ≥ r.minSymbols) = true)

example : Spec.pre { characterSets := [{ digits := true, lower := false, upper := false, symbols := false },
                                        { digits := false, lower := true, upper := false, symbols := false }],
                     patterns := [{ sequence := "abc", repeat := 3 }],
                     rules := [{ minDigits := 1, minLower := 1, minUpper := 0, minSymbols := 0, minLength := 3, maxLength := 3 }],
                     minLength := 3, maxLength := 3 } ∧
          Spec.post { characterSets := [{ digits := true, lower := false, upper := false, symbols := false },
                                        { digits := false, lower := true, upper := false, symbols := false }],
                      patterns := [{ sequence := "abc", repeat := 3 }],
                      rules := [{ minDigits := 1, minLower := 1, minUpper := 0, minSymbols := 0, minLength := 3, maxLength := 3 }],
                      minLength := 3, maxLength := 3 }
                    { password := "abcabc" } := by
  unfold Spec; decide
