import ContractForge
open ContractForge

/-!
# GAMMA-J Web Store — L0 gold specifications

Source: PURE dataset, `0000 - gamma j.xml` (GAMMA-J Web Store SRS).

Convention (matches the framework):
* every entry is a `Contract Input Output` named `Spec_<id>`
* every entry has a satisfiability witness `Spec_<id>_sat : ∃ i o, pre i ∧ post i o`
* Lean core only, no Mathlib
* strings are inspected through `String.toList` so that `decide` can evaluate
  the predicates on concrete inputs (the kernel does not reduce `String.all`)

Interpretation choices for ambiguous requirements are marked `AMBIGUITY:`.
-/

namespace GammaJ

/-! ## Shared helpers -/

/-- All characters are letters or digits. -/
def AllAlnum (cs : List Char) : Prop := cs.all Char.isAlphanum = true

/-- All characters are decimal digits. -/
def AllDigits (cs : List Char) : Prop := cs.all Char.isDigit = true

/-- All characters are letters or spaces ("alphabetic string" for names). -/
def AllAlphaSpace (cs : List Char) : Prop :=
  cs.all (fun c => c.isAlpha || c == ' ') = true

/-- Value of a decimal digit character. -/
def digitVal (c : Char) : Nat := c.toNat - '0'.toNat

/-- Two-digit number from two digit characters. -/
def twoDigits (a b : Char) : Nat := digitVal a * 10 + digitVal b

instance (cs : List Char) : Decidable (AllAlnum cs) := by unfold AllAlnum; infer_instance
instance (cs : List Char) : Decidable (AllDigits cs) := by unfold AllDigits; infer_instance
instance (cs : List Char) : Decidable (AllAlphaSpace cs) := by unfold AllAlphaSpace; infer_instance

/-- A validator contract: the output flag is `true` exactly when the input is valid. -/
def validator (Valid : String → Prop) : Contract String Bool where
  pre  := fun _ => True
  post := fun s b => (b = true ↔ Valid s)

/-! ## Appendix E: Data Dictionary -/

/-- DD-user-id: "minimum 4 to maximum 10 characters (alphabetic or alphanumeric)".
AMBIGUITY: "alphabetic or alphanumeric" read as: only letters/digits, at least one letter
(a purely numeric ID is excluded). -/
def ValidUserId (s : String) : Prop :=
  4 ≤ s.toList.length ∧ s.toList.length ≤ 10 ∧ AllAlnum s.toList ∧
  s.toList.any Char.isAlpha = true
instance (s : String) : Decidable (ValidUserId s) := by unfold ValidUserId; infer_instance
def Spec_DD_user_id : Contract String Bool := validator ValidUserId
theorem Spec_DD_user_id_sat :
    ∃ i o, Spec_DD_user_id.pre i ∧ Spec_DD_user_id.post i o :=
  ⟨"cust01", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-password: same rule as the user ID. -/
def ValidPassword (s : String) : Prop := ValidUserId s
instance (s : String) : Decidable (ValidPassword s) := by unfold ValidPassword; infer_instance
def Spec_DD_password : Contract String Bool := validator ValidPassword
theorem Spec_DD_password_sat :
    ∃ i o, Spec_DD_password.pre i ∧ Spec_DD_password.post i o :=
  ⟨"pass1234", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-item-name: "maximum 50 character alphabetic string".
AMBIGUITY: spaces allowed (item names have several words); empty name rejected. -/
def ValidItemName (s : String) : Prop :=
  1 ≤ s.toList.length ∧ s.toList.length ≤ 50 ∧ AllAlphaSpace s.toList
instance (s : String) : Decidable (ValidItemName s) := by unfold ValidItemName; infer_instance
def Spec_DD_item_name : Contract String Bool := validator ValidItemName
theorem Spec_DD_item_name_sat :
    ∃ i o, Spec_DD_item_name.pre i ∧ Spec_DD_item_name.post i o :=
  ⟨"Garden Hose", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-item-id: "a 7-digit system generated alphanumeric character".
AMBIGUITY: "7-digit ... alphanumeric" read as exactly 7 letters/digits. -/
def ValidItemId (s : String) : Prop :=
  s.toList.length = 7 ∧ AllAlnum s.toList
instance (s : String) : Decidable (ValidItemId s) := by unfold ValidItemId; infer_instance
def Spec_DD_item_id : Contract String Bool := validator ValidItemId
theorem Spec_DD_item_id_sat :
    ∃ i o, Spec_DD_item_id.pre i ∧ Spec_DD_item_id.post i o :=
  ⟨"AB12345", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-text-description: "maximum 100 alphabetic characters" (spaces allowed). -/
def ValidDescription (s : String) : Prop :=
  s.toList.length ≤ 100 ∧ AllAlphaSpace s.toList
instance (s : String) : Decidable (ValidDescription s) := by unfold ValidDescription; infer_instance
def Spec_DD_text_description : Contract String Bool := validator ValidDescription
theorem Spec_DD_text_description_sat :
    ∃ i o, Spec_DD_text_description.pre i ∧ Spec_DD_text_description.post i o :=
  ⟨"Durable rubber hose", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-quantity: "default = 1; maximum = quantity presently in inventory".
Input: (requested quantity, if any; units in stock). Output: the quantity used.
AMBIGUITY: a quantity of 0 is not a valid order line, so the minimum is 1. -/
def Spec_DD_quantity : Contract (Option Nat × Nat) Nat where
  pre  := fun (req, stock) => 1 ≤ req.getD 1 ∧ req.getD 1 ≤ stock
  post := fun (req, _) q => q = req.getD 1
theorem Spec_DD_quantity_sat :
    ∃ i o, Spec_DD_quantity.pre i ∧ Spec_DD_quantity.post i o :=
  ⟨(none, 5), 1, by show 1 ≤ 1 ∧ 1 ≤ 5; decide, rfl⟩

/-- DD-name: "maximum 100 alphabetic characters" (spaces allowed, non-empty). -/
def ValidName (s : String) : Prop :=
  1 ≤ s.toList.length ∧ s.toList.length ≤ 100 ∧ AllAlphaSpace s.toList
instance (s : String) : Decidable (ValidName s) := by unfold ValidName; infer_instance
def Spec_DD_name : Contract String Bool := validator ValidName
theorem Spec_DD_name_sat :
    ∃ i o, Spec_DD_name.pre i ∧ Spec_DD_name.post i o :=
  ⟨"Ada Lovelace", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-city / DD-state: "maximum 20 characters alphabetic string". -/
def ValidCityOrState (s : String) : Prop :=
  1 ≤ s.toList.length ∧ s.toList.length ≤ 20 ∧ AllAlphaSpace s.toList
instance (s : String) : Decidable (ValidCityOrState s) := by
  unfold ValidCityOrState; infer_instance
def Spec_DD_city : Contract String Bool := validator ValidCityOrState
theorem Spec_DD_city_sat :
    ∃ i o, Spec_DD_city.pre i ∧ Spec_DD_city.post i o :=
  ⟨"Hyderabad", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩
def Spec_DD_state : Contract String Bool := validator ValidCityOrState
theorem Spec_DD_state_sat :
    ∃ i o, Spec_DD_state.pre i ∧ Spec_DD_state.post i o :=
  ⟨"Telangana", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-zip-code: "5 digit numeric string". -/
def ValidZip (s : String) : Prop := s.toList.length = 5 ∧ AllDigits s.toList
instance (s : String) : Decidable (ValidZip s) := by unfold ValidZip; infer_instance
def Spec_DD_zip_code : Contract String Bool := validator ValidZip
theorem Spec_DD_zip_code_sat :
    ∃ i o, Spec_DD_zip_code.pre i ∧ Spec_DD_zip_code.post i o :=
  ⟨"50003", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-email: "50 characters alphanumeric".
AMBIGUITY: a literal reading forbids '@', so no e-mail address could be valid.
Read as: at most 50 characters, exactly one '@', non-empty alphanumeric/'.'
parts on both sides. -/
def EmailChar (c : Char) : Bool := c.isAlphanum || c == '.'
def ValidEmail (s : String) : Prop :=
  s.toList.length ≤ 50 ∧
  ∃ l d, s.toList = l ++ '@' :: d ∧ l ≠ [] ∧ d ≠ [] ∧
    l.all EmailChar = true ∧ d.all EmailChar = true
def Spec_DD_email : Contract String Bool := validator ValidEmail
theorem Spec_DD_email_sat :
    ∃ i o, Spec_DD_email.pre i ∧ Spec_DD_email.post i o :=
  ⟨"a@b.in", true, trivial,
   ⟨fun _ => ⟨by decide, ['a'], ['b', '.', 'i', 'n'], rfl, by decide, by decide, rfl, rfl⟩,
    fun _ => rfl⟩⟩

/-- DD-credit-card-no: "16 digit numeric string". -/
def ValidCardNo (s : String) : Prop := s.toList.length = 16 ∧ AllDigits s.toList
instance (s : String) : Decidable (ValidCardNo s) := by unfold ValidCardNo; infer_instance
def Spec_DD_credit_card_no : Contract String Bool := validator ValidCardNo
theorem Spec_DD_credit_card_no_sat :
    ∃ i o, Spec_DD_credit_card_no.pre i ∧ Spec_DD_credit_card_no.post i o :=
  ⟨"4111111111111111", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-credit-card-expiry: "format MM/YY" with month 01-12. -/
def ValidExpiry (s : String) : Prop :=
  ∃ m1 m2 y1 y2, s.toList = [m1, m2, '/', y1, y2] ∧
    AllDigits [m1, m2, y1, y2] ∧ 1 ≤ twoDigits m1 m2 ∧ twoDigits m1 m2 ≤ 12
def Spec_DD_credit_card_expiry : Contract String Bool := validator ValidExpiry
theorem Spec_DD_credit_card_expiry_sat :
    ∃ i o, Spec_DD_credit_card_expiry.pre i ∧ Spec_DD_credit_card_expiry.post i o :=
  ⟨"09/27", true, trivial,
   ⟨fun _ => ⟨'0', '9', '2', '7', rfl, by decide, by decide, by decide⟩, fun _ => rfl⟩⟩

/-- DD-order-no: "9 characters alphanumeric". -/
def ValidOrderNo (s : String) : Prop := s.toList.length = 9 ∧ AllAlnum s.toList
instance (s : String) : Decidable (ValidOrderNo s) := by unfold ValidOrderNo; infer_instance
def Spec_DD_order_no : Contract String Bool := validator ValidOrderNo
theorem Spec_DD_order_no_sat :
    ∃ i o, Spec_DD_order_no.pre i ∧ Spec_DD_order_no.post i o :=
  ⟨"ORD000123", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-tracking-no: "20 characters alphanumeric". -/
def ValidTrackingNo (s : String) : Prop := s.toList.length = 20 ∧ AllAlnum s.toList
instance (s : String) : Decidable (ValidTrackingNo s) := by unfold ValidTrackingNo; infer_instance
def Spec_DD_tracking_no : Contract String Bool := validator ValidTrackingNo
theorem Spec_DD_tracking_no_sat :
    ∃ i o, Spec_DD_tracking_no.pre i ∧ Spec_DD_tracking_no.post i o :=
  ⟨"TRK00000000000000001", true, trivial, ⟨fun _ => by decide, fun _ => rfl⟩⟩

/-- DD-shipping-date: "format MM/DD/YYYY".
AMBIGUITY: days 01-31 for every month (month lengths and leap years not enforced). -/
def ValidShipDate (s : String) : Prop :=
  ∃ m1 m2 d1 d2 y1 y2 y3 y4,
    s.toList = [m1, m2, '/', d1, d2, '/', y1, y2, y3, y4] ∧
    AllDigits [m1, m2, d1, d2, y1, y2, y3, y4] ∧
    1 ≤ twoDigits m1 m2 ∧ twoDigits m1 m2 ≤ 12 ∧
    1 ≤ twoDigits d1 d2 ∧ twoDigits d1 d2 ≤ 31
def Spec_DD_shipping_date : Contract String Bool := validator ValidShipDate
theorem Spec_DD_shipping_date_sat :
    ∃ i o, Spec_DD_shipping_date.pre i ∧ Spec_DD_shipping_date.post i o :=
  ⟨"10/31/2026", true, trivial,
   ⟨fun _ => ⟨'1', '0', '3', '1', '2', '0', '2', '6', rfl,
              by decide, by decide, by decide, by decide, by decide⟩,
    fun _ => rfl⟩⟩

/-! ## Domain model for the functional requirements -/

/-- A product in the store. Prices are in cents. -/
structure Product where
  id    : String
  price : Nat

/-- One line of a shopping cart. -/
structure CartLine where
  product : Product
  qty     : Nat

/-- A shopping cart. -/
abbrev Cart := List CartLine

/-- Units of the product with id `pid` in the cart. -/
def qtyOf (c : Cart) (pid : String) : Nat :=
  ((c.filter (fun l => l.product.id == pid)).map (·.qty)).sum

/-- Number of items in the cart (sum of quantities). -/
def itemCount (c : Cart) : Nat := (c.map (·.qty)).sum

/-- Total cost of the cart in cents. -/
def totalCost (c : Cart) : Nat := (c.map (fun l => l.qty * l.product.price)).sum

/-- A registered customer account. -/
structure Account where
  email    : String
  password : String
  name     : String
  billing  : String
  shipping : String

/-- A placed order. -/
structure Order where
  lines : Cart
  total : Nat

/-! ## 3.3 Shopping Cart -/

/-- FR-cart-display: "The shopping cart will clearly display the number of items in the
cart, along with the total cost." Output: (item count, total cost). -/
def Spec_FR_cart_display : Contract Cart (Nat × Nat) where
  pre  := fun _ => True
  post := fun c (n, t) => n = itemCount c ∧ t = totalCost c
theorem Spec_FR_cart_display_sat :
    ∃ i o, Spec_FR_cart_display.pre i ∧ Spec_FR_cart_display.post i o :=
  ⟨[], (0, 0), trivial, rfl, rfl⟩

/-- FR-cart-add (+ UC Add Item To Cart, + DD-quantity bound): adding `q` units of `p`
increases that product's quantity by `q`, leaves every other product unchanged, and never
exceeds the units in stock. Input: (cart, product, q, stock of p). -/
def Spec_FR_cart_add : Contract (Cart × Product × Nat × Nat) Cart where
  pre  := fun (c, p, q, stock) => 1 ≤ q ∧ qtyOf c p.id + q ≤ stock
  post := fun (c, p, q, _) c' =>
    qtyOf c' p.id = qtyOf c p.id + q ∧
    ∀ pid, pid ≠ p.id → qtyOf c' pid = qtyOf c pid
theorem Spec_FR_cart_add_sat :
    ∃ i o, Spec_FR_cart_add.pre i ∧ Spec_FR_cart_add.post i o := by
  refine ⟨([], ⟨"AB12345", 500⟩, 1, 10), [⟨⟨"AB12345", 500⟩, 1⟩], ?_, ?_, ?_⟩
  · show 1 ≤ 1 ∧ qtyOf [] "AB12345" + 1 ≤ 10
    simp [qtyOf]
  · show qtyOf [⟨⟨"AB12345", 500⟩, 1⟩] "AB12345" = qtyOf [] "AB12345" + 1
    simp [qtyOf]
  · intro pid hne
    show qtyOf [⟨⟨"AB12345", 500⟩, 1⟩] pid = qtyOf [] pid
    have h : ("AB12345" == pid) = false := by
      simp only [beq_eq_false_iff_ne]; exact fun h => hne h.symm
    simp [qtyOf, List.filter, h]

/-- FR-cart-remove: removing a product sets its quantity to 0 and leaves every other
product unchanged. Input: (cart, product id). -/
def Spec_FR_cart_remove : Contract (Cart × String) Cart where
  pre  := fun _ => True
  post := fun (c, pid) c' =>
    qtyOf c' pid = 0 ∧ ∀ other, other ≠ pid → qtyOf c' other = qtyOf c other
theorem Spec_FR_cart_remove_sat :
    ∃ i o, Spec_FR_cart_remove.pre i ∧ Spec_FR_cart_remove.post i o :=
  ⟨([], "AB12345"), [], trivial, rfl, fun _ _ => rfl⟩

/-! ## 3.1 Customer Accounts + Appendix B use cases -/

/-- UC Register Customer: a new account is added, no existing account is lost, and
e-mail addresses stay unique. Input: (existing accounts, new account). -/
def Spec_UC_register : Contract (List Account × Account) (List Account) where
  pre  := fun (accts, a) => ValidEmail a.email ∧ ValidPassword a.password ∧
                            ∀ b ∈ accts, b.email ≠ a.email
  post := fun (accts, a) accts' =>
    a ∈ accts' ∧ (∀ b ∈ accts, b ∈ accts') ∧ accts'.length = accts.length + 1
/-- Sample account used by the witnesses. -/
def sampleAccount : Account := ⟨"a@b.in", "pass1234", "Ada", "x", "x"⟩

theorem Spec_UC_register_sat :
    ∃ i o, Spec_UC_register.pre i ∧ Spec_UC_register.post i o := by
  refine ⟨([], sampleAccount), [sampleAccount], ⟨?_, ?_, ?_⟩, ?_, ?_, rfl⟩
  · exact ⟨by decide, ['a'], ['b', '.', 'i', 'n'], by decide, by decide, by decide, rfl, rfl⟩
  · show ValidUserId "pass1234"; decide
  · intro b hb; nomatch hb
  · exact List.mem_singleton.mpr rfl
  · intro b hb; nomatch hb

/-- UC Login Customer: login succeeds, opening a session for that e-mail, exactly when the
e-mail/password pair belongs to a registered account. Output: `some email` = session opened. -/
def Spec_UC_login : Contract (List Account × String × String) (Option String) where
  pre  := fun _ => True
  post := fun (accts, e, pw) r =>
    (r.isSome = true ↔ ∃ a ∈ accts, a.email = e ∧ a.password = pw) ∧
    ∀ s, r = some s → s = e
theorem Spec_UC_login_sat :
    ∃ i o, Spec_UC_login.pre i ∧ Spec_UC_login.post i o :=
  by
    refine ⟨([], "a@b.in", "pass1234"), none, trivial, ?_, ?_⟩
    · show (none : Option String).isSome = true ↔ ∃ a ∈ ([] : List Account), _
      simp
    · intro s h; nomatch h

/-- UC Logout Customer: "System terminates the session cookie". Pre: logged in. -/
def Spec_UC_logout : Contract (Option String) (Option String) where
  pre  := fun s => s.isSome = true
  post := fun _ s' => s' = none
theorem Spec_UC_logout_sat :
    ∃ i o, Spec_UC_logout.pre i ∧ Spec_UC_logout.post i o :=
  ⟨some "a@b.in", none, rfl, rfl⟩

/-- UC Checkout An Order (+ CI-1 confirmation e-mail): requires a logged-in customer and a
non-empty cart; the order contains exactly the cart, its total is the cart's total cost, and
the confirmation goes to the customer's e-mail.
Input: (session e-mail, cart). Output: (order, confirmation recipient). -/
def Spec_UC_checkout : Contract (Option String × Cart) (Order × String) where
  pre  := fun (sess, c) => sess.isSome = true ∧ c ≠ []
  post := fun (sess, c) (o, to) =>
    o.lines = c ∧ o.total = totalCost c ∧ sess = some to
theorem Spec_UC_checkout_sat :
    ∃ i o, Spec_UC_checkout.pre i ∧ Spec_UC_checkout.post i o :=
  let c : Cart := [⟨⟨"AB12345", 500⟩, 2⟩]
  ⟨(some "a@b.in", c), (⟨c, 1000⟩, "a@b.in"), ⟨rfl, by decide⟩, rfl, by decide, rfl⟩

/-! ## Glossary business rule -/

/-- BR-out-of-stock: "Entire order will be delayed until all of the ordered items are in
stock." Output `true` = ship now, `false` = delay the whole order.
Input: (order, stock level per product id). -/
def Spec_BR_out_of_stock : Contract (Order × (String → Nat)) Bool where
  pre  := fun _ => True
  post := fun (o, stock) ship =>
    (ship = true ↔ ∀ l ∈ o.lines, l.qty ≤ stock l.product.id)
theorem Spec_BR_out_of_stock_sat :
    ∃ i o, Spec_BR_out_of_stock.pre i ∧ Spec_BR_out_of_stock.post i o :=
  by
    refine ⟨(⟨[], 0⟩, fun _ => 0), true, trivial, ?_⟩
    show true = true ↔ ∀ l ∈ ([] : Cart), _
    simp

/-! ## 5.3 Security -/

/-- NFR-sec-failed-logins: "The system shall detect consecutive failed login attempts."
AMBIGUITY: the SRS gives no threshold, so it is a parameter `k`.
Input: login history, newest last (`true` = success). Output `true` = flagged. -/
def Spec_NFR_failed_logins (k : Nat) : Contract (List Bool) Bool where
  pre  := fun _ => 1 ≤ k
  post := fun hist flagged =>
    (flagged = true ↔ k ≤ hist.length ∧ (hist.drop (hist.length - k)).all (· == false) = true)
theorem Spec_NFR_failed_logins_sat :
    ∃ i o, (Spec_NFR_failed_logins 3).pre i ∧ (Spec_NFR_failed_logins 3).post i o :=
  by
    refine ⟨[false, false, false], true, by show 1 ≤ 3; decide, ?_⟩
    show true = true ↔ 3 ≤ 3 ∧ ([false, false, false].drop (3 - 3)).all (· == false) = true
    decide

end GammaJ
