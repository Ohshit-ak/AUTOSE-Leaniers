/-!
# String helpers for specs

Checks on text fields, written over `List Char` (use `s.toList`) with structural
recursion only, so `decide` evaluates them in the kernel. Lean core only.
This module is frozen with L0 v10: add new helpers in a new module.
-/

namespace ContractForge

/-- Every character is a decimal digit `0`–`9` (true for the empty list). -/
def allDigits (cs : List Char) : Bool := cs.all Char.isDigit

/-- Every character is a letter or a digit (true for the empty list). -/
def allAlnum (cs : List Char) : Bool := cs.all Char.isAlphanum

/-- The length is between `lo` and `hi`, both included. -/
def lenBetween (lo hi : Nat) (cs : List Char) : Bool :=
  decide (lo ≤ cs.length) && decide (cs.length ≤ hi)

/-- Split at every `sep`: `splitOn '/' "12/31".toList = ["12".toList, "31".toList]`.
Always returns at least one part; empty parts are kept (`"a//b"` has three). -/
def splitOn (sep : Char) : List Char → List (List Char)
  | [] => [[]]
  | c :: cs =>
    match splitOn sep cs with
    | [] => [[c]]
    | w :: ws => if c = sep then [] :: w :: ws else (c :: w) :: ws

/-- The value of a decimal digit character (`'7'` ↦ 7). -/
def digitVal (c : Char) : Nat := c.toNat - '0'.toNat

/-- The number written by exactly two digits (`"07"` ↦ `some 7`), else `none`. -/
def twoDigitNat : List Char → Option Nat
  | [a, b] => if a.isDigit && b.isDigit then some (digitVal a * 10 + digitVal b) else none
  | _ => none

/-- A month `01`–`12` written with two digits. -/
def isMonth (cs : List Char) : Bool :=
  match twoDigitNat cs with
  | some m => decide (1 ≤ m) && decide (m ≤ 12)
  | none => false

/-- A day `01`–`31` written with two digits (the month is not checked). -/
def isDay (cs : List Char) : Bool :=
  match twoDigitNat cs with
  | some d => decide (1 ≤ d) && decide (d ≤ 31)
  | none => false

/-- `MM/YY`: a month `01`–`12`, `/`, two digits. -/
def isMMYY : List Char → Bool
  | [m1, m2, s, y1, y2] => s == '/' && isMonth [m1, m2] && allDigits [y1, y2]
  | _ => false

/-- `MM/DD/YYYY`: a month `01`–`12`, `/`, a day `01`–`31`, `/`, four digits. -/
def isMMDDYYYY : List Char → Bool
  | [m1, m2, s1, d1, d2, s2, y1, y2, y3, y4] =>
    s1 == '/' && s2 == '/' && isMonth [m1, m2] && isDay [d1, d2] && allDigits [y1, y2, y3, y4]
  | _ => false

end ContractForge
