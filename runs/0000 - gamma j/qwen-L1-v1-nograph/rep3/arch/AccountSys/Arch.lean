import ContractForge
open ContractForge

-- L1 architecture of AccountSys (generated; statements by the harness)

-- locked context sha 687428ab8e2e; chain: Inventory → Accounts → ShoppingCart → Payment

set_option linter.unusedSimpArgs false
set_option linter.unusedVariables false
namespace Domain
-- STATUS: REVIEWED 2026-11-06 (compiles; definitions identical to GammaJ_L0.lean lines 205-245 plus DecidableEq, Repr deriving)
/-!
# GAMMA-J Web Store — shared domain types (L1)

Extracted from `benchmark/gammaj/GammaJ_L0.lean` (hand-written gold): `Product`, `CartLine`,
`Cart`, `Account`, `Order` and the helpers `qtyOf`, `itemCount`, `totalCost`, unchanged
except that every structure derives `DecidableEq, Repr` (so equality of values and lists of
them is decidable). Lean core only. Locked during L1: the harness hashes this file.
-/

/-- A product in the store. Prices are in cents. -/
structure Product where
  id    : String
  price : Nat
  deriving DecidableEq, Repr

/-- One line of a shopping cart. -/
structure CartLine where
  product : Product
  qty     : Nat
  deriving DecidableEq, Repr

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
  deriving DecidableEq, Repr

/-- A placed order. -/
structure Order where
  lines : Cart
  total : Nat
  deriving DecidableEq, Repr

-- Decidable over `List`: these evaluate with `decide`.
example : itemCount [⟨⟨"AB12345", 500⟩, 2⟩] = 2 := by decide
example : totalCost [⟨⟨"AB12345", 500⟩, 2⟩] = 1000 := by decide
example : qtyOf [⟨⟨"AB12345", 500⟩, 2⟩, ⟨⟨"ZZ00001", 100⟩, 1⟩] "AB12345" = 2 := by decide
example : (⟨"a@b.in", "pass1234", "Ada", "x", "x"⟩ : Account) ∈
    [(⟨"a@b.in", "pass1234", "Ada", "x", "x"⟩ : Account)] := by decide
end Domain

namespace L0_1_4_s2
-- 1.4/S2
structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items = 100
  post := fun i o => o.items = i.items
end L0_1_4_s2

namespace L0_1_4_s3
-- 1.4/S3
structure Code where
  code : String
  unique : Bool
  deriving DecidableEq, Repr

structure Input where
  inventory : List Code
  purchases : List Code
  deriving DecidableEq, Repr

structure Output where
  inventory : List Code
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.purchases.all (fun c => c.unique)
  post := fun i o => o.inventory.length = i.inventory.length + i.purchases.length ∧
                     ∀ c ∈ i.purchases, c ∈ o.inventory ∧ c.unique
end L0_1_4_s3

namespace L0_1_4_s4
-- 1.4/S4
structure Input where
  items : Nat
  deriving DecidableEq, Repr

structure Output where
  items : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items ≥ 20000
  post := fun i o => o.items = i.items
end L0_1_4_s4

namespace L0_3_1_3_s1
-- 3.1.3/S1
structure CustomerProfile where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Input where
  name        : String
  email       : String
  phone       : String
  address     : String
  purchaseHistory : List String
  orderStatus : String
  deriving DecidableEq, Repr

structure Output where
  profileCreated : Bool
  profile        : CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" ∧ i.phone ≠ "" ∧ i.address ≠ ""
  post := fun i o => (o.profileCreated = true ↔
    o.profile.name = i.name ∧ o.profile.email = i.email ∧
    o.profile.phone = i.phone ∧ o.profile.address = i.address ∧
    o.profile.purchaseHistory = i.purchaseHistory ∧
    o.profile.orderStatus = i.orderStatus) ∧
    o.profile.purchaseHistory.Nodup ∧
    o.profile.orderStatus = "confirmed"
end L0_3_1_3_s1

namespace L0_3_1_3_s2
-- 3.1.3/S2
structure Account where
  username : String
  password : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  action   : String
  accounts : List Account
  deriving DecidableEq, Repr

structure Output where
  username : String
  logged   : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ ""
  post := fun i o => (o.logged = true ↔
    i.action = "login" ∧
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
    (o.logged = false ↔
    (i.action = "logout" ∧ o.username = i.username) ∨
    (i.action = "register" ∧ i.username ∉ i.accounts.map (·.username)))
end L0_3_1_3_s2

namespace L0_3_1_3_s3
-- 3.1.3/S3
structure CreditCard where
  number : String
  expiry : String
  cvv    : Nat
  deriving DecidableEq, Repr

structure Address where
  street  : String
  city    : String
  state   : String
  zipCode : String
  deriving DecidableEq, Repr

structure CustomerProfile where
  name        : String
  email       : String
  creditCards : List CreditCard
  addresses   : List Address
  deriving DecidableEq, Repr

structure Input where
  profiles : List CustomerProfile
  deriving DecidableEq, Repr

structure Output where
  profiles : List CustomerProfile
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.profiles = i.profiles ∧
                     ∀ p ∈ o.profiles, p.name ≠ "" ∧
                     p.email ≠ "" ∧
                     p.creditCards.Nodup ∧
                     p.addresses.Nodup
end L0_3_1_3_s3

namespace L0_3_2_3_s2
-- 3.2.3/S2
structure Category where
  id : Nat
  name : String
  parent : Option Nat
  deriving DecidableEq, Repr

structure Product where
  id : Nat
  name : String
  category : Nat
  details : String
  deriving DecidableEq, Repr

structure Input where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

structure Output where
  categories : List Category
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.categories.Nodup ∧ i.products.Nodup
  post := fun i o => o.categories = i.categories ∧
                     o.products = i.products
end L0_3_2_3_s2

namespace L0_3_3_3_s1
-- 3.3.3/S1
structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  productToAdd : Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.cart.length = i.cart.length + 1 ∧
                     o.cart.contains i.productToAdd
end L0_3_3_3_s1

namespace L0_3_3_3_s2
-- 3.3.3/S2
structure CartItem where
  name : String
  price : Nat
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  items : List CartItem
  deriving DecidableEq, Repr

structure Output where
  itemCount : Nat
  totalCost : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.items.Nodup
  post := fun i o => o.itemCount = (i.items.map (fun x => x.quantity)).sum ∧
                     o.totalCost = (i.items.map (fun x => x.quantity * x.price)).sum
end L0_3_3_3_s2

namespace L0_3_3_3_s3
-- 3.3.3/S3
structure Product where
  name : String
  price : Nat
  deriving DecidableEq, Repr

structure Input where
  cart : List Product
  deriving DecidableEq, Repr

structure Output where
  cart : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.Nodup
  post := fun i o => o.cart = i.cart
end L0_3_3_3_s3

namespace L0_3_4_3_s1
-- 3.4.3/S1
structure Cart where
  items : List String
  deriving DecidableEq, Repr

structure Order where
  items : List String
  confirmed : Bool
  deriving DecidableEq, Repr

structure Input where
  cart : Cart
  deriving DecidableEq, Repr

structure Output where
  order : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.cart.items.Nodup
  post := fun i o => o.order.items = i.cart.items ∧
                     o.order.confirmed = true ∧
                     o.order.items.Nodup
end L0_3_4_3_s1

namespace L0_3_4_3_s2
-- 3.4.3/S2
structure Order where
  items : List String
  quantity : Nat
  deriving DecidableEq, Repr

structure Input where
  order : Order
  deriving DecidableEq, Repr

structure Output where
  order : Order
  revised : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.order.quantity > 0
  post := fun i o => (o.revised = true ↔
    ∃ item ∈ i.order.items, o.order.quantity < i.order.quantity) ∧
    o.order.items = i.order.items ∧
    o.order.quantity ≤ i.order.quantity
end L0_3_4_3_s2

namespace L0_3_4_3_s3
-- 3.4.3/S3
structure Order where
  id      : Nat
  items   : List String
  total   : Nat
  deriving DecidableEq, Repr

structure Input where
  orderId : Nat
  deriving DecidableEq, Repr

structure Output where
  sent : Bool
  details : Order
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderId > 0
  post := fun i o => o.sent = true ∧
                     o.details = { id := i.orderId, items := [], total := 0 } -- Assume no items and total 0 for simplicity
end L0_3_4_3_s3

namespace L0_3_5_3_s2
-- 3.5.3/S2
structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  deriving DecidableEq, Repr

structure Input where
  query          : String
  products       : List Product
  includeOutofStock : Bool
  deriving DecidableEq, Repr

structure Output where
  results : List Product
  deriving DecidableEq, Repr

-- an item may be returned: it matches the query, and it is not filtered out (out of stock if not included)
def Wanted (i : Input) (it : Product) : Bool :=
  it.name.toLower.contains i.query.toLower && (i.includeOutofStock || 0 < it.stock)

def Spec : Contract Input Output where
  pre  := fun i => i.query ≠ ""
  post := fun i o =>
    (∀ it ∈ o.results, it ∈ i.products ∧ Wanted i it = true) ∧
    (o.results.length < 100 → ∀ it ∈ i.products, Wanted i it = true → it ∈ o.results) ∧
    o.results.length ≤ 100 ∧
    List.Pairwise (fun a b => a.price ≤ b.price) o.results
end L0_3_5_3_s2

namespace L0_5_1_r5
-- 5.1/R5
structure Input where
  product : String
  items   : List String
  deriving DecidableEq, Repr

structure Output where
  results : List String
  elapsedMicros : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.product ≠ ""
  post := fun i o => (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
                     (o.results.length > 0 → o.elapsedMicros < 1000000)
end L0_5_1_r5

namespace L0_5_3_r3
-- 5.3/R3
structure Input where
  customerData : List String
  encryptedData : List String
  deriving DecidableEq, Repr

structure Output where
  encryptedData : List String
  deriving DecidableEq, Repr

-- A simple encryption function
def encrypt (s : String) : String := "加密" ++ s

def Spec : Contract Input Output where
  pre  := fun i => true
  post := fun i o => o.encryptedData.length = i.customerData.length ∧
                     ∀ s ∈ i.customerData, s ≠ "" →
                     o.encryptedData.contains (encrypt s) = true
end L0_5_3_r3

namespace L0_5_3_r5
-- 5.3/R5
structure Account where
  username : String
  password : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  password : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  accepted : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o =>
    (o.accepted = true ↔
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts < 3 ∧ a.password = i.password)) ∧
    (o.accepted = false →
      ∃ a ∈ i.accounts, a.username = i.username ∧
      (a.failedAttempts = 3 ∨ a.failedAttempts + 1 = 3))
end L0_5_3_r5

namespace L0_5_5_r5
-- 5.5/R5
structure Input where
  email : String
  deriving DecidableEq, Repr

structure Output where
  exists_ : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ ""
  post := fun i o => o.exists_ = true ↔ i.email.toList.all Char.isAlphanum = true ∧
                     i.email.contains '@' ∧ i.email.contains '.' ∧
                     i.email.length ≥ 6
end L0_5_5_r5

namespace L0_ci_1
-- CI-1
structure Input where
  customerEmail : String
  items         : List String
  shippingAddr  : String
  trackingNum   : String
  deriving DecidableEq, Repr

structure Output where
  sentEmail : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
  post := fun i o => o.sentEmail = true ↔
    (i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ "")
end L0_ci_1

namespace L0_dd_credit_card_no
-- DD-credit-card-no
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.raw.length = 16 ∧
    i.raw.toList.all Char.isDigit = true
end L0_dd_credit_card_no

namespace L0_dd_e_mail_id
-- DD-e-mail-id
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    i.raw.length = 50 ∧
    i.raw.toList.all Char.isAlphanum = true
end L0_dd_e_mail_id

namespace L0_dd_item_id
-- DD-item-id
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 7) ∧
    i.raw.toList.all (·.isAlphanum) = true
end L0_dd_item_id

namespace L0_dd_item_name
-- DD-item-name
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 50 ∧
     i.raw.toList.all (·.isAlpha) = true)
end L0_dd_item_name

namespace L0_dd_name
-- DD-name
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧
     i.raw.toList.all (·.isAlpha) = true)
end L0_dd_name

namespace L0_dd_order_no
-- DD-order-no
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 9) ∧
    (i.raw.toList.all Char.isAlphanum = true)
end L0_dd_order_no

namespace L0_dd_password
-- DD-password
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10 ∧
     i.raw.toList.all (·.isAlphanum) = true)
end L0_dd_password

namespace L0_dd_price
-- DD-price
structure Input where
  value : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.value ≤ 9999
end L0_dd_price

namespace L0_dd_quantity
-- DD-quantity
structure Input where
  value : Nat
  max_ref : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ 1 ≤ i.value ∧ i.value ≤ i.max_ref
end L0_dd_quantity

namespace L0_dd_text_description
-- DD-text-description
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧
     i.raw.toList.all (·.isAlpha) = true)
end L0_dd_text_description

namespace L0_dd_total
-- DD-total
structure Input where
  value : Nat
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔ i.value ≤ 9999
end L0_dd_total

namespace L0_dd_tracking_no
-- DD-tracking-no
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (i.raw.length = 20 ∧
     i.raw.toList.all Char.isAlphanum = true)
end L0_dd_tracking_no

namespace L0_dd_user_id
-- DD-user-id
structure Input where
  raw : String
  deriving DecidableEq, Repr

structure Output where
  valid : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun _ => True
  post := fun i o => o.valid = true ↔
    (4 ≤ i.raw.length ∧ i.raw.length ≤ 10) ∧
    i.raw.toList.all Char.isAlphanum = true
end L0_dd_user_id

namespace L0_si_1_2
-- SI-1.2
structure Item where
  name   : String
  count  : Nat
  deriving DecidableEq, Repr

structure Input where
  orderedItems : List Item
  deriving DecidableEq, Repr

structure Output where
  success  : Bool
  updatedItems : List Item
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.orderedItems.Nodup
  post := fun i o => (o.success = true ↔
    ∀ it ∈ i.orderedItems, ∃ uit ∈ o.updatedItems, uit.name = it.name ∧ uit.count = it.count + 1)
end L0_si_1_2

namespace L0_uc_administrator_add_user
-- UC-administrator-add-user
structure Account where
  username : String
  password : String
  role     : String
  privileges : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  role     : String
  privileges : String
  isCustomer : Bool
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  role     : String
  privileges : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧
                 (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
                 i.isCustomer
  post := fun i o => (o.username = i.username ∧ o.password = i.password ∧
                      o.role = i.role ∧ o.privileges = i.privileges) ↔
                    (i.isCustomer ∧
                     o.username ≠ "" ∧ o.password ≠ "" ∧
                     o.role = "customer" ∧ o.privileges ≠ "")
end L0_uc_administrator_add_user

namespace L0_uc_administrator_change_user_properties
-- UC-administrator-change-user-properties
structure User where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

structure Input where
  username : String
  newPassword : String
  newPrivileges : Nat
  deriving DecidableEq, Repr

structure Output where
  username : String
  password : String
  privileges : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.username = i.username ∧
                     o.password = i.newPassword ∧
                     o.privileges = i.newPrivileges
end L0_uc_administrator_change_user_properties

namespace L0_uc_administrator_login_administrator
-- UC-administrator-login-administrator
structure Account where
  username : String
  password : String
  email    : String
  role     : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  role     : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

structure Output where
  username : String
  role     : String
  session  : String
  failedAttempts : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.role = "Administrator"
  post := fun i o => o.role = "Administrator" ∧
                     (o.failedAttempts = i.failedAttempts + 1 ↔ i.password ≠ "correctPassword") ∧
                     (o.session ≠ "" ↔ i.failedAttempts < 3) ∧
                     (o.username = i.username)
end L0_uc_administrator_login_administrator

namespace L0_uc_administrator_logout_administrator
-- UC-administrator-logout-administrator
structure Session where
  cookie : String
  deriving DecidableEq, Repr

structure Input where
  cookie : String
  logged_in : Bool
  deriving DecidableEq, Repr

structure Output where
  cookie : String
  logged_in : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.logged_in = true
  post := fun i o => o.logged_in = false ∧ o.cookie = i.cookie
end L0_uc_administrator_logout_administrator

namespace L0_uc_administrator_remove_plug_ins
-- UC-administrator-remove-plug-ins
structure PlugIn where
  name : String
  active : Bool
  deriving DecidableEq, Repr

structure Input where
  plugIns : List PlugIn
  name    : String
  deriving DecidableEq, Repr

structure Output where
  plugIns : List PlugIn
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.plugIns.Nodup
  post := fun i o => 
    (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
    o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
    o.plugIns.Nodup
end L0_uc_administrator_remove_plug_ins

namespace L0_uc_administrator_remove_user
-- UC-administrator-remove-user
structure Account where
  username : String
  deriving DecidableEq, Repr

structure Input where
  accounts : List Account
  username : String
  deriving DecidableEq, Repr

structure Output where
  accounts : List Account
  deleted  : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ ""
  post := fun i o => o.deleted = true ∧
                     (∃ a ∈ i.accounts, a.username = i.username) ∧
                     (o.accounts = i.accounts.filter (fun a => a.username ≠ i.username))
end L0_uc_administrator_remove_user

namespace L0_uc_customer_add_item_to_cart
-- UC-customer-add-item-to-cart
structure Input where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  items    : List String
  cookie   : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.items = i.items ∧
                     o.cookie ≠ ""
end L0_uc_customer_add_item_to_cart

namespace L0_uc_customer_edit_customer_details
-- UC-customer-edit-customer-details
structure Account where
  username : String
  password : String
  email    : String
  phone    : String
  deriving DecidableEq, Repr

structure Input where
  signedIn : Bool
  changes  : Account
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  changes  : Account
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = i.signedIn ∧
                     o.changes.username = i.changes.username ∧
                     o.changes.password = i.changes.password ∧
                     o.changes.email = i.changes.email ∧
                     o.changes.phone = i.changes.phone
end L0_uc_customer_edit_customer_details

namespace L0_uc_customer_login_customer
-- UC-customer-login-customer
structure Account where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Input where
  username : String
  password : String
  email    : String
  account  : Account
  deriving DecidableEq, Repr

structure Output where
  logged : Bool
  cookie : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.email ≠ "" -- Customer account must be registered
  post := fun i o => (o.logged = true ↔ i.password = i.account.password) ∧
                     (o.logged = false ↔ i.password ≠ i.account.password) ∧
                     (o.cookie ≠ "" ↔ o.logged = true)
end L0_uc_customer_login_customer

namespace L0_uc_customer_logout_customer
-- UC-customer-logout-customer
structure Input where
  signedIn : Bool
  deriving DecidableEq, Repr

structure Output where
  signedIn : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.signedIn = true
  post := fun i o => o.signedIn = false
end L0_uc_customer_logout_customer

namespace L0_uc_customer_register_customer
-- UC-customer-register-customer
structure Customer where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Input where
  name   : String
  email  : String
  deriving DecidableEq, Repr

structure Output where
  registered : Bool
  cookie     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ i.email ≠ ""
  post := fun i o => (o.registered = true ↔
    i.name ≠ "" ∧ i.email ≠ "") ∧
    o.cookie ≠ ""
end L0_uc_customer_register_customer

namespace L0_uc_sales_person_add_product
-- UC-sales-person-add-product
structure Product where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

structure Input where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

structure Output where
  name : String
  price : Nat
  description : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price
  post := fun i o => o.name = i.name ∧ o.price = i.price ∧ o.description = i.description
end L0_uc_sales_person_add_product

namespace L0_uc_sales_person_login_sales_person
-- UC-sales-person-login-sales-person
structure Input where
  username : String
  password : String
  email    : String
  deriving DecidableEq, Repr

structure Output where
  loggedIn : Bool
  cookie   : Option String
  emailSent : Bool
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""
  post := fun i o => o.loggedIn = true ↔
    (i.username = "registered_username" ∧ i.password = "registered_password") ∧
    (o.cookie = some "session_cookie" ↔ i.username = "registered_username") ∧
    (o.emailSent = true ↔ i.password ≠ "registered_password")
end L0_uc_sales_person_login_sales_person

namespace L0_uc_sales_person_remove_product
-- UC-sales-person-remove-product
structure Product where
  name   : String
  price  : Nat
  deriving DecidableEq, Repr

structure Input where
  products : List Product
  name     : String
  price    : Nat
  deriving DecidableEq, Repr

structure Output where
  products : List Product
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.products.Nodup
  post := fun i o => o.products = i.products.filter (fun p => p.name ≠ i.name ∧ p.price ≠ i.price)
end L0_uc_sales_person_remove_product

namespace L0_uc_sales_person_update_product_attributes
-- UC-sales-person-update-product-attributes
structure Product where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Input where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

structure Output where
  name   : String
  price  : Nat
  stock  : Nat
  rating : Nat
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
  post := fun i o => o.name = i.name ∧
                     o.price = i.price ∧
                     o.stock = i.stock ∧
                     o.rating = i.rating
end L0_uc_sales_person_update_product_attributes

/-- Messages of AccountSys: a request to and a response from each operation. -/
inductive AccountSysMsg where
  | req_1_4_s2 (i : L0_1_4_s2.Input)
  | res_1_4_s2 (o : L0_1_4_s2.Output)
  | req_1_4_s3 (i : L0_1_4_s3.Input)
  | res_1_4_s3 (o : L0_1_4_s3.Output)
  | req_1_4_s4 (i : L0_1_4_s4.Input)
  | res_1_4_s4 (o : L0_1_4_s4.Output)
  | req_3_1_3_s1 (i : L0_3_1_3_s1.Input)
  | res_3_1_3_s1 (o : L0_3_1_3_s1.Output)
  | req_3_1_3_s2 (i : L0_3_1_3_s2.Input)
  | res_3_1_3_s2 (o : L0_3_1_3_s2.Output)
  | req_3_1_3_s3 (i : L0_3_1_3_s3.Input)
  | res_3_1_3_s3 (o : L0_3_1_3_s3.Output)
  | req_3_2_3_s2 (i : L0_3_2_3_s2.Input)
  | res_3_2_3_s2 (o : L0_3_2_3_s2.Output)
  | req_3_3_3_s1 (i : L0_3_3_3_s1.Input)
  | res_3_3_3_s1 (o : L0_3_3_3_s1.Output)
  | req_3_3_3_s2 (i : L0_3_3_3_s2.Input)
  | res_3_3_3_s2 (o : L0_3_3_3_s2.Output)
  | req_3_3_3_s3 (i : L0_3_3_3_s3.Input)
  | res_3_3_3_s3 (o : L0_3_3_3_s3.Output)
  | req_3_4_3_s1 (i : L0_3_4_3_s1.Input)
  | res_3_4_3_s1 (o : L0_3_4_3_s1.Output)
  | req_3_4_3_s2 (i : L0_3_4_3_s2.Input)
  | res_3_4_3_s2 (o : L0_3_4_3_s2.Output)
  | req_3_4_3_s3 (i : L0_3_4_3_s3.Input)
  | res_3_4_3_s3 (o : L0_3_4_3_s3.Output)
  | req_3_5_3_s2 (i : L0_3_5_3_s2.Input)
  | res_3_5_3_s2 (o : L0_3_5_3_s2.Output)
  | req_5_1_r5 (i : L0_5_1_r5.Input)
  | res_5_1_r5 (o : L0_5_1_r5.Output)
  | req_5_3_r3 (i : L0_5_3_r3.Input)
  | res_5_3_r3 (o : L0_5_3_r3.Output)
  | req_5_3_r5 (i : L0_5_3_r5.Input)
  | res_5_3_r5 (o : L0_5_3_r5.Output)
  | req_5_5_r5 (i : L0_5_5_r5.Input)
  | res_5_5_r5 (o : L0_5_5_r5.Output)
  | req_ci_1 (i : L0_ci_1.Input)
  | res_ci_1 (o : L0_ci_1.Output)
  | req_dd_credit_card_no (i : L0_dd_credit_card_no.Input)
  | res_dd_credit_card_no (o : L0_dd_credit_card_no.Output)
  | req_dd_e_mail_id (i : L0_dd_e_mail_id.Input)
  | res_dd_e_mail_id (o : L0_dd_e_mail_id.Output)
  | req_dd_item_id (i : L0_dd_item_id.Input)
  | res_dd_item_id (o : L0_dd_item_id.Output)
  | req_dd_item_name (i : L0_dd_item_name.Input)
  | res_dd_item_name (o : L0_dd_item_name.Output)
  | req_dd_name (i : L0_dd_name.Input)
  | res_dd_name (o : L0_dd_name.Output)
  | req_dd_order_no (i : L0_dd_order_no.Input)
  | res_dd_order_no (o : L0_dd_order_no.Output)
  | req_dd_password (i : L0_dd_password.Input)
  | res_dd_password (o : L0_dd_password.Output)
  | req_dd_price (i : L0_dd_price.Input)
  | res_dd_price (o : L0_dd_price.Output)
  | req_dd_quantity (i : L0_dd_quantity.Input)
  | res_dd_quantity (o : L0_dd_quantity.Output)
  | req_dd_text_description (i : L0_dd_text_description.Input)
  | res_dd_text_description (o : L0_dd_text_description.Output)
  | req_dd_total (i : L0_dd_total.Input)
  | res_dd_total (o : L0_dd_total.Output)
  | req_dd_tracking_no (i : L0_dd_tracking_no.Input)
  | res_dd_tracking_no (o : L0_dd_tracking_no.Output)
  | req_dd_user_id (i : L0_dd_user_id.Input)
  | res_dd_user_id (o : L0_dd_user_id.Output)
  | req_si_1_2 (i : L0_si_1_2.Input)
  | res_si_1_2 (o : L0_si_1_2.Output)
  | req_uc_administrator_add_user (i : L0_uc_administrator_add_user.Input)
  | res_uc_administrator_add_user (o : L0_uc_administrator_add_user.Output)
  | req_uc_administrator_change_user_properties (i : L0_uc_administrator_change_user_properties.Input)
  | res_uc_administrator_change_user_properties (o : L0_uc_administrator_change_user_properties.Output)
  | req_uc_administrator_login_administrator (i : L0_uc_administrator_login_administrator.Input)
  | res_uc_administrator_login_administrator (o : L0_uc_administrator_login_administrator.Output)
  | req_uc_administrator_logout_administrator (i : L0_uc_administrator_logout_administrator.Input)
  | res_uc_administrator_logout_administrator (o : L0_uc_administrator_logout_administrator.Output)
  | req_uc_administrator_remove_plug_ins (i : L0_uc_administrator_remove_plug_ins.Input)
  | res_uc_administrator_remove_plug_ins (o : L0_uc_administrator_remove_plug_ins.Output)
  | req_uc_administrator_remove_user (i : L0_uc_administrator_remove_user.Input)
  | res_uc_administrator_remove_user (o : L0_uc_administrator_remove_user.Output)
  | req_uc_customer_add_item_to_cart (i : L0_uc_customer_add_item_to_cart.Input)
  | res_uc_customer_add_item_to_cart (o : L0_uc_customer_add_item_to_cart.Output)
  | req_uc_customer_edit_customer_details (i : L0_uc_customer_edit_customer_details.Input)
  | res_uc_customer_edit_customer_details (o : L0_uc_customer_edit_customer_details.Output)
  | req_uc_customer_login_customer (i : L0_uc_customer_login_customer.Input)
  | res_uc_customer_login_customer (o : L0_uc_customer_login_customer.Output)
  | req_uc_customer_logout_customer (i : L0_uc_customer_logout_customer.Input)
  | res_uc_customer_logout_customer (o : L0_uc_customer_logout_customer.Output)
  | req_uc_customer_register_customer (i : L0_uc_customer_register_customer.Input)
  | res_uc_customer_register_customer (o : L0_uc_customer_register_customer.Output)
  | req_uc_sales_person_add_product (i : L0_uc_sales_person_add_product.Input)
  | res_uc_sales_person_add_product (o : L0_uc_sales_person_add_product.Output)
  | req_uc_sales_person_login_sales_person (i : L0_uc_sales_person_login_sales_person.Input)
  | res_uc_sales_person_login_sales_person (o : L0_uc_sales_person_login_sales_person.Output)
  | req_uc_sales_person_remove_product (i : L0_uc_sales_person_remove_product.Input)
  | res_uc_sales_person_remove_product (o : L0_uc_sales_person_remove_product.Output)
  | req_uc_sales_person_update_product_attributes (i : L0_uc_sales_person_update_product_attributes.Input)
  | res_uc_sales_person_update_product_attributes (o : L0_uc_sales_person_update_product_attributes.Output)

/-- The system spec of AccountSys: every L0 spec of the group, one case per operation. -/
def AccountSysSystemSpec : Contract AccountSysMsg AccountSysMsg where
  pre := fun m => match m with
    | .req_1_4_s2 i => L0_1_4_s2.Spec.pre i
    | .req_1_4_s3 i => L0_1_4_s3.Spec.pre i
    | .req_1_4_s4 i => L0_1_4_s4.Spec.pre i
    | .req_3_1_3_s1 i => L0_3_1_3_s1.Spec.pre i
    | .req_3_1_3_s2 i => L0_3_1_3_s2.Spec.pre i
    | .req_3_1_3_s3 i => L0_3_1_3_s3.Spec.pre i
    | .req_3_2_3_s2 i => L0_3_2_3_s2.Spec.pre i
    | .req_3_3_3_s1 i => L0_3_3_3_s1.Spec.pre i
    | .req_3_3_3_s2 i => L0_3_3_3_s2.Spec.pre i
    | .req_3_3_3_s3 i => L0_3_3_3_s3.Spec.pre i
    | .req_3_4_3_s1 i => L0_3_4_3_s1.Spec.pre i
    | .req_3_4_3_s2 i => L0_3_4_3_s2.Spec.pre i
    | .req_3_4_3_s3 i => L0_3_4_3_s3.Spec.pre i
    | .req_3_5_3_s2 i => L0_3_5_3_s2.Spec.pre i
    | .req_5_1_r5 i => L0_5_1_r5.Spec.pre i
    | .req_5_3_r3 i => L0_5_3_r3.Spec.pre i
    | .req_5_3_r5 i => L0_5_3_r5.Spec.pre i
    | .req_5_5_r5 i => L0_5_5_r5.Spec.pre i
    | .req_ci_1 i => L0_ci_1.Spec.pre i
    | .req_dd_credit_card_no i => L0_dd_credit_card_no.Spec.pre i
    | .req_dd_e_mail_id i => L0_dd_e_mail_id.Spec.pre i
    | .req_dd_item_id i => L0_dd_item_id.Spec.pre i
    | .req_dd_item_name i => L0_dd_item_name.Spec.pre i
    | .req_dd_name i => L0_dd_name.Spec.pre i
    | .req_dd_order_no i => L0_dd_order_no.Spec.pre i
    | .req_dd_password i => L0_dd_password.Spec.pre i
    | .req_dd_price i => L0_dd_price.Spec.pre i
    | .req_dd_quantity i => L0_dd_quantity.Spec.pre i
    | .req_dd_text_description i => L0_dd_text_description.Spec.pre i
    | .req_dd_total i => L0_dd_total.Spec.pre i
    | .req_dd_tracking_no i => L0_dd_tracking_no.Spec.pre i
    | .req_dd_user_id i => L0_dd_user_id.Spec.pre i
    | .req_si_1_2 i => L0_si_1_2.Spec.pre i
    | .req_uc_administrator_add_user i => L0_uc_administrator_add_user.Spec.pre i
    | .req_uc_administrator_change_user_properties i => L0_uc_administrator_change_user_properties.Spec.pre i
    | .req_uc_administrator_login_administrator i => L0_uc_administrator_login_administrator.Spec.pre i
    | .req_uc_administrator_logout_administrator i => L0_uc_administrator_logout_administrator.Spec.pre i
    | .req_uc_administrator_remove_plug_ins i => L0_uc_administrator_remove_plug_ins.Spec.pre i
    | .req_uc_administrator_remove_user i => L0_uc_administrator_remove_user.Spec.pre i
    | .req_uc_customer_add_item_to_cart i => L0_uc_customer_add_item_to_cart.Spec.pre i
    | .req_uc_customer_edit_customer_details i => L0_uc_customer_edit_customer_details.Spec.pre i
    | .req_uc_customer_login_customer i => L0_uc_customer_login_customer.Spec.pre i
    | .req_uc_customer_logout_customer i => L0_uc_customer_logout_customer.Spec.pre i
    | .req_uc_customer_register_customer i => L0_uc_customer_register_customer.Spec.pre i
    | .req_uc_sales_person_add_product i => L0_uc_sales_person_add_product.Spec.pre i
    | .req_uc_sales_person_login_sales_person i => L0_uc_sales_person_login_sales_person.Spec.pre i
    | .req_uc_sales_person_remove_product i => L0_uc_sales_person_remove_product.Spec.pre i
    | .req_uc_sales_person_update_product_attributes i => L0_uc_sales_person_update_product_attributes.Spec.pre i
    | _ => False
  post := fun m m' => match m with
    | .req_1_4_s2 i => ∃ o, m' = .res_1_4_s2 o ∧ L0_1_4_s2.Spec.post i o
    | .req_1_4_s3 i => ∃ o, m' = .res_1_4_s3 o ∧ L0_1_4_s3.Spec.post i o
    | .req_1_4_s4 i => ∃ o, m' = .res_1_4_s4 o ∧ L0_1_4_s4.Spec.post i o
    | .req_3_1_3_s1 i => ∃ o, m' = .res_3_1_3_s1 o ∧ L0_3_1_3_s1.Spec.post i o
    | .req_3_1_3_s2 i => ∃ o, m' = .res_3_1_3_s2 o ∧ L0_3_1_3_s2.Spec.post i o
    | .req_3_1_3_s3 i => ∃ o, m' = .res_3_1_3_s3 o ∧ L0_3_1_3_s3.Spec.post i o
    | .req_3_2_3_s2 i => ∃ o, m' = .res_3_2_3_s2 o ∧ L0_3_2_3_s2.Spec.post i o
    | .req_3_3_3_s1 i => ∃ o, m' = .res_3_3_3_s1 o ∧ L0_3_3_3_s1.Spec.post i o
    | .req_3_3_3_s2 i => ∃ o, m' = .res_3_3_3_s2 o ∧ L0_3_3_3_s2.Spec.post i o
    | .req_3_3_3_s3 i => ∃ o, m' = .res_3_3_3_s3 o ∧ L0_3_3_3_s3.Spec.post i o
    | .req_3_4_3_s1 i => ∃ o, m' = .res_3_4_3_s1 o ∧ L0_3_4_3_s1.Spec.post i o
    | .req_3_4_3_s2 i => ∃ o, m' = .res_3_4_3_s2 o ∧ L0_3_4_3_s2.Spec.post i o
    | .req_3_4_3_s3 i => ∃ o, m' = .res_3_4_3_s3 o ∧ L0_3_4_3_s3.Spec.post i o
    | .req_3_5_3_s2 i => ∃ o, m' = .res_3_5_3_s2 o ∧ L0_3_5_3_s2.Spec.post i o
    | .req_5_1_r5 i => ∃ o, m' = .res_5_1_r5 o ∧ L0_5_1_r5.Spec.post i o
    | .req_5_3_r3 i => ∃ o, m' = .res_5_3_r3 o ∧ L0_5_3_r3.Spec.post i o
    | .req_5_3_r5 i => ∃ o, m' = .res_5_3_r5 o ∧ L0_5_3_r5.Spec.post i o
    | .req_5_5_r5 i => ∃ o, m' = .res_5_5_r5 o ∧ L0_5_5_r5.Spec.post i o
    | .req_ci_1 i => ∃ o, m' = .res_ci_1 o ∧ L0_ci_1.Spec.post i o
    | .req_dd_credit_card_no i => ∃ o, m' = .res_dd_credit_card_no o ∧ L0_dd_credit_card_no.Spec.post i o
    | .req_dd_e_mail_id i => ∃ o, m' = .res_dd_e_mail_id o ∧ L0_dd_e_mail_id.Spec.post i o
    | .req_dd_item_id i => ∃ o, m' = .res_dd_item_id o ∧ L0_dd_item_id.Spec.post i o
    | .req_dd_item_name i => ∃ o, m' = .res_dd_item_name o ∧ L0_dd_item_name.Spec.post i o
    | .req_dd_name i => ∃ o, m' = .res_dd_name o ∧ L0_dd_name.Spec.post i o
    | .req_dd_order_no i => ∃ o, m' = .res_dd_order_no o ∧ L0_dd_order_no.Spec.post i o
    | .req_dd_password i => ∃ o, m' = .res_dd_password o ∧ L0_dd_password.Spec.post i o
    | .req_dd_price i => ∃ o, m' = .res_dd_price o ∧ L0_dd_price.Spec.post i o
    | .req_dd_quantity i => ∃ o, m' = .res_dd_quantity o ∧ L0_dd_quantity.Spec.post i o
    | .req_dd_text_description i => ∃ o, m' = .res_dd_text_description o ∧ L0_dd_text_description.Spec.post i o
    | .req_dd_total i => ∃ o, m' = .res_dd_total o ∧ L0_dd_total.Spec.post i o
    | .req_dd_tracking_no i => ∃ o, m' = .res_dd_tracking_no o ∧ L0_dd_tracking_no.Spec.post i o
    | .req_dd_user_id i => ∃ o, m' = .res_dd_user_id o ∧ L0_dd_user_id.Spec.post i o
    | .req_si_1_2 i => ∃ o, m' = .res_si_1_2 o ∧ L0_si_1_2.Spec.post i o
    | .req_uc_administrator_add_user i => ∃ o, m' = .res_uc_administrator_add_user o ∧ L0_uc_administrator_add_user.Spec.post i o
    | .req_uc_administrator_change_user_properties i => ∃ o, m' = .res_uc_administrator_change_user_properties o ∧ L0_uc_administrator_change_user_properties.Spec.post i o
    | .req_uc_administrator_login_administrator i => ∃ o, m' = .res_uc_administrator_login_administrator o ∧ L0_uc_administrator_login_administrator.Spec.post i o
    | .req_uc_administrator_logout_administrator i => ∃ o, m' = .res_uc_administrator_logout_administrator o ∧ L0_uc_administrator_logout_administrator.Spec.post i o
    | .req_uc_administrator_remove_plug_ins i => ∃ o, m' = .res_uc_administrator_remove_plug_ins o ∧ L0_uc_administrator_remove_plug_ins.Spec.post i o
    | .req_uc_administrator_remove_user i => ∃ o, m' = .res_uc_administrator_remove_user o ∧ L0_uc_administrator_remove_user.Spec.post i o
    | .req_uc_customer_add_item_to_cart i => ∃ o, m' = .res_uc_customer_add_item_to_cart o ∧ L0_uc_customer_add_item_to_cart.Spec.post i o
    | .req_uc_customer_edit_customer_details i => ∃ o, m' = .res_uc_customer_edit_customer_details o ∧ L0_uc_customer_edit_customer_details.Spec.post i o
    | .req_uc_customer_login_customer i => ∃ o, m' = .res_uc_customer_login_customer o ∧ L0_uc_customer_login_customer.Spec.post i o
    | .req_uc_customer_logout_customer i => ∃ o, m' = .res_uc_customer_logout_customer o ∧ L0_uc_customer_logout_customer.Spec.post i o
    | .req_uc_customer_register_customer i => ∃ o, m' = .res_uc_customer_register_customer o ∧ L0_uc_customer_register_customer.Spec.post i o
    | .req_uc_sales_person_add_product i => ∃ o, m' = .res_uc_sales_person_add_product o ∧ L0_uc_sales_person_add_product.Spec.post i o
    | .req_uc_sales_person_login_sales_person i => ∃ o, m' = .res_uc_sales_person_login_sales_person o ∧ L0_uc_sales_person_login_sales_person.Spec.post i o
    | .req_uc_sales_person_remove_product i => ∃ o, m' = .res_uc_sales_person_remove_product o ∧ L0_uc_sales_person_remove_product.Spec.post i o
    | .req_uc_sales_person_update_product_attributes i => ∃ o, m' = .res_uc_sales_person_update_product_attributes o ∧ L0_uc_sales_person_update_product_attributes.Spec.post i o
    | _ => False

-- ===== component Inventory =====

def Inventory_pre_1_4_s2 (i : L0_1_4_s2.Input) : Prop := i.items = 100
def Inventory_post_1_4_s2 (i : L0_1_4_s2.Input) (o : L0_1_4_s2.Output) : Prop := o.items = i.items

def Inventory_pre_1_4_s3 (i : L0_1_4_s3.Input) : Prop := i.purchases.all (fun c => c.unique)
def Inventory_post_1_4_s3 (i : L0_1_4_s3.Input) (o : L0_1_4_s3.Output) : Prop := 
  o.inventory.length = i.inventory.length + i.purchases.length ∧
  ∀ c ∈ i.purchases, c ∈ o.inventory ∧ c.unique

def Inventory_pre_1_4_s4 (i : L0_1_4_s4.Input) : Prop := i.items ≥ 20000
def Inventory_post_1_4_s4 (i : L0_1_4_s4.Input) (o : L0_1_4_s4.Output) : Prop := o.items = i.items

def Inventory_pre_5_1_r5 (i : L0_5_1_r5.Input) : Prop := i.product ≠ ""
def Inventory_post_5_1_r5 (i : L0_5_1_r5.Input) (o : L0_5_1_r5.Output) : Prop := 
  (o.results.length = 0 ↔ o.elapsedMicros = 0) ∧
  (o.results.length > 0 → o.elapsedMicros < 1000000)

def Inventory_pre_si_1_2 (i : L0_si_1_2.Input) : Prop := i.orderedItems.Nodup
def Inventory_post_si_1_2 (i : L0_si_1_2.Input) (o : L0_si_1_2.Output) : Prop := 
  o.success = true ↔ ∀ it ∈ i.orderedItems, ∃ uit ∈ o.updatedItems, uit.name = it.name ∧ uit.count = it.count + 1

/-- Component Inventory: owns 1.4/S2, 1.4/S3, 1.4/S4, 5.1/R5, SI-1.2. -/
def InventoryContract : Contract AccountSysMsg AccountSysMsg where
  pre := fun m => match m with
    | .req_1_4_s2 i => Inventory_pre_1_4_s2 i
    | .req_1_4_s3 i => Inventory_pre_1_4_s3 i
    | .req_1_4_s4 i => Inventory_pre_1_4_s4 i
    | .req_3_1_3_s1 i => L0_3_1_3_s1.Spec.pre i
    | .req_3_1_3_s2 i => L0_3_1_3_s2.Spec.pre i
    | .req_3_1_3_s3 i => L0_3_1_3_s3.Spec.pre i
    | .req_3_2_3_s2 i => L0_3_2_3_s2.Spec.pre i
    | .req_3_3_3_s1 i => L0_3_3_3_s1.Spec.pre i
    | .req_3_3_3_s2 i => L0_3_3_3_s2.Spec.pre i
    | .req_3_3_3_s3 i => L0_3_3_3_s3.Spec.pre i
    | .req_3_4_3_s1 i => L0_3_4_3_s1.Spec.pre i
    | .req_3_4_3_s2 i => L0_3_4_3_s2.Spec.pre i
    | .req_3_4_3_s3 i => L0_3_4_3_s3.Spec.pre i
    | .req_3_5_3_s2 i => L0_3_5_3_s2.Spec.pre i
    | .req_5_1_r5 i => Inventory_pre_5_1_r5 i
    | .req_5_3_r3 i => L0_5_3_r3.Spec.pre i
    | .req_5_3_r5 i => L0_5_3_r5.Spec.pre i
    | .req_5_5_r5 i => L0_5_5_r5.Spec.pre i
    | .req_ci_1 i => L0_ci_1.Spec.pre i
    | .req_dd_credit_card_no i => L0_dd_credit_card_no.Spec.pre i
    | .req_dd_e_mail_id i => L0_dd_e_mail_id.Spec.pre i
    | .req_dd_item_id i => L0_dd_item_id.Spec.pre i
    | .req_dd_item_name i => L0_dd_item_name.Spec.pre i
    | .req_dd_name i => L0_dd_name.Spec.pre i
    | .req_dd_order_no i => L0_dd_order_no.Spec.pre i
    | .req_dd_password i => L0_dd_password.Spec.pre i
    | .req_dd_price i => L0_dd_price.Spec.pre i
    | .req_dd_quantity i => L0_dd_quantity.Spec.pre i
    | .req_dd_text_description i => L0_dd_text_description.Spec.pre i
    | .req_dd_total i => L0_dd_total.Spec.pre i
    | .req_dd_tracking_no i => L0_dd_tracking_no.Spec.pre i
    | .req_dd_user_id i => L0_dd_user_id.Spec.pre i
    | .req_si_1_2 i => Inventory_pre_si_1_2 i
    | .req_uc_administrator_add_user i => L0_uc_administrator_add_user.Spec.pre i
    | .req_uc_administrator_change_user_properties i => L0_uc_administrator_change_user_properties.Spec.pre i
    | .req_uc_administrator_login_administrator i => L0_uc_administrator_login_administrator.Spec.pre i
    | .req_uc_administrator_logout_administrator i => L0_uc_administrator_logout_administrator.Spec.pre i
    | .req_uc_administrator_remove_plug_ins i => L0_uc_administrator_remove_plug_ins.Spec.pre i
    | .req_uc_administrator_remove_user i => L0_uc_administrator_remove_user.Spec.pre i
    | .req_uc_customer_add_item_to_cart i => L0_uc_customer_add_item_to_cart.Spec.pre i
    | .req_uc_customer_edit_customer_details i => L0_uc_customer_edit_customer_details.Spec.pre i
    | .req_uc_customer_login_customer i => L0_uc_customer_login_customer.Spec.pre i
    | .req_uc_customer_logout_customer i => L0_uc_customer_logout_customer.Spec.pre i
    | .req_uc_customer_register_customer i => L0_uc_customer_register_customer.Spec.pre i
    | .req_uc_sales_person_add_product i => L0_uc_sales_person_add_product.Spec.pre i
    | .req_uc_sales_person_login_sales_person i => L0_uc_sales_person_login_sales_person.Spec.pre i
    | .req_uc_sales_person_remove_product i => L0_uc_sales_person_remove_product.Spec.pre i
    | .req_uc_sales_person_update_product_attributes i => L0_uc_sales_person_update_product_attributes.Spec.pre i
    | _ => True
  post := fun m m' => match m with
    | .req_1_4_s2 i => ∃ o, m' = .res_1_4_s2 o ∧ Inventory_post_1_4_s2 i o
    | .req_1_4_s3 i => ∃ o, m' = .res_1_4_s3 o ∧ Inventory_post_1_4_s3 i o
    | .req_1_4_s4 i => ∃ o, m' = .res_1_4_s4 o ∧ Inventory_post_1_4_s4 i o
    | .req_5_1_r5 i => ∃ o, m' = .res_5_1_r5 o ∧ Inventory_post_5_1_r5 i o
    | .req_si_1_2 i => ∃ o, m' = .res_si_1_2 o ∧ Inventory_post_si_1_2 i o
    | _ => m' = m

theorem trace_pre_Inventory_1_4_s2 : ∀ i : L0_1_4_s2.Input, L0_1_4_s2.Spec.pre i → Inventory_pre_1_4_s2 i := by
  intros
  first
  | (simp_all [Inventory_pre_1_4_s2, Inventory_post_1_4_s2, L0_1_4_s2.Spec, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_1_4_s2, Inventory_post_1_4_s2, L0_1_4_s2.Spec, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_1_4_s2 Inventory_post_1_4_s2 at *; simp_all)
  | (simp_all [Inventory_pre_1_4_s2, Inventory_post_1_4_s2, L0_1_4_s2.Spec, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_post_Inventory_1_4_s2 : ∀ (i : L0_1_4_s2.Input) (o : L0_1_4_s2.Output), L0_1_4_s2.Spec.pre i → Inventory_post_1_4_s2 i o → L0_1_4_s2.Spec.post i o := by
  intros
  first
  | (simp_all [Inventory_pre_1_4_s2, Inventory_post_1_4_s2, L0_1_4_s2.Spec, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_1_4_s2, Inventory_post_1_4_s2, L0_1_4_s2.Spec, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_1_4_s2 Inventory_post_1_4_s2 at *; simp_all)
  | (simp_all [Inventory_pre_1_4_s2, Inventory_post_1_4_s2, L0_1_4_s2.Spec, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_pre_Inventory_1_4_s3 : ∀ i : L0_1_4_s3.Input, L0_1_4_s3.Spec.pre i → Inventory_pre_1_4_s3 i := by
  intros
  first
  | (simp_all [Inventory_pre_1_4_s3, Inventory_post_1_4_s3, L0_1_4_s3.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_1_4_s3, Inventory_post_1_4_s3, L0_1_4_s3.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_1_4_s3 Inventory_post_1_4_s3 at *; simp_all)
  | (simp_all [Inventory_pre_1_4_s3, Inventory_post_1_4_s3, L0_1_4_s3.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_post_Inventory_1_4_s3 : ∀ (i : L0_1_4_s3.Input) (o : L0_1_4_s3.Output), L0_1_4_s3.Spec.pre i → Inventory_post_1_4_s3 i o → L0_1_4_s3.Spec.post i o := by
  intros
  first
  | (simp_all [Inventory_pre_1_4_s3, Inventory_post_1_4_s3, L0_1_4_s3.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_1_4_s3, Inventory_post_1_4_s3, L0_1_4_s3.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_1_4_s3 Inventory_post_1_4_s3 at *; simp_all)
  | (simp_all [Inventory_pre_1_4_s3, Inventory_post_1_4_s3, L0_1_4_s3.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_pre_Inventory_1_4_s4 : ∀ i : L0_1_4_s4.Input, L0_1_4_s4.Spec.pre i → Inventory_pre_1_4_s4 i := by
  intros
  first
  | (simp_all [Inventory_pre_1_4_s4, Inventory_post_1_4_s4, L0_1_4_s4.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_1_4_s4, Inventory_post_1_4_s4, L0_1_4_s4.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_1_4_s4 Inventory_post_1_4_s4 at *; simp_all)
  | (simp_all [Inventory_pre_1_4_s4, Inventory_post_1_4_s4, L0_1_4_s4.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_post_Inventory_1_4_s4 : ∀ (i : L0_1_4_s4.Input) (o : L0_1_4_s4.Output), L0_1_4_s4.Spec.pre i → Inventory_post_1_4_s4 i o → L0_1_4_s4.Spec.post i o := by
  intros
  first
  | (simp_all [Inventory_pre_1_4_s4, Inventory_post_1_4_s4, L0_1_4_s4.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_1_4_s4, Inventory_post_1_4_s4, L0_1_4_s4.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_1_4_s4 Inventory_post_1_4_s4 at *; simp_all)
  | (simp_all [Inventory_pre_1_4_s4, Inventory_post_1_4_s4, L0_1_4_s4.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_5_1_r5, Inventory_post_5_1_r5, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_pre_Inventory_5_1_r5 : ∀ i : L0_5_1_r5.Input, L0_5_1_r5.Spec.pre i → Inventory_pre_5_1_r5 i := by
  intros
  first
  | (simp_all [Inventory_pre_5_1_r5, Inventory_post_5_1_r5, L0_5_1_r5.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_5_1_r5, Inventory_post_5_1_r5, L0_5_1_r5.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_5_1_r5 Inventory_post_5_1_r5 at *; simp_all)
  | (simp_all [Inventory_pre_5_1_r5, Inventory_post_5_1_r5, L0_5_1_r5.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_post_Inventory_5_1_r5 : ∀ (i : L0_5_1_r5.Input) (o : L0_5_1_r5.Output), L0_5_1_r5.Spec.pre i → Inventory_post_5_1_r5 i o → L0_5_1_r5.Spec.post i o := by
  intros
  first
  | (simp_all [Inventory_pre_5_1_r5, Inventory_post_5_1_r5, L0_5_1_r5.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_si_1_2, Inventory_post_si_1_2]; done)
  | (simp_all [Inventory_pre_5_1_r5, Inventory_post_5_1_r5, L0_5_1_r5.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_si_1_2, Inventory_post_si_1_2]; omega)
  | (unfold Inventory_pre_5_1_r5 Inventory_post_5_1_r5 at *; simp_all)
  | (simp_all [Inventory_pre_5_1_r5, Inventory_post_5_1_r5, L0_5_1_r5.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_si_1_2, Inventory_post_si_1_2]; decide)

theorem trace_pre_Inventory_si_1_2 : ∀ i : L0_si_1_2.Input, L0_si_1_2.Spec.pre i → Inventory_pre_si_1_2 i := by
  intros
  first
  | (simp_all [Inventory_pre_si_1_2, Inventory_post_si_1_2, L0_si_1_2.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5]; done)
  | (simp_all [Inventory_pre_si_1_2, Inventory_post_si_1_2, L0_si_1_2.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5]; omega)
  | (unfold Inventory_pre_si_1_2 Inventory_post_si_1_2 at *; simp_all)
  | (simp_all [Inventory_pre_si_1_2, Inventory_post_si_1_2, L0_si_1_2.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5]; decide)

theorem trace_post_Inventory_si_1_2 : ∀ (i : L0_si_1_2.Input) (o : L0_si_1_2.Output), L0_si_1_2.Spec.pre i → Inventory_post_si_1_2 i o → L0_si_1_2.Spec.post i o := by
  intros
  first
  | (simp_all [Inventory_pre_si_1_2, Inventory_post_si_1_2, L0_si_1_2.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5]; done)
  | (simp_all [Inventory_pre_si_1_2, Inventory_post_si_1_2, L0_si_1_2.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5]; omega)
  | (unfold Inventory_pre_si_1_2 Inventory_post_si_1_2 at *; simp_all)
  | (simp_all [Inventory_pre_si_1_2, Inventory_post_si_1_2, L0_si_1_2.Spec, Inventory_pre_1_4_s2, Inventory_post_1_4_s2, Inventory_pre_1_4_s3, Inventory_post_1_4_s3, Inventory_pre_1_4_s4, Inventory_post_1_4_s4, Inventory_pre_5_1_r5, Inventory_post_5_1_r5]; decide)

-- ===== component Accounts =====

def Accounts_pre_3_1_3_s1 (i : L0_3_1_3_s1.Input) : Prop := i.email ≠ "" ∧ i.phone ≠ "" ∧ i.address ≠ ""
def Accounts_post_3_1_3_s1 (i : L0_3_1_3_s1.Input) (o : L0_3_1_3_s1.Output) : Prop := 
  (o.profileCreated = true ↔
    o.profile.name = i.name ∧ o.profile.email = i.email ∧
    o.profile.phone = i.phone ∧ o.profile.address = i.address ∧
    o.profile.purchaseHistory = i.purchaseHistory ∧
    o.profile.orderStatus = i.orderStatus) ∧
  o.profile.purchaseHistory.Nodup ∧
  o.profile.orderStatus = "confirmed"

def Accounts_pre_3_1_3_s2 (i : L0_3_1_3_s2.Input) : Prop := i.username ≠ "" ∧ i.password ≠ ""
def Accounts_post_3_1_3_s2 (i : L0_3_1_3_s2.Input) (o : L0_3_1_3_s2.Output) : Prop := 
  (o.logged = true ↔
    i.action = "login" ∧
    ∃ a ∈ i.accounts, a.username = i.username ∧ a.password = i.password) ∧
  (o.logged = false ↔
    (i.action = "logout" ∧ o.username = i.username) ∨
    (i.action = "register" ∧ i.username ∉ i.accounts.map (·.username)))

def Accounts_pre_3_1_3_s3 (i : L0_3_1_3_s3.Input) : Prop := True
def Accounts_post_3_1_3_s3 (i : L0_3_1_3_s3.Input) (o : L0_3_1_3_s3.Output) : Prop := 
  o.profiles = i.profiles ∧
  ∀ p ∈ o.profiles, p.name ≠ "" ∧
  p.email ≠ "" ∧
  p.creditCards.Nodup ∧
  p.addresses.Nodup

def Accounts_pre_3_2_3_s2 (i : L0_3_2_3_s2.Input) : Prop := i.categories.Nodup ∧ i.products.Nodup
def Accounts_post_3_2_3_s2 (i : L0_3_2_3_s2.Input) (o : L0_3_2_3_s2.Output) : Prop := 
  o.categories = i.categories ∧ o.products = i.products

def Accounts_pre_3_5_3_s2 (i : L0_3_5_3_s2.Input) : Prop := i.query ≠ ""
def Accounts_post_3_5_3_s2 (i : L0_3_5_3_s2.Input) (o : L0_3_5_3_s2.Output) : Prop := 
  (∀ it ∈ o.results, it ∈ i.products ∧ it.name.toLower.contains i.query.toLower ∧ (i.includeOutofStock || 0 < it.stock)) ∧
  (o.results.length < 100 → ∀ it ∈ i.products, it.name.toLower.contains i.query.toLower ∧ (i.includeOutofStock || 0 < it.stock) → it ∈ o.results) ∧
  o.results.length ≤ 100 ∧
  List.Pairwise (fun a b => a.price ≤ b.price) o.results

def Accounts_pre_5_3_r3 (i : L0_5_3_r3.Input) : Prop := true
def Accounts_post_5_3_r3 (i : L0_5_3_r3.Input) (o : L0_5_3_r3.Output) : Prop := 
  o.encryptedData.length = i.customerData.length ∧
  ∀ s ∈ i.customerData, s ≠ "" →
  o.encryptedData.contains (L0_5_3_r3.encrypt s) = true

def Accounts_pre_5_3_r5 (i : L0_5_3_r5.Input) : Prop := i.username ≠ ""
def Accounts_post_5_3_r5 (i : L0_5_3_r5.Input) (o : L0_5_3_r5.Output) : Prop := 
  (o.accepted = true ↔ 
    ∃ a ∈ i.accounts, a.username = i.username ∧ 
    (a.failedAttempts < 3 ∧ a.password = i.password)) ∧ 
  (o.accepted = false → 
    ∃ a ∈ i.accounts, a.username = i.username ∧ 
    (a.failedAttempts = 3 ∨ a.failedAttempts + 1 = 3))

def Accounts_pre_5_5_r5 (i : L0_5_5_r5.Input) : Prop := i.email ≠ ""
def Accounts_post_5_5_r5 (i : L0_5_5_r5.Input) (o : L0_5_5_r5.Output) : Prop := 
  o.exists_ = true ↔ i.email.toList.all Char.isAlphanum = true ∧
  i.email.contains '@' ∧ i.email.contains '.' ∧
  i.email.length ≥ 6

def Accounts_pre_uc_administrator_add_user (i : L0_uc_administrator_add_user.Input) : Prop := 
  i.username ≠ "" ∧ i.password ≠ "" ∧
  (i.role = "customer" ∨ i.role = "sales person" ∨ i.role = "administrator") ∧
  i.isCustomer

def Accounts_post_uc_administrator_add_user (i : L0_uc_administrator_add_user.Input) (o : L0_uc_administrator_add_user.Output) : Prop := 
  (o.username = i.username ∧ o.password = i.password ∧
   o.role = i.role ∧ o.privileges = i.privileges) ↔
  (i.isCustomer ∧
   o.username ≠ "" ∧ o.password ≠ "" ∧
   o.role = "customer" ∧ o.privileges ≠ "")

def Accounts_pre_uc_administrator_change_user_properties (i : L0_uc_administrator_change_user_properties.Input) : Prop := i.username ≠ ""
def Accounts_post_uc_administrator_change_user_properties (i : L0_uc_administrator_change_user_properties.Input) (o : L0_uc_administrator_change_user_properties.Output) : Prop := o.username = i.username ∧ o.password = i.newPassword ∧ o.privileges = i.newPrivileges

def Accounts_pre_uc_administrator_login_administrator (i : L0_uc_administrator_login_administrator.Input) : Prop := i.role = "Administrator"
def Accounts_post_uc_administrator_login_administrator (i : L0_uc_administrator_login_administrator.Input) (o : L0_uc_administrator_login_administrator.Output) : Prop := 
  o.role = "Administrator" ∧
  (o.failedAttempts = i.failedAttempts + 1 ↔ i.password ≠ "correctPassword") ∧
  (o.session ≠ "" ↔ i.failedAttempts < 3) ∧
  (o.username = i.username)

def Accounts_pre_uc_administrator_logout_administrator (i : L0_uc_administrator_logout_administrator.Input) : Prop := i.logged_in = true
def Accounts_post_uc_administrator_logout_administrator (i : L0_uc_administrator_logout_administrator.Input) (o : L0_uc_administrator_logout_administrator.Output) : Prop := o.logged_in = false ∧ o.cookie = i.cookie

def Accounts_pre_uc_administrator_remove_plug_ins (i : L0_uc_administrator_remove_plug_ins.Input) : Prop := i.name ≠ "" ∧ i.plugIns.Nodup
def Accounts_post_uc_administrator_remove_plug_ins (i : L0_uc_administrator_remove_plug_ins.Input) (o : L0_uc_administrator_remove_plug_ins.Output) : Prop := 
  (∃ p ∈ i.plugIns, p.name = i.name ∧ p.active = true) →
  o.plugIns = i.plugIns.filter (fun p => p.name ≠ i.name) ∧
  o.plugIns.Nodup

def Accounts_pre_uc_administrator_remove_user (i : L0_uc_administrator_remove_user.Input) : Prop := i.username ≠ ""
def Accounts_post_uc_administrator_remove_user (i : L0_uc_administrator_remove_user.Input) (o : L0_uc_administrator_remove_user.Output) : Prop := 
  o.deleted = true ∧
  (∃ a ∈ i.accounts, a.username = i.username) ∧
  (o.accounts = i.accounts.filter (fun a => a.username ≠ i.username))

def Accounts_pre_uc_customer_edit_customer_details (i : L0_uc_customer_edit_customer_details.Input) : Prop := i.signedIn = true
def Accounts_post_uc_customer_edit_customer_details (i : L0_uc_customer_edit_customer_details.Input) (o : L0_uc_customer_edit_customer_details.Output) : Prop := o.signedIn = i.signedIn ∧
  o.changes.username = i.changes.username ∧
  o.changes.password = i.changes.password ∧
  o.changes.email = i.changes.email ∧
  o.changes.phone = i.changes.phone

def Accounts_pre_uc_customer_login_customer (i : L0_uc_customer_login_customer.Input) : Prop := i.email ≠ ""
def Accounts_post_uc_customer_login_customer (i : L0_uc_customer_login_customer.Input) (o : L0_uc_customer_login_customer.Output) : Prop := 
  (o.logged = true ↔ i.password = i.account.password) ∧
  (o.logged = false ↔ i.password ≠ i.account.password) ∧
  (o.cookie ≠ "" ↔ o.logged = true)

def Accounts_pre_uc_customer_logout_customer (i : L0_uc_customer_logout_customer.Input) : Prop := i.signedIn = true
def Accounts_post_uc_customer_logout_customer (i : L0_uc_customer_logout_customer.Input) (o : L0_uc_customer_logout_customer.Output) : Prop := o.signedIn = false

def Accounts_pre_uc_customer_register_customer (i : L0_uc_customer_register_customer.Input) : Prop := 
  i.name ≠ "" ∧ i.email ≠ ""

def Accounts_post_uc_customer_register_customer (i : L0_uc_customer_register_customer.Input) (o : L0_uc_customer_register_customer.Output) : Prop := 
  (o.registered = true ↔ i.name ≠ "" ∧ i.email ≠ "") ∧ o.cookie ≠ ""

def Accounts_pre_uc_sales_person_add_product (i : L0_uc_sales_person_add_product.Input) : Prop := i.name ≠ "" ∧ 0 < i.price
def Accounts_post_uc_sales_person_add_product (i : L0_uc_sales_person_add_product.Input) (o : L0_uc_sales_person_add_product.Output) : Prop := o.name = i.name ∧ o.price = i.price ∧ o.description = i.description

def Accounts_pre_uc_sales_person_login_sales_person (i : L0_uc_sales_person_login_sales_person.Input) : Prop := 
  i.username ≠ "" ∧ i.password ≠ "" ∧ i.email ≠ ""

def Accounts_post_uc_sales_person_login_sales_person (i : L0_uc_sales_person_login_sales_person.Input) (o : L0_uc_sales_person_login_sales_person.Output) : Prop := 
  o.loggedIn = true ↔
  (i.username = "registered_username" ∧ i.password = "registered_password") ∧
  (o.cookie = some "session_cookie" ↔ i.username = "registered_username") ∧
  (o.emailSent = true ↔ i.password ≠ "registered_password")

def Accounts_pre_uc_sales_person_remove_product (i : L0_uc_sales_person_remove_product.Input) : Prop := i.products.Nodup
def Accounts_post_uc_sales_person_remove_product (i : L0_uc_sales_person_remove_product.Input) (o : L0_uc_sales_person_remove_product.Output) : Prop := o.products = i.products.filter (fun p => p.name ≠ i.name ∧ p.price ≠ i.price)

def Accounts_pre_uc_sales_person_update_product_attributes (i : L0_uc_sales_person_update_product_attributes.Input) : Prop := i.name ≠ "" ∧ 0 < i.price ∧ i.stock > 0 ∧ i.rating > 0
def Accounts_post_uc_sales_person_update_product_attributes (i : L0_uc_sales_person_update_product_attributes.Input) (o : L0_uc_sales_person_update_product_attributes.Output) : Prop := o.name = i.name ∧ o.price = i.price ∧ o.stock = i.stock ∧ o.rating = i.rating

/-- Component Accounts: owns 3.1.3/S1, 3.1.3/S2, 3.1.3/S3, 3.2.3/S2, 3.5.3/S2, 5.3/R3, 5.3/R5, 5.5/R5, UC-administrator-add-user, UC-administrator-change-user-properties, UC-administrator-login-administrator, UC-administrator-logout-administrator, UC-administrator-remove-plug-ins, UC-administrator-remove-user, UC-customer-edit-customer-details, UC-customer-login-customer, UC-customer-logout-customer, UC-customer-register-customer, UC-sales-person-add-product, UC-sales-person-login-sales-person, UC-sales-person-remove-product, UC-sales-person-update-product-attributes. -/
def AccountsContract : Contract AccountSysMsg AccountSysMsg where
  pre := fun m => match m with
    | .req_1_4_s2 i => L0_1_4_s2.Spec.pre i
    | .req_1_4_s3 i => L0_1_4_s3.Spec.pre i
    | .req_1_4_s4 i => L0_1_4_s4.Spec.pre i
    | .req_3_1_3_s1 i => Accounts_pre_3_1_3_s1 i
    | .req_3_1_3_s2 i => Accounts_pre_3_1_3_s2 i
    | .req_3_1_3_s3 i => Accounts_pre_3_1_3_s3 i
    | .req_3_2_3_s2 i => Accounts_pre_3_2_3_s2 i
    | .req_3_3_3_s1 i => L0_3_3_3_s1.Spec.pre i
    | .req_3_3_3_s2 i => L0_3_3_3_s2.Spec.pre i
    | .req_3_3_3_s3 i => L0_3_3_3_s3.Spec.pre i
    | .req_3_4_3_s1 i => L0_3_4_3_s1.Spec.pre i
    | .req_3_4_3_s2 i => L0_3_4_3_s2.Spec.pre i
    | .req_3_4_3_s3 i => L0_3_4_3_s3.Spec.pre i
    | .req_3_5_3_s2 i => Accounts_pre_3_5_3_s2 i
    | .req_5_1_r5 i => L0_5_1_r5.Spec.pre i
    | .req_5_3_r3 i => Accounts_pre_5_3_r3 i
    | .req_5_3_r5 i => Accounts_pre_5_3_r5 i
    | .req_5_5_r5 i => Accounts_pre_5_5_r5 i
    | .req_ci_1 i => L0_ci_1.Spec.pre i
    | .req_dd_credit_card_no i => L0_dd_credit_card_no.Spec.pre i
    | .req_dd_e_mail_id i => L0_dd_e_mail_id.Spec.pre i
    | .req_dd_item_id i => L0_dd_item_id.Spec.pre i
    | .req_dd_item_name i => L0_dd_item_name.Spec.pre i
    | .req_dd_name i => L0_dd_name.Spec.pre i
    | .req_dd_order_no i => L0_dd_order_no.Spec.pre i
    | .req_dd_password i => L0_dd_password.Spec.pre i
    | .req_dd_price i => L0_dd_price.Spec.pre i
    | .req_dd_quantity i => L0_dd_quantity.Spec.pre i
    | .req_dd_text_description i => L0_dd_text_description.Spec.pre i
    | .req_dd_total i => L0_dd_total.Spec.pre i
    | .req_dd_tracking_no i => L0_dd_tracking_no.Spec.pre i
    | .req_dd_user_id i => L0_dd_user_id.Spec.pre i
    | .req_si_1_2 i => L0_si_1_2.Spec.pre i
    | .req_uc_administrator_add_user i => Accounts_pre_uc_administrator_add_user i
    | .req_uc_administrator_change_user_properties i => Accounts_pre_uc_administrator_change_user_properties i
    | .req_uc_administrator_login_administrator i => Accounts_pre_uc_administrator_login_administrator i
    | .req_uc_administrator_logout_administrator i => Accounts_pre_uc_administrator_logout_administrator i
    | .req_uc_administrator_remove_plug_ins i => Accounts_pre_uc_administrator_remove_plug_ins i
    | .req_uc_administrator_remove_user i => Accounts_pre_uc_administrator_remove_user i
    | .req_uc_customer_add_item_to_cart i => L0_uc_customer_add_item_to_cart.Spec.pre i
    | .req_uc_customer_edit_customer_details i => Accounts_pre_uc_customer_edit_customer_details i
    | .req_uc_customer_login_customer i => Accounts_pre_uc_customer_login_customer i
    | .req_uc_customer_logout_customer i => Accounts_pre_uc_customer_logout_customer i
    | .req_uc_customer_register_customer i => Accounts_pre_uc_customer_register_customer i
    | .req_uc_sales_person_add_product i => Accounts_pre_uc_sales_person_add_product i
    | .req_uc_sales_person_login_sales_person i => Accounts_pre_uc_sales_person_login_sales_person i
    | .req_uc_sales_person_remove_product i => Accounts_pre_uc_sales_person_remove_product i
    | .req_uc_sales_person_update_product_attributes i => Accounts_pre_uc_sales_person_update_product_attributes i
    | _ => True
  post := fun m m' => match m with
    | .req_3_1_3_s1 i => ∃ o, m' = .res_3_1_3_s1 o ∧ Accounts_post_3_1_3_s1 i o
    | .req_3_1_3_s2 i => ∃ o, m' = .res_3_1_3_s2 o ∧ Accounts_post_3_1_3_s2 i o
    | .req_3_1_3_s3 i => ∃ o, m' = .res_3_1_3_s3 o ∧ Accounts_post_3_1_3_s3 i o
    | .req_3_2_3_s2 i => ∃ o, m' = .res_3_2_3_s2 o ∧ Accounts_post_3_2_3_s2 i o
    | .req_3_5_3_s2 i => ∃ o, m' = .res_3_5_3_s2 o ∧ Accounts_post_3_5_3_s2 i o
    | .req_5_3_r3 i => ∃ o, m' = .res_5_3_r3 o ∧ Accounts_post_5_3_r3 i o
    | .req_5_3_r5 i => ∃ o, m' = .res_5_3_r5 o ∧ Accounts_post_5_3_r5 i o
    | .req_5_5_r5 i => ∃ o, m' = .res_5_5_r5 o ∧ Accounts_post_5_5_r5 i o
    | .req_uc_administrator_add_user i => ∃ o, m' = .res_uc_administrator_add_user o ∧ Accounts_post_uc_administrator_add_user i o
    | .req_uc_administrator_change_user_properties i => ∃ o, m' = .res_uc_administrator_change_user_properties o ∧ Accounts_post_uc_administrator_change_user_properties i o
    | .req_uc_administrator_login_administrator i => ∃ o, m' = .res_uc_administrator_login_administrator o ∧ Accounts_post_uc_administrator_login_administrator i o
    | .req_uc_administrator_logout_administrator i => ∃ o, m' = .res_uc_administrator_logout_administrator o ∧ Accounts_post_uc_administrator_logout_administrator i o
    | .req_uc_administrator_remove_plug_ins i => ∃ o, m' = .res_uc_administrator_remove_plug_ins o ∧ Accounts_post_uc_administrator_remove_plug_ins i o
    | .req_uc_administrator_remove_user i => ∃ o, m' = .res_uc_administrator_remove_user o ∧ Accounts_post_uc_administrator_remove_user i o
    | .req_uc_customer_edit_customer_details i => ∃ o, m' = .res_uc_customer_edit_customer_details o ∧ Accounts_post_uc_customer_edit_customer_details i o
    | .req_uc_customer_login_customer i => ∃ o, m' = .res_uc_customer_login_customer o ∧ Accounts_post_uc_customer_login_customer i o
    | .req_uc_customer_logout_customer i => ∃ o, m' = .res_uc_customer_logout_customer o ∧ Accounts_post_uc_customer_logout_customer i o
    | .req_uc_customer_register_customer i => ∃ o, m' = .res_uc_customer_register_customer o ∧ Accounts_post_uc_customer_register_customer i o
    | .req_uc_sales_person_add_product i => ∃ o, m' = .res_uc_sales_person_add_product o ∧ Accounts_post_uc_sales_person_add_product i o
    | .req_uc_sales_person_login_sales_person i => ∃ o, m' = .res_uc_sales_person_login_sales_person o ∧ Accounts_post_uc_sales_person_login_sales_person i o
    | .req_uc_sales_person_remove_product i => ∃ o, m' = .res_uc_sales_person_remove_product o ∧ Accounts_post_uc_sales_person_remove_product i o
    | .req_uc_sales_person_update_product_attributes i => ∃ o, m' = .res_uc_sales_person_update_product_attributes o ∧ Accounts_post_uc_sales_person_update_product_attributes i o
    | _ => m' = m

theorem trace_pre_Accounts_3_1_3_s1 : ∀ i : L0_3_1_3_s1.Input, L0_3_1_3_s1.Spec.pre i → Accounts_pre_3_1_3_s1 i := by
  intros
  first
  | (simp_all [Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, L0_3_1_3_s1.Spec, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, L0_3_1_3_s1.Spec, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_1_3_s1 Accounts_post_3_1_3_s1 at *; simp_all)
  | (simp_all [Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, L0_3_1_3_s1.Spec, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_3_1_3_s1 : ∀ (i : L0_3_1_3_s1.Input) (o : L0_3_1_3_s1.Output), L0_3_1_3_s1.Spec.pre i → Accounts_post_3_1_3_s1 i o → L0_3_1_3_s1.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, L0_3_1_3_s1.Spec, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, L0_3_1_3_s1.Spec, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_1_3_s1 Accounts_post_3_1_3_s1 at *; simp_all)
  | (simp_all [Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, L0_3_1_3_s1.Spec, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_3_1_3_s2 : ∀ i : L0_3_1_3_s2.Input, L0_3_1_3_s2.Spec.pre i → Accounts_pre_3_1_3_s2 i := by
  intros
  first
  | (simp_all [Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, L0_3_1_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, L0_3_1_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_1_3_s2 Accounts_post_3_1_3_s2 at *; simp_all)
  | (simp_all [Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, L0_3_1_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_3_1_3_s2 : ∀ (i : L0_3_1_3_s2.Input) (o : L0_3_1_3_s2.Output), L0_3_1_3_s2.Spec.pre i → Accounts_post_3_1_3_s2 i o → L0_3_1_3_s2.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, L0_3_1_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, L0_3_1_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_1_3_s2 Accounts_post_3_1_3_s2 at *; simp_all)
  | (simp_all [Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, L0_3_1_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_3_1_3_s3 : ∀ i : L0_3_1_3_s3.Input, L0_3_1_3_s3.Spec.pre i → Accounts_pre_3_1_3_s3 i := by
  intros
  first
  | (simp_all [Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, L0_3_1_3_s3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, L0_3_1_3_s3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_1_3_s3 Accounts_post_3_1_3_s3 at *; simp_all)
  | (simp_all [Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, L0_3_1_3_s3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_3_1_3_s3 : ∀ (i : L0_3_1_3_s3.Input) (o : L0_3_1_3_s3.Output), L0_3_1_3_s3.Spec.pre i → Accounts_post_3_1_3_s3 i o → L0_3_1_3_s3.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, L0_3_1_3_s3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, L0_3_1_3_s3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_1_3_s3 Accounts_post_3_1_3_s3 at *; simp_all)
  | (simp_all [Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, L0_3_1_3_s3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_3_2_3_s2 : ∀ i : L0_3_2_3_s2.Input, L0_3_2_3_s2.Spec.pre i → Accounts_pre_3_2_3_s2 i := by
  intros
  first
  | (simp_all [Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, L0_3_2_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, L0_3_2_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_2_3_s2 Accounts_post_3_2_3_s2 at *; simp_all)
  | (simp_all [Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, L0_3_2_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_3_2_3_s2 : ∀ (i : L0_3_2_3_s2.Input) (o : L0_3_2_3_s2.Output), L0_3_2_3_s2.Spec.pre i → Accounts_post_3_2_3_s2 i o → L0_3_2_3_s2.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, L0_3_2_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, L0_3_2_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_2_3_s2 Accounts_post_3_2_3_s2 at *; simp_all)
  | (simp_all [Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, L0_3_2_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_3_5_3_s2 : ∀ i : L0_3_5_3_s2.Input, L0_3_5_3_s2.Spec.pre i → Accounts_pre_3_5_3_s2 i := by
  intros
  first
  | (simp_all [Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, L0_3_5_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, L0_3_5_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_3_5_3_s2 Accounts_post_3_5_3_s2 at *; simp_all)
  | (simp_all [Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, L0_3_5_3_s2.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

-- NOT PROVED: theorem trace_post_Accounts_3_5_3_s2 : ∀ (i : L0_3_5_3_s2.Input) (o : L0_3_5_3_s2.Output), L0_3_5_3_s2.Spec.pre i → Accounts_post_3_5_3_s2 i o → L0_3_5_3_s2.Spec.post i o

theorem trace_pre_Accounts_5_3_r3 : ∀ i : L0_5_3_r3.Input, L0_5_3_r3.Spec.pre i → Accounts_pre_5_3_r3 i := by
  intros
  first
  | (simp_all [Accounts_pre_5_3_r3, Accounts_post_5_3_r3, L0_5_3_r3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_5_3_r3, Accounts_post_5_3_r3, L0_5_3_r3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_5_3_r3 Accounts_post_5_3_r3 at *; simp_all)
  | (simp_all [Accounts_pre_5_3_r3, Accounts_post_5_3_r3, L0_5_3_r3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_5_3_r3 : ∀ (i : L0_5_3_r3.Input) (o : L0_5_3_r3.Output), L0_5_3_r3.Spec.pre i → Accounts_post_5_3_r3 i o → L0_5_3_r3.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_5_3_r3, Accounts_post_5_3_r3, L0_5_3_r3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_5_3_r3, Accounts_post_5_3_r3, L0_5_3_r3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_5_3_r3 Accounts_post_5_3_r3 at *; simp_all)
  | (simp_all [Accounts_pre_5_3_r3, Accounts_post_5_3_r3, L0_5_3_r3.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_5_3_r5 : ∀ i : L0_5_3_r5.Input, L0_5_3_r5.Spec.pre i → Accounts_pre_5_3_r5 i := by
  intros
  first
  | (simp_all [Accounts_pre_5_3_r5, Accounts_post_5_3_r5, L0_5_3_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_5_3_r5, Accounts_post_5_3_r5, L0_5_3_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_5_3_r5 Accounts_post_5_3_r5 at *; simp_all)
  | (simp_all [Accounts_pre_5_3_r5, Accounts_post_5_3_r5, L0_5_3_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_5_3_r5 : ∀ (i : L0_5_3_r5.Input) (o : L0_5_3_r5.Output), L0_5_3_r5.Spec.pre i → Accounts_post_5_3_r5 i o → L0_5_3_r5.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_5_3_r5, Accounts_post_5_3_r5, L0_5_3_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_5_3_r5, Accounts_post_5_3_r5, L0_5_3_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_5_3_r5 Accounts_post_5_3_r5 at *; simp_all)
  | (simp_all [Accounts_pre_5_3_r5, Accounts_post_5_3_r5, L0_5_3_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_5_5_r5 : ∀ i : L0_5_5_r5.Input, L0_5_5_r5.Spec.pre i → Accounts_pre_5_5_r5 i := by
  intros
  first
  | (simp_all [Accounts_pre_5_5_r5, Accounts_post_5_5_r5, L0_5_5_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_5_5_r5, Accounts_post_5_5_r5, L0_5_5_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_5_5_r5 Accounts_post_5_5_r5 at *; simp_all)
  | (simp_all [Accounts_pre_5_5_r5, Accounts_post_5_5_r5, L0_5_5_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_5_5_r5 : ∀ (i : L0_5_5_r5.Input) (o : L0_5_5_r5.Output), L0_5_5_r5.Spec.pre i → Accounts_post_5_5_r5 i o → L0_5_5_r5.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_5_5_r5, Accounts_post_5_5_r5, L0_5_5_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_5_5_r5, Accounts_post_5_5_r5, L0_5_5_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_5_5_r5 Accounts_post_5_5_r5 at *; simp_all)
  | (simp_all [Accounts_pre_5_5_r5, Accounts_post_5_5_r5, L0_5_5_r5.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_administrator_add_user : ∀ i : L0_uc_administrator_add_user.Input, L0_uc_administrator_add_user.Spec.pre i → Accounts_pre_uc_administrator_add_user i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, L0_uc_administrator_add_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, L0_uc_administrator_add_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_add_user Accounts_post_uc_administrator_add_user at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, L0_uc_administrator_add_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_administrator_add_user : ∀ (i : L0_uc_administrator_add_user.Input) (o : L0_uc_administrator_add_user.Output), L0_uc_administrator_add_user.Spec.pre i → Accounts_post_uc_administrator_add_user i o → L0_uc_administrator_add_user.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, L0_uc_administrator_add_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, L0_uc_administrator_add_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_add_user Accounts_post_uc_administrator_add_user at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, L0_uc_administrator_add_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_administrator_change_user_properties : ∀ i : L0_uc_administrator_change_user_properties.Input, L0_uc_administrator_change_user_properties.Spec.pre i → Accounts_pre_uc_administrator_change_user_properties i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, L0_uc_administrator_change_user_properties.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, L0_uc_administrator_change_user_properties.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_change_user_properties Accounts_post_uc_administrator_change_user_properties at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, L0_uc_administrator_change_user_properties.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_administrator_change_user_properties : ∀ (i : L0_uc_administrator_change_user_properties.Input) (o : L0_uc_administrator_change_user_properties.Output), L0_uc_administrator_change_user_properties.Spec.pre i → Accounts_post_uc_administrator_change_user_properties i o → L0_uc_administrator_change_user_properties.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, L0_uc_administrator_change_user_properties.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, L0_uc_administrator_change_user_properties.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_change_user_properties Accounts_post_uc_administrator_change_user_properties at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, L0_uc_administrator_change_user_properties.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_administrator_login_administrator : ∀ i : L0_uc_administrator_login_administrator.Input, L0_uc_administrator_login_administrator.Spec.pre i → Accounts_pre_uc_administrator_login_administrator i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, L0_uc_administrator_login_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, L0_uc_administrator_login_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_login_administrator Accounts_post_uc_administrator_login_administrator at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, L0_uc_administrator_login_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_administrator_login_administrator : ∀ (i : L0_uc_administrator_login_administrator.Input) (o : L0_uc_administrator_login_administrator.Output), L0_uc_administrator_login_administrator.Spec.pre i → Accounts_post_uc_administrator_login_administrator i o → L0_uc_administrator_login_administrator.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, L0_uc_administrator_login_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, L0_uc_administrator_login_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_login_administrator Accounts_post_uc_administrator_login_administrator at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, L0_uc_administrator_login_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_administrator_logout_administrator : ∀ i : L0_uc_administrator_logout_administrator.Input, L0_uc_administrator_logout_administrator.Spec.pre i → Accounts_pre_uc_administrator_logout_administrator i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, L0_uc_administrator_logout_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, L0_uc_administrator_logout_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_logout_administrator Accounts_post_uc_administrator_logout_administrator at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, L0_uc_administrator_logout_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_administrator_logout_administrator : ∀ (i : L0_uc_administrator_logout_administrator.Input) (o : L0_uc_administrator_logout_administrator.Output), L0_uc_administrator_logout_administrator.Spec.pre i → Accounts_post_uc_administrator_logout_administrator i o → L0_uc_administrator_logout_administrator.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, L0_uc_administrator_logout_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, L0_uc_administrator_logout_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_logout_administrator Accounts_post_uc_administrator_logout_administrator at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, L0_uc_administrator_logout_administrator.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_administrator_remove_plug_ins : ∀ i : L0_uc_administrator_remove_plug_ins.Input, L0_uc_administrator_remove_plug_ins.Spec.pre i → Accounts_pre_uc_administrator_remove_plug_ins i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, L0_uc_administrator_remove_plug_ins.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, L0_uc_administrator_remove_plug_ins.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_remove_plug_ins Accounts_post_uc_administrator_remove_plug_ins at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, L0_uc_administrator_remove_plug_ins.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_administrator_remove_plug_ins : ∀ (i : L0_uc_administrator_remove_plug_ins.Input) (o : L0_uc_administrator_remove_plug_ins.Output), L0_uc_administrator_remove_plug_ins.Spec.pre i → Accounts_post_uc_administrator_remove_plug_ins i o → L0_uc_administrator_remove_plug_ins.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, L0_uc_administrator_remove_plug_ins.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, L0_uc_administrator_remove_plug_ins.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_remove_plug_ins Accounts_post_uc_administrator_remove_plug_ins at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, L0_uc_administrator_remove_plug_ins.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_administrator_remove_user : ∀ i : L0_uc_administrator_remove_user.Input, L0_uc_administrator_remove_user.Spec.pre i → Accounts_pre_uc_administrator_remove_user i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, L0_uc_administrator_remove_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, L0_uc_administrator_remove_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_remove_user Accounts_post_uc_administrator_remove_user at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, L0_uc_administrator_remove_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_administrator_remove_user : ∀ (i : L0_uc_administrator_remove_user.Input) (o : L0_uc_administrator_remove_user.Output), L0_uc_administrator_remove_user.Spec.pre i → Accounts_post_uc_administrator_remove_user i o → L0_uc_administrator_remove_user.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, L0_uc_administrator_remove_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, L0_uc_administrator_remove_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_administrator_remove_user Accounts_post_uc_administrator_remove_user at *; simp_all)
  | (simp_all [Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, L0_uc_administrator_remove_user.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_customer_edit_customer_details : ∀ i : L0_uc_customer_edit_customer_details.Input, L0_uc_customer_edit_customer_details.Spec.pre i → Accounts_pre_uc_customer_edit_customer_details i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, L0_uc_customer_edit_customer_details.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, L0_uc_customer_edit_customer_details.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_edit_customer_details Accounts_post_uc_customer_edit_customer_details at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, L0_uc_customer_edit_customer_details.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_customer_edit_customer_details : ∀ (i : L0_uc_customer_edit_customer_details.Input) (o : L0_uc_customer_edit_customer_details.Output), L0_uc_customer_edit_customer_details.Spec.pre i → Accounts_post_uc_customer_edit_customer_details i o → L0_uc_customer_edit_customer_details.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, L0_uc_customer_edit_customer_details.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, L0_uc_customer_edit_customer_details.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_edit_customer_details Accounts_post_uc_customer_edit_customer_details at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, L0_uc_customer_edit_customer_details.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_customer_login_customer : ∀ i : L0_uc_customer_login_customer.Input, L0_uc_customer_login_customer.Spec.pre i → Accounts_pre_uc_customer_login_customer i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, L0_uc_customer_login_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, L0_uc_customer_login_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_login_customer Accounts_post_uc_customer_login_customer at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, L0_uc_customer_login_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_customer_login_customer : ∀ (i : L0_uc_customer_login_customer.Input) (o : L0_uc_customer_login_customer.Output), L0_uc_customer_login_customer.Spec.pre i → Accounts_post_uc_customer_login_customer i o → L0_uc_customer_login_customer.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, L0_uc_customer_login_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, L0_uc_customer_login_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_login_customer Accounts_post_uc_customer_login_customer at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, L0_uc_customer_login_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_customer_logout_customer : ∀ i : L0_uc_customer_logout_customer.Input, L0_uc_customer_logout_customer.Spec.pre i → Accounts_pre_uc_customer_logout_customer i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, L0_uc_customer_logout_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, L0_uc_customer_logout_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_logout_customer Accounts_post_uc_customer_logout_customer at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, L0_uc_customer_logout_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_customer_logout_customer : ∀ (i : L0_uc_customer_logout_customer.Input) (o : L0_uc_customer_logout_customer.Output), L0_uc_customer_logout_customer.Spec.pre i → Accounts_post_uc_customer_logout_customer i o → L0_uc_customer_logout_customer.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, L0_uc_customer_logout_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, L0_uc_customer_logout_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_logout_customer Accounts_post_uc_customer_logout_customer at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, L0_uc_customer_logout_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_customer_register_customer : ∀ i : L0_uc_customer_register_customer.Input, L0_uc_customer_register_customer.Spec.pre i → Accounts_pre_uc_customer_register_customer i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, L0_uc_customer_register_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, L0_uc_customer_register_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_register_customer Accounts_post_uc_customer_register_customer at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, L0_uc_customer_register_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_customer_register_customer : ∀ (i : L0_uc_customer_register_customer.Input) (o : L0_uc_customer_register_customer.Output), L0_uc_customer_register_customer.Spec.pre i → Accounts_post_uc_customer_register_customer i o → L0_uc_customer_register_customer.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, L0_uc_customer_register_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, L0_uc_customer_register_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_customer_register_customer Accounts_post_uc_customer_register_customer at *; simp_all)
  | (simp_all [Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, L0_uc_customer_register_customer.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_sales_person_add_product : ∀ i : L0_uc_sales_person_add_product.Input, L0_uc_sales_person_add_product.Spec.pre i → Accounts_pre_uc_sales_person_add_product i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, L0_uc_sales_person_add_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, L0_uc_sales_person_add_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_sales_person_add_product Accounts_post_uc_sales_person_add_product at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, L0_uc_sales_person_add_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_sales_person_add_product : ∀ (i : L0_uc_sales_person_add_product.Input) (o : L0_uc_sales_person_add_product.Output), L0_uc_sales_person_add_product.Spec.pre i → Accounts_post_uc_sales_person_add_product i o → L0_uc_sales_person_add_product.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, L0_uc_sales_person_add_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, L0_uc_sales_person_add_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_sales_person_add_product Accounts_post_uc_sales_person_add_product at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, L0_uc_sales_person_add_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_sales_person_login_sales_person : ∀ i : L0_uc_sales_person_login_sales_person.Input, L0_uc_sales_person_login_sales_person.Spec.pre i → Accounts_pre_uc_sales_person_login_sales_person i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, L0_uc_sales_person_login_sales_person.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, L0_uc_sales_person_login_sales_person.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_sales_person_login_sales_person Accounts_post_uc_sales_person_login_sales_person at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, L0_uc_sales_person_login_sales_person.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_sales_person_login_sales_person : ∀ (i : L0_uc_sales_person_login_sales_person.Input) (o : L0_uc_sales_person_login_sales_person.Output), L0_uc_sales_person_login_sales_person.Spec.pre i → Accounts_post_uc_sales_person_login_sales_person i o → L0_uc_sales_person_login_sales_person.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, L0_uc_sales_person_login_sales_person.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, L0_uc_sales_person_login_sales_person.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_sales_person_login_sales_person Accounts_post_uc_sales_person_login_sales_person at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, L0_uc_sales_person_login_sales_person.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_sales_person_remove_product : ∀ i : L0_uc_sales_person_remove_product.Input, L0_uc_sales_person_remove_product.Spec.pre i → Accounts_pre_uc_sales_person_remove_product i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, L0_uc_sales_person_remove_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, L0_uc_sales_person_remove_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_sales_person_remove_product Accounts_post_uc_sales_person_remove_product at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, L0_uc_sales_person_remove_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_post_Accounts_uc_sales_person_remove_product : ∀ (i : L0_uc_sales_person_remove_product.Input) (o : L0_uc_sales_person_remove_product.Output), L0_uc_sales_person_remove_product.Spec.pre i → Accounts_post_uc_sales_person_remove_product i o → L0_uc_sales_person_remove_product.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, L0_uc_sales_person_remove_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; done)
  | (simp_all [Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, L0_uc_sales_person_remove_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; omega)
  | (unfold Accounts_pre_uc_sales_person_remove_product Accounts_post_uc_sales_person_remove_product at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product, L0_uc_sales_person_remove_product.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes]; decide)

theorem trace_pre_Accounts_uc_sales_person_update_product_attributes : ∀ i : L0_uc_sales_person_update_product_attributes.Input, L0_uc_sales_person_update_product_attributes.Spec.pre i → Accounts_pre_uc_sales_person_update_product_attributes i := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes, L0_uc_sales_person_update_product_attributes.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product]; done)
  | (simp_all [Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes, L0_uc_sales_person_update_product_attributes.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product]; omega)
  | (unfold Accounts_pre_uc_sales_person_update_product_attributes Accounts_post_uc_sales_person_update_product_attributes at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes, L0_uc_sales_person_update_product_attributes.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product]; decide)

theorem trace_post_Accounts_uc_sales_person_update_product_attributes : ∀ (i : L0_uc_sales_person_update_product_attributes.Input) (o : L0_uc_sales_person_update_product_attributes.Output), L0_uc_sales_person_update_product_attributes.Spec.pre i → Accounts_post_uc_sales_person_update_product_attributes i o → L0_uc_sales_person_update_product_attributes.Spec.post i o := by
  intros
  first
  | (simp_all [Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes, L0_uc_sales_person_update_product_attributes.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product]; done)
  | (simp_all [Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes, L0_uc_sales_person_update_product_attributes.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product]; omega)
  | (unfold Accounts_pre_uc_sales_person_update_product_attributes Accounts_post_uc_sales_person_update_product_attributes at *; simp_all)
  | (simp_all [Accounts_pre_uc_sales_person_update_product_attributes, Accounts_post_uc_sales_person_update_product_attributes, L0_uc_sales_person_update_product_attributes.Spec, Accounts_pre_3_1_3_s1, Accounts_post_3_1_3_s1, Accounts_pre_3_1_3_s2, Accounts_post_3_1_3_s2, Accounts_pre_3_1_3_s3, Accounts_post_3_1_3_s3, Accounts_pre_3_2_3_s2, Accounts_post_3_2_3_s2, Accounts_pre_3_5_3_s2, Accounts_post_3_5_3_s2, Accounts_pre_5_3_r3, Accounts_post_5_3_r3, Accounts_pre_5_3_r5, Accounts_post_5_3_r5, Accounts_pre_5_5_r5, Accounts_post_5_5_r5, Accounts_pre_uc_administrator_add_user, Accounts_post_uc_administrator_add_user, Accounts_pre_uc_administrator_change_user_properties, Accounts_post_uc_administrator_change_user_properties, Accounts_pre_uc_administrator_login_administrator, Accounts_post_uc_administrator_login_administrator, Accounts_pre_uc_administrator_logout_administrator, Accounts_post_uc_administrator_logout_administrator, Accounts_pre_uc_administrator_remove_plug_ins, Accounts_post_uc_administrator_remove_plug_ins, Accounts_pre_uc_administrator_remove_user, Accounts_post_uc_administrator_remove_user, Accounts_pre_uc_customer_edit_customer_details, Accounts_post_uc_customer_edit_customer_details, Accounts_pre_uc_customer_login_customer, Accounts_post_uc_customer_login_customer, Accounts_pre_uc_customer_logout_customer, Accounts_post_uc_customer_logout_customer, Accounts_pre_uc_customer_register_customer, Accounts_post_uc_customer_register_customer, Accounts_pre_uc_sales_person_add_product, Accounts_post_uc_sales_person_add_product, Accounts_pre_uc_sales_person_login_sales_person, Accounts_post_uc_sales_person_login_sales_person, Accounts_pre_uc_sales_person_remove_product, Accounts_post_uc_sales_person_remove_product]; decide)

-- ===== component ShoppingCart =====

def ShoppingCart_pre_3_3_3_s1 (i : L0_3_3_3_s1.Input) : Prop := true
def ShoppingCart_post_3_3_3_s1 (i : L0_3_3_3_s1.Input) (o : L0_3_3_3_s1.Output) : Prop := 
  o.cart.length = i.cart.length + 1 ∧ o.cart.contains i.productToAdd

def ShoppingCart_pre_3_3_3_s2 (i : L0_3_3_3_s2.Input) : Prop := i.items.Nodup
def ShoppingCart_post_3_3_3_s2 (i : L0_3_3_3_s2.Input) (o : L0_3_3_3_s2.Output) : Prop := 
  o.itemCount = (i.items.map (fun x => x.quantity)).sum ∧ o.totalCost = (i.items.map (fun x => x.quantity * x.price)).sum

def ShoppingCart_pre_3_3_3_s3 (i : L0_3_3_3_s3.Input) : Prop := i.cart.Nodup
def ShoppingCart_post_3_3_3_s3 (i : L0_3_3_3_s3.Input) (o : L0_3_3_3_s3.Output) : Prop := o.cart = i.cart

def ShoppingCart_pre_3_4_3_s1 (i : L0_3_4_3_s1.Input) : Prop := i.cart.items.Nodup
def ShoppingCart_post_3_4_3_s1 (i : L0_3_4_3_s1.Input) (o : L0_3_4_3_s1.Output) : Prop := 
  o.order.items = i.cart.items ∧ o.order.confirmed = true ∧ o.order.items.Nodup

def ShoppingCart_pre_3_4_3_s2 (i : L0_3_4_3_s2.Input) : Prop := i.order.quantity > 0
def ShoppingCart_post_3_4_3_s2 (i : L0_3_4_3_s2.Input) (o : L0_3_4_3_s2.Output) : Prop := 
  (o.revised = true ↔ 
    ∃ item ∈ i.order.items, o.order.quantity < i.order.quantity) ∧
  o.order.items = i.order.items ∧
  o.order.quantity ≤ i.order.quantity

def ShoppingCart_pre_3_4_3_s3 (i : L0_3_4_3_s3.Input) : Prop := i.orderId > 0
def ShoppingCart_post_3_4_3_s3 (i : L0_3_4_3_s3.Input) (o : L0_3_4_3_s3.Output) : Prop := 
  o.sent = true ∧ o.details = { id := i.orderId, items := [], total := 0 }

def ShoppingCart_pre_uc_customer_add_item_to_cart (i : L0_uc_customer_add_item_to_cart.Input) : Prop := i.signedIn = true
def ShoppingCart_post_uc_customer_add_item_to_cart (i : L0_uc_customer_add_item_to_cart.Input) (o : L0_uc_customer_add_item_to_cart.Output) : Prop := o.signedIn = i.signedIn ∧ o.items = i.items ∧ o.cookie ≠ ""

def ShoppingCart_pre_ci_1 (i : L0_ci_1.Input) : Prop := i.customerEmail ≠ "" ∧ i.items.Nodup ∧ i.shippingAddr ≠ "" ∧ i.trackingNum ≠ ""
def ShoppingCart_post_ci_1 (i : L0_ci_1.Input) (o : L0_ci_1.Output) : Prop := o.sentEmail = true

/-- Component ShoppingCart: owns 3.3.3/S1, 3.3.3/S2, 3.3.3/S3, 3.4.3/S1, 3.4.3/S2, 3.4.3/S3, UC-customer-add-item-to-cart, CI-1. -/
def ShoppingCartContract : Contract AccountSysMsg AccountSysMsg where
  pre := fun m => match m with
    | .req_1_4_s2 i => L0_1_4_s2.Spec.pre i
    | .req_1_4_s3 i => L0_1_4_s3.Spec.pre i
    | .req_1_4_s4 i => L0_1_4_s4.Spec.pre i
    | .req_3_1_3_s1 i => L0_3_1_3_s1.Spec.pre i
    | .req_3_1_3_s2 i => L0_3_1_3_s2.Spec.pre i
    | .req_3_1_3_s3 i => L0_3_1_3_s3.Spec.pre i
    | .req_3_2_3_s2 i => L0_3_2_3_s2.Spec.pre i
    | .req_3_3_3_s1 i => ShoppingCart_pre_3_3_3_s1 i
    | .req_3_3_3_s2 i => ShoppingCart_pre_3_3_3_s2 i
    | .req_3_3_3_s3 i => ShoppingCart_pre_3_3_3_s3 i
    | .req_3_4_3_s1 i => ShoppingCart_pre_3_4_3_s1 i
    | .req_3_4_3_s2 i => ShoppingCart_pre_3_4_3_s2 i
    | .req_3_4_3_s3 i => ShoppingCart_pre_3_4_3_s3 i
    | .req_3_5_3_s2 i => L0_3_5_3_s2.Spec.pre i
    | .req_5_1_r5 i => L0_5_1_r5.Spec.pre i
    | .req_5_3_r3 i => L0_5_3_r3.Spec.pre i
    | .req_5_3_r5 i => L0_5_3_r5.Spec.pre i
    | .req_5_5_r5 i => L0_5_5_r5.Spec.pre i
    | .req_ci_1 i => ShoppingCart_pre_ci_1 i
    | .req_dd_credit_card_no i => L0_dd_credit_card_no.Spec.pre i
    | .req_dd_e_mail_id i => L0_dd_e_mail_id.Spec.pre i
    | .req_dd_item_id i => L0_dd_item_id.Spec.pre i
    | .req_dd_item_name i => L0_dd_item_name.Spec.pre i
    | .req_dd_name i => L0_dd_name.Spec.pre i
    | .req_dd_order_no i => L0_dd_order_no.Spec.pre i
    | .req_dd_password i => L0_dd_password.Spec.pre i
    | .req_dd_price i => L0_dd_price.Spec.pre i
    | .req_dd_quantity i => L0_dd_quantity.Spec.pre i
    | .req_dd_text_description i => L0_dd_text_description.Spec.pre i
    | .req_dd_total i => L0_dd_total.Spec.pre i
    | .req_dd_tracking_no i => L0_dd_tracking_no.Spec.pre i
    | .req_dd_user_id i => L0_dd_user_id.Spec.pre i
    | .req_si_1_2 i => L0_si_1_2.Spec.pre i
    | .req_uc_administrator_add_user i => L0_uc_administrator_add_user.Spec.pre i
    | .req_uc_administrator_change_user_properties i => L0_uc_administrator_change_user_properties.Spec.pre i
    | .req_uc_administrator_login_administrator i => L0_uc_administrator_login_administrator.Spec.pre i
    | .req_uc_administrator_logout_administrator i => L0_uc_administrator_logout_administrator.Spec.pre i
    | .req_uc_administrator_remove_plug_ins i => L0_uc_administrator_remove_plug_ins.Spec.pre i
    | .req_uc_administrator_remove_user i => L0_uc_administrator_remove_user.Spec.pre i
    | .req_uc_customer_add_item_to_cart i => ShoppingCart_pre_uc_customer_add_item_to_cart i
    | .req_uc_customer_edit_customer_details i => L0_uc_customer_edit_customer_details.Spec.pre i
    | .req_uc_customer_login_customer i => L0_uc_customer_login_customer.Spec.pre i
    | .req_uc_customer_logout_customer i => L0_uc_customer_logout_customer.Spec.pre i
    | .req_uc_customer_register_customer i => L0_uc_customer_register_customer.Spec.pre i
    | .req_uc_sales_person_add_product i => L0_uc_sales_person_add_product.Spec.pre i
    | .req_uc_sales_person_login_sales_person i => L0_uc_sales_person_login_sales_person.Spec.pre i
    | .req_uc_sales_person_remove_product i => L0_uc_sales_person_remove_product.Spec.pre i
    | .req_uc_sales_person_update_product_attributes i => L0_uc_sales_person_update_product_attributes.Spec.pre i
    | _ => True
  post := fun m m' => match m with
    | .req_3_3_3_s1 i => ∃ o, m' = .res_3_3_3_s1 o ∧ ShoppingCart_post_3_3_3_s1 i o
    | .req_3_3_3_s2 i => ∃ o, m' = .res_3_3_3_s2 o ∧ ShoppingCart_post_3_3_3_s2 i o
    | .req_3_3_3_s3 i => ∃ o, m' = .res_3_3_3_s3 o ∧ ShoppingCart_post_3_3_3_s3 i o
    | .req_3_4_3_s1 i => ∃ o, m' = .res_3_4_3_s1 o ∧ ShoppingCart_post_3_4_3_s1 i o
    | .req_3_4_3_s2 i => ∃ o, m' = .res_3_4_3_s2 o ∧ ShoppingCart_post_3_4_3_s2 i o
    | .req_3_4_3_s3 i => ∃ o, m' = .res_3_4_3_s3 o ∧ ShoppingCart_post_3_4_3_s3 i o
    | .req_ci_1 i => ∃ o, m' = .res_ci_1 o ∧ ShoppingCart_post_ci_1 i o
    | .req_uc_customer_add_item_to_cart i => ∃ o, m' = .res_uc_customer_add_item_to_cart o ∧ ShoppingCart_post_uc_customer_add_item_to_cart i o
    | _ => m' = m

theorem trace_pre_ShoppingCart_3_3_3_s1 : ∀ i : L0_3_3_3_s1.Input, L0_3_3_3_s1.Spec.pre i → ShoppingCart_pre_3_3_3_s1 i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, L0_3_3_3_s1.Spec, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, L0_3_3_3_s1.Spec, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_3_3_s1 ShoppingCart_post_3_3_3_s1 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, L0_3_3_3_s1.Spec, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_post_ShoppingCart_3_3_3_s1 : ∀ (i : L0_3_3_3_s1.Input) (o : L0_3_3_3_s1.Output), L0_3_3_3_s1.Spec.pre i → ShoppingCart_post_3_3_3_s1 i o → L0_3_3_3_s1.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, L0_3_3_3_s1.Spec, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, L0_3_3_3_s1.Spec, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_3_3_s1 ShoppingCart_post_3_3_3_s1 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, L0_3_3_3_s1.Spec, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_pre_ShoppingCart_3_3_3_s2 : ∀ i : L0_3_3_3_s2.Input, L0_3_3_3_s2.Spec.pre i → ShoppingCart_pre_3_3_3_s2 i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, L0_3_3_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, L0_3_3_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_3_3_s2 ShoppingCart_post_3_3_3_s2 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, L0_3_3_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_post_ShoppingCart_3_3_3_s2 : ∀ (i : L0_3_3_3_s2.Input) (o : L0_3_3_3_s2.Output), L0_3_3_3_s2.Spec.pre i → ShoppingCart_post_3_3_3_s2 i o → L0_3_3_3_s2.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, L0_3_3_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, L0_3_3_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_3_3_s2 ShoppingCart_post_3_3_3_s2 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, L0_3_3_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_pre_ShoppingCart_3_3_3_s3 : ∀ i : L0_3_3_3_s3.Input, L0_3_3_3_s3.Spec.pre i → ShoppingCart_pre_3_3_3_s3 i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, L0_3_3_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, L0_3_3_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_3_3_s3 ShoppingCart_post_3_3_3_s3 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, L0_3_3_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_post_ShoppingCart_3_3_3_s3 : ∀ (i : L0_3_3_3_s3.Input) (o : L0_3_3_3_s3.Output), L0_3_3_3_s3.Spec.pre i → ShoppingCart_post_3_3_3_s3 i o → L0_3_3_3_s3.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, L0_3_3_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, L0_3_3_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_3_3_s3 ShoppingCart_post_3_3_3_s3 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, L0_3_3_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_pre_ShoppingCart_3_4_3_s1 : ∀ i : L0_3_4_3_s1.Input, L0_3_4_3_s1.Spec.pre i → ShoppingCart_pre_3_4_3_s1 i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, L0_3_4_3_s1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, L0_3_4_3_s1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_4_3_s1 ShoppingCart_post_3_4_3_s1 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, L0_3_4_3_s1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_post_ShoppingCart_3_4_3_s1 : ∀ (i : L0_3_4_3_s1.Input) (o : L0_3_4_3_s1.Output), L0_3_4_3_s1.Spec.pre i → ShoppingCart_post_3_4_3_s1 i o → L0_3_4_3_s1.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, L0_3_4_3_s1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, L0_3_4_3_s1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_4_3_s1 ShoppingCart_post_3_4_3_s1 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, L0_3_4_3_s1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_pre_ShoppingCart_3_4_3_s2 : ∀ i : L0_3_4_3_s2.Input, L0_3_4_3_s2.Spec.pre i → ShoppingCart_pre_3_4_3_s2 i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, L0_3_4_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, L0_3_4_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_4_3_s2 ShoppingCart_post_3_4_3_s2 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, L0_3_4_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_post_ShoppingCart_3_4_3_s2 : ∀ (i : L0_3_4_3_s2.Input) (o : L0_3_4_3_s2.Output), L0_3_4_3_s2.Spec.pre i → ShoppingCart_post_3_4_3_s2 i o → L0_3_4_3_s2.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, L0_3_4_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, L0_3_4_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_4_3_s2 ShoppingCart_post_3_4_3_s2 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, L0_3_4_3_s2.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_pre_ShoppingCart_3_4_3_s3 : ∀ i : L0_3_4_3_s3.Input, L0_3_4_3_s3.Spec.pre i → ShoppingCart_pre_3_4_3_s3 i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, L0_3_4_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, L0_3_4_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_4_3_s3 ShoppingCart_post_3_4_3_s3 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, L0_3_4_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_post_ShoppingCart_3_4_3_s3 : ∀ (i : L0_3_4_3_s3.Input) (o : L0_3_4_3_s3.Output), L0_3_4_3_s3.Spec.pre i → ShoppingCart_post_3_4_3_s3 i o → L0_3_4_3_s3.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, L0_3_4_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, L0_3_4_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_3_4_3_s3 ShoppingCart_post_3_4_3_s3 at *; simp_all)
  | (simp_all [ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, L0_3_4_3_s3.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_pre_ShoppingCart_uc_customer_add_item_to_cart : ∀ i : L0_uc_customer_add_item_to_cart.Input, L0_uc_customer_add_item_to_cart.Spec.pre i → ShoppingCart_pre_uc_customer_add_item_to_cart i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, L0_uc_customer_add_item_to_cart.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, L0_uc_customer_add_item_to_cart.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_uc_customer_add_item_to_cart ShoppingCart_post_uc_customer_add_item_to_cart at *; simp_all)
  | (simp_all [ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, L0_uc_customer_add_item_to_cart.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_post_ShoppingCart_uc_customer_add_item_to_cart : ∀ (i : L0_uc_customer_add_item_to_cart.Input) (o : L0_uc_customer_add_item_to_cart.Output), L0_uc_customer_add_item_to_cart.Spec.pre i → ShoppingCart_post_uc_customer_add_item_to_cart i o → L0_uc_customer_add_item_to_cart.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, L0_uc_customer_add_item_to_cart.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; done)
  | (simp_all [ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, L0_uc_customer_add_item_to_cart.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; omega)
  | (unfold ShoppingCart_pre_uc_customer_add_item_to_cart ShoppingCart_post_uc_customer_add_item_to_cart at *; simp_all)
  | (simp_all [ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart, L0_uc_customer_add_item_to_cart.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1]; decide)

theorem trace_pre_ShoppingCart_ci_1 : ∀ i : L0_ci_1.Input, L0_ci_1.Spec.pre i → ShoppingCart_pre_ci_1 i := by
  intros
  first
  | (simp_all [ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1, L0_ci_1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart]; done)
  | (simp_all [ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1, L0_ci_1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart]; omega)
  | (unfold ShoppingCart_pre_ci_1 ShoppingCart_post_ci_1 at *; simp_all)
  | (simp_all [ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1, L0_ci_1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart]; decide)

theorem trace_post_ShoppingCart_ci_1 : ∀ (i : L0_ci_1.Input) (o : L0_ci_1.Output), L0_ci_1.Spec.pre i → ShoppingCart_post_ci_1 i o → L0_ci_1.Spec.post i o := by
  intros
  first
  | (simp_all [ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1, L0_ci_1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart]; done)
  | (simp_all [ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1, L0_ci_1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart]; omega)
  | (unfold ShoppingCart_pre_ci_1 ShoppingCart_post_ci_1 at *; simp_all)
  | (simp_all [ShoppingCart_pre_ci_1, ShoppingCart_post_ci_1, L0_ci_1.Spec, ShoppingCart_pre_3_3_3_s1, ShoppingCart_post_3_3_3_s1, ShoppingCart_pre_3_3_3_s2, ShoppingCart_post_3_3_3_s2, ShoppingCart_pre_3_3_3_s3, ShoppingCart_post_3_3_3_s3, ShoppingCart_pre_3_4_3_s1, ShoppingCart_post_3_4_3_s1, ShoppingCart_pre_3_4_3_s2, ShoppingCart_post_3_4_3_s2, ShoppingCart_pre_3_4_3_s3, ShoppingCart_post_3_4_3_s3, ShoppingCart_pre_uc_customer_add_item_to_cart, ShoppingCart_post_uc_customer_add_item_to_cart]; decide)

-- ===== component Payment =====

def Payment_pre_dd_credit_card_no (i : L0_dd_credit_card_no.Input) : Prop := true
def Payment_post_dd_credit_card_no (i : L0_dd_credit_card_no.Input) (o : L0_dd_credit_card_no.Output) : Prop := o.valid = true ↔ i.raw.length = 16 ∧ i.raw.toList.all Char.isDigit = true

def Payment_pre_dd_e_mail_id (i : L0_dd_e_mail_id.Input) : Prop := true
def Payment_post_dd_e_mail_id (i : L0_dd_e_mail_id.Input) (o : L0_dd_e_mail_id.Output) : Prop := o.valid = true ↔ i.raw.length = 50 ∧ i.raw.toList.all Char.isAlphanum = true

def Payment_pre_dd_item_id (i : L0_dd_item_id.Input) : Prop := true
def Payment_post_dd_item_id (i : L0_dd_item_id.Input) (o : L0_dd_item_id.Output) : Prop := o.valid = true ↔ (i.raw.length = 7) ∧ i.raw.toList.all (·.isAlphanum) = true

def Payment_pre_dd_item_name (i : L0_dd_item_name.Input) : Prop := true
def Payment_post_dd_item_name (i : L0_dd_item_name.Input) (o : L0_dd_item_name.Output) : Prop := o.valid = true ↔
  (1 ≤ i.raw.length ∧ i.raw.length ≤ 50 ∧
   i.raw.toList.all (·.isAlpha) = true)

def Payment_pre_dd_name (i : L0_dd_name.Input) : Prop := true
def Payment_post_dd_name (i : L0_dd_name.Input) (o : L0_dd_name.Output) : Prop := o.valid = true ↔
  (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧
   i.raw.toList.all (·.isAlpha) = true)

def Payment_pre_dd_order_no (i : L0_dd_order_no.Input) : Prop := true
def Payment_post_dd_order_no (i : L0_dd_order_no.Input) (o : L0_dd_order_no.Output) : Prop := o.valid = true ↔ (i.raw.length = 9) ∧ (i.raw.toList.all Char.isAlphanum = true)

def Payment_pre_dd_password (i : L0_dd_password.Input) : Prop := true
def Payment_post_dd_password (i : L0_dd_password.Input) (o : L0_dd_password.Output) : Prop := o.valid = true ↔
  (4 ≤ i.raw.length ∧ i.raw.length ≤ 10 ∧
   i.raw.toList.all (·.isAlphanum) = true)

def Payment_pre_dd_price (i : L0_dd_price.Input) : Prop := true
def Payment_post_dd_price (i : L0_dd_price.Input) (o : L0_dd_price.Output) : Prop := o.valid = true ↔ i.value ≤ 9999

def Payment_pre_dd_quantity (i : L0_dd_quantity.Input) : Prop := true
def Payment_post_dd_quantity (i : L0_dd_quantity.Input) (o : L0_dd_quantity.Output) : Prop := o.valid = true ↔ 1 ≤ i.value ∧ i.value ≤ i.max_ref

def Payment_pre_dd_text_description (i : L0_dd_text_description.Input) : Prop := true
def Payment_post_dd_text_description (i : L0_dd_text_description.Input) (o : L0_dd_text_description.Output) : Prop := o.valid = true ↔ (1 ≤ i.raw.length ∧ i.raw.length ≤ 100 ∧ i.raw.toList.all (·.isAlpha) = true)

def Payment_pre_dd_total (i : L0_dd_total.Input) : Prop := true
def Payment_post_dd_total (i : L0_dd_total.Input) (o : L0_dd_total.Output) : Prop := o.valid = true ↔ i.value ≤ 9999

def Payment_pre_dd_tracking_no (i : L0_dd_tracking_no.Input) : Prop := true
def Payment_post_dd_tracking_no (i : L0_dd_tracking_no.Input) (o : L0_dd_tracking_no.Output) : Prop := o.valid = true ↔ (i.raw.length = 20 ∧ i.raw.toList.all Char.isAlphanum = true)

def Payment_pre_dd_user_id (i : L0_dd_user_id.Input) : Prop := true
def Payment_post_dd_user_id (i : L0_dd_user_id.Input) (o : L0_dd_user_id.Output) : Prop := o.valid = true ↔ (4 ≤ i.raw.length ∧ i.raw.length ≤ 10) ∧ i.raw.toList.all Char.isAlphanum = true

/-- Component Payment: owns DD-credit-card-no, DD-e-mail-id, DD-item-id, DD-item-name, DD-name, DD-order-no, DD-password, DD-price, DD-quantity, DD-text-description, DD-total, DD-tracking-no, DD-user-id. -/
def PaymentContract : Contract AccountSysMsg AccountSysMsg where
  pre := fun m => match m with
    | .req_1_4_s2 i => L0_1_4_s2.Spec.pre i
    | .req_1_4_s3 i => L0_1_4_s3.Spec.pre i
    | .req_1_4_s4 i => L0_1_4_s4.Spec.pre i
    | .req_3_1_3_s1 i => L0_3_1_3_s1.Spec.pre i
    | .req_3_1_3_s2 i => L0_3_1_3_s2.Spec.pre i
    | .req_3_1_3_s3 i => L0_3_1_3_s3.Spec.pre i
    | .req_3_2_3_s2 i => L0_3_2_3_s2.Spec.pre i
    | .req_3_3_3_s1 i => L0_3_3_3_s1.Spec.pre i
    | .req_3_3_3_s2 i => L0_3_3_3_s2.Spec.pre i
    | .req_3_3_3_s3 i => L0_3_3_3_s3.Spec.pre i
    | .req_3_4_3_s1 i => L0_3_4_3_s1.Spec.pre i
    | .req_3_4_3_s2 i => L0_3_4_3_s2.Spec.pre i
    | .req_3_4_3_s3 i => L0_3_4_3_s3.Spec.pre i
    | .req_3_5_3_s2 i => L0_3_5_3_s2.Spec.pre i
    | .req_5_1_r5 i => L0_5_1_r5.Spec.pre i
    | .req_5_3_r3 i => L0_5_3_r3.Spec.pre i
    | .req_5_3_r5 i => L0_5_3_r5.Spec.pre i
    | .req_5_5_r5 i => L0_5_5_r5.Spec.pre i
    | .req_ci_1 i => L0_ci_1.Spec.pre i
    | .req_dd_credit_card_no i => Payment_pre_dd_credit_card_no i
    | .req_dd_e_mail_id i => Payment_pre_dd_e_mail_id i
    | .req_dd_item_id i => Payment_pre_dd_item_id i
    | .req_dd_item_name i => Payment_pre_dd_item_name i
    | .req_dd_name i => Payment_pre_dd_name i
    | .req_dd_order_no i => Payment_pre_dd_order_no i
    | .req_dd_password i => Payment_pre_dd_password i
    | .req_dd_price i => Payment_pre_dd_price i
    | .req_dd_quantity i => Payment_pre_dd_quantity i
    | .req_dd_text_description i => Payment_pre_dd_text_description i
    | .req_dd_total i => Payment_pre_dd_total i
    | .req_dd_tracking_no i => Payment_pre_dd_tracking_no i
    | .req_dd_user_id i => Payment_pre_dd_user_id i
    | .req_si_1_2 i => L0_si_1_2.Spec.pre i
    | .req_uc_administrator_add_user i => L0_uc_administrator_add_user.Spec.pre i
    | .req_uc_administrator_change_user_properties i => L0_uc_administrator_change_user_properties.Spec.pre i
    | .req_uc_administrator_login_administrator i => L0_uc_administrator_login_administrator.Spec.pre i
    | .req_uc_administrator_logout_administrator i => L0_uc_administrator_logout_administrator.Spec.pre i
    | .req_uc_administrator_remove_plug_ins i => L0_uc_administrator_remove_plug_ins.Spec.pre i
    | .req_uc_administrator_remove_user i => L0_uc_administrator_remove_user.Spec.pre i
    | .req_uc_customer_add_item_to_cart i => L0_uc_customer_add_item_to_cart.Spec.pre i
    | .req_uc_customer_edit_customer_details i => L0_uc_customer_edit_customer_details.Spec.pre i
    | .req_uc_customer_login_customer i => L0_uc_customer_login_customer.Spec.pre i
    | .req_uc_customer_logout_customer i => L0_uc_customer_logout_customer.Spec.pre i
    | .req_uc_customer_register_customer i => L0_uc_customer_register_customer.Spec.pre i
    | .req_uc_sales_person_add_product i => L0_uc_sales_person_add_product.Spec.pre i
    | .req_uc_sales_person_login_sales_person i => L0_uc_sales_person_login_sales_person.Spec.pre i
    | .req_uc_sales_person_remove_product i => L0_uc_sales_person_remove_product.Spec.pre i
    | .req_uc_sales_person_update_product_attributes i => L0_uc_sales_person_update_product_attributes.Spec.pre i
    | _ => True
  post := fun m m' => match m with
    | .req_dd_credit_card_no i => ∃ o, m' = .res_dd_credit_card_no o ∧ Payment_post_dd_credit_card_no i o
    | .req_dd_e_mail_id i => ∃ o, m' = .res_dd_e_mail_id o ∧ Payment_post_dd_e_mail_id i o
    | .req_dd_item_id i => ∃ o, m' = .res_dd_item_id o ∧ Payment_post_dd_item_id i o
    | .req_dd_item_name i => ∃ o, m' = .res_dd_item_name o ∧ Payment_post_dd_item_name i o
    | .req_dd_name i => ∃ o, m' = .res_dd_name o ∧ Payment_post_dd_name i o
    | .req_dd_order_no i => ∃ o, m' = .res_dd_order_no o ∧ Payment_post_dd_order_no i o
    | .req_dd_password i => ∃ o, m' = .res_dd_password o ∧ Payment_post_dd_password i o
    | .req_dd_price i => ∃ o, m' = .res_dd_price o ∧ Payment_post_dd_price i o
    | .req_dd_quantity i => ∃ o, m' = .res_dd_quantity o ∧ Payment_post_dd_quantity i o
    | .req_dd_text_description i => ∃ o, m' = .res_dd_text_description o ∧ Payment_post_dd_text_description i o
    | .req_dd_total i => ∃ o, m' = .res_dd_total o ∧ Payment_post_dd_total i o
    | .req_dd_tracking_no i => ∃ o, m' = .res_dd_tracking_no o ∧ Payment_post_dd_tracking_no i o
    | .req_dd_user_id i => ∃ o, m' = .res_dd_user_id o ∧ Payment_post_dd_user_id i o
    | _ => m' = m

theorem trace_pre_Payment_dd_credit_card_no : ∀ i : L0_dd_credit_card_no.Input, L0_dd_credit_card_no.Spec.pre i → Payment_pre_dd_credit_card_no i := by
  intros
  first
  | (simp_all [Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, L0_dd_credit_card_no.Spec, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, L0_dd_credit_card_no.Spec, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_credit_card_no Payment_post_dd_credit_card_no at *; simp_all)
  | (simp_all [Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, L0_dd_credit_card_no.Spec, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_credit_card_no : ∀ (i : L0_dd_credit_card_no.Input) (o : L0_dd_credit_card_no.Output), L0_dd_credit_card_no.Spec.pre i → Payment_post_dd_credit_card_no i o → L0_dd_credit_card_no.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, L0_dd_credit_card_no.Spec, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, L0_dd_credit_card_no.Spec, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_credit_card_no Payment_post_dd_credit_card_no at *; simp_all)
  | (simp_all [Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, L0_dd_credit_card_no.Spec, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_e_mail_id : ∀ i : L0_dd_e_mail_id.Input, L0_dd_e_mail_id.Spec.pre i → Payment_pre_dd_e_mail_id i := by
  intros
  first
  | (simp_all [Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, L0_dd_e_mail_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, L0_dd_e_mail_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_e_mail_id Payment_post_dd_e_mail_id at *; simp_all)
  | (simp_all [Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, L0_dd_e_mail_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_e_mail_id : ∀ (i : L0_dd_e_mail_id.Input) (o : L0_dd_e_mail_id.Output), L0_dd_e_mail_id.Spec.pre i → Payment_post_dd_e_mail_id i o → L0_dd_e_mail_id.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, L0_dd_e_mail_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, L0_dd_e_mail_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_e_mail_id Payment_post_dd_e_mail_id at *; simp_all)
  | (simp_all [Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, L0_dd_e_mail_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_item_id : ∀ i : L0_dd_item_id.Input, L0_dd_item_id.Spec.pre i → Payment_pre_dd_item_id i := by
  intros
  first
  | (simp_all [Payment_pre_dd_item_id, Payment_post_dd_item_id, L0_dd_item_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_item_id, Payment_post_dd_item_id, L0_dd_item_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_item_id Payment_post_dd_item_id at *; simp_all)
  | (simp_all [Payment_pre_dd_item_id, Payment_post_dd_item_id, L0_dd_item_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_item_id : ∀ (i : L0_dd_item_id.Input) (o : L0_dd_item_id.Output), L0_dd_item_id.Spec.pre i → Payment_post_dd_item_id i o → L0_dd_item_id.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_item_id, Payment_post_dd_item_id, L0_dd_item_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_item_id, Payment_post_dd_item_id, L0_dd_item_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_item_id Payment_post_dd_item_id at *; simp_all)
  | (simp_all [Payment_pre_dd_item_id, Payment_post_dd_item_id, L0_dd_item_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_item_name : ∀ i : L0_dd_item_name.Input, L0_dd_item_name.Spec.pre i → Payment_pre_dd_item_name i := by
  intros
  first
  | (simp_all [Payment_pre_dd_item_name, Payment_post_dd_item_name, L0_dd_item_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_item_name, Payment_post_dd_item_name, L0_dd_item_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_item_name Payment_post_dd_item_name at *; simp_all)
  | (simp_all [Payment_pre_dd_item_name, Payment_post_dd_item_name, L0_dd_item_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_item_name : ∀ (i : L0_dd_item_name.Input) (o : L0_dd_item_name.Output), L0_dd_item_name.Spec.pre i → Payment_post_dd_item_name i o → L0_dd_item_name.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_item_name, Payment_post_dd_item_name, L0_dd_item_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_item_name, Payment_post_dd_item_name, L0_dd_item_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_item_name Payment_post_dd_item_name at *; simp_all)
  | (simp_all [Payment_pre_dd_item_name, Payment_post_dd_item_name, L0_dd_item_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_name : ∀ i : L0_dd_name.Input, L0_dd_name.Spec.pre i → Payment_pre_dd_name i := by
  intros
  first
  | (simp_all [Payment_pre_dd_name, Payment_post_dd_name, L0_dd_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_name, Payment_post_dd_name, L0_dd_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_name Payment_post_dd_name at *; simp_all)
  | (simp_all [Payment_pre_dd_name, Payment_post_dd_name, L0_dd_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_name : ∀ (i : L0_dd_name.Input) (o : L0_dd_name.Output), L0_dd_name.Spec.pre i → Payment_post_dd_name i o → L0_dd_name.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_name, Payment_post_dd_name, L0_dd_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_name, Payment_post_dd_name, L0_dd_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_name Payment_post_dd_name at *; simp_all)
  | (simp_all [Payment_pre_dd_name, Payment_post_dd_name, L0_dd_name.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_order_no : ∀ i : L0_dd_order_no.Input, L0_dd_order_no.Spec.pre i → Payment_pre_dd_order_no i := by
  intros
  first
  | (simp_all [Payment_pre_dd_order_no, Payment_post_dd_order_no, L0_dd_order_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_order_no, Payment_post_dd_order_no, L0_dd_order_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_order_no Payment_post_dd_order_no at *; simp_all)
  | (simp_all [Payment_pre_dd_order_no, Payment_post_dd_order_no, L0_dd_order_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_order_no : ∀ (i : L0_dd_order_no.Input) (o : L0_dd_order_no.Output), L0_dd_order_no.Spec.pre i → Payment_post_dd_order_no i o → L0_dd_order_no.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_order_no, Payment_post_dd_order_no, L0_dd_order_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_order_no, Payment_post_dd_order_no, L0_dd_order_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_order_no Payment_post_dd_order_no at *; simp_all)
  | (simp_all [Payment_pre_dd_order_no, Payment_post_dd_order_no, L0_dd_order_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_password : ∀ i : L0_dd_password.Input, L0_dd_password.Spec.pre i → Payment_pre_dd_password i := by
  intros
  first
  | (simp_all [Payment_pre_dd_password, Payment_post_dd_password, L0_dd_password.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_password, Payment_post_dd_password, L0_dd_password.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_password Payment_post_dd_password at *; simp_all)
  | (simp_all [Payment_pre_dd_password, Payment_post_dd_password, L0_dd_password.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_password : ∀ (i : L0_dd_password.Input) (o : L0_dd_password.Output), L0_dd_password.Spec.pre i → Payment_post_dd_password i o → L0_dd_password.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_password, Payment_post_dd_password, L0_dd_password.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_password, Payment_post_dd_password, L0_dd_password.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_password Payment_post_dd_password at *; simp_all)
  | (simp_all [Payment_pre_dd_password, Payment_post_dd_password, L0_dd_password.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_price : ∀ i : L0_dd_price.Input, L0_dd_price.Spec.pre i → Payment_pre_dd_price i := by
  intros
  first
  | (simp_all [Payment_pre_dd_price, Payment_post_dd_price, L0_dd_price.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_price, Payment_post_dd_price, L0_dd_price.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_price Payment_post_dd_price at *; simp_all)
  | (simp_all [Payment_pre_dd_price, Payment_post_dd_price, L0_dd_price.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_price : ∀ (i : L0_dd_price.Input) (o : L0_dd_price.Output), L0_dd_price.Spec.pre i → Payment_post_dd_price i o → L0_dd_price.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_price, Payment_post_dd_price, L0_dd_price.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_price, Payment_post_dd_price, L0_dd_price.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_price Payment_post_dd_price at *; simp_all)
  | (simp_all [Payment_pre_dd_price, Payment_post_dd_price, L0_dd_price.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_quantity : ∀ i : L0_dd_quantity.Input, L0_dd_quantity.Spec.pre i → Payment_pre_dd_quantity i := by
  intros
  first
  | (simp_all [Payment_pre_dd_quantity, Payment_post_dd_quantity, L0_dd_quantity.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_quantity, Payment_post_dd_quantity, L0_dd_quantity.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_quantity Payment_post_dd_quantity at *; simp_all)
  | (simp_all [Payment_pre_dd_quantity, Payment_post_dd_quantity, L0_dd_quantity.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_quantity : ∀ (i : L0_dd_quantity.Input) (o : L0_dd_quantity.Output), L0_dd_quantity.Spec.pre i → Payment_post_dd_quantity i o → L0_dd_quantity.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_quantity, Payment_post_dd_quantity, L0_dd_quantity.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_quantity, Payment_post_dd_quantity, L0_dd_quantity.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_quantity Payment_post_dd_quantity at *; simp_all)
  | (simp_all [Payment_pre_dd_quantity, Payment_post_dd_quantity, L0_dd_quantity.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_text_description : ∀ i : L0_dd_text_description.Input, L0_dd_text_description.Spec.pre i → Payment_pre_dd_text_description i := by
  intros
  first
  | (simp_all [Payment_pre_dd_text_description, Payment_post_dd_text_description, L0_dd_text_description.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_text_description, Payment_post_dd_text_description, L0_dd_text_description.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_text_description Payment_post_dd_text_description at *; simp_all)
  | (simp_all [Payment_pre_dd_text_description, Payment_post_dd_text_description, L0_dd_text_description.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_text_description : ∀ (i : L0_dd_text_description.Input) (o : L0_dd_text_description.Output), L0_dd_text_description.Spec.pre i → Payment_post_dd_text_description i o → L0_dd_text_description.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_text_description, Payment_post_dd_text_description, L0_dd_text_description.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_text_description, Payment_post_dd_text_description, L0_dd_text_description.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_text_description Payment_post_dd_text_description at *; simp_all)
  | (simp_all [Payment_pre_dd_text_description, Payment_post_dd_text_description, L0_dd_text_description.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_total : ∀ i : L0_dd_total.Input, L0_dd_total.Spec.pre i → Payment_pre_dd_total i := by
  intros
  first
  | (simp_all [Payment_pre_dd_total, Payment_post_dd_total, L0_dd_total.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_total, Payment_post_dd_total, L0_dd_total.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_total Payment_post_dd_total at *; simp_all)
  | (simp_all [Payment_pre_dd_total, Payment_post_dd_total, L0_dd_total.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_total : ∀ (i : L0_dd_total.Input) (o : L0_dd_total.Output), L0_dd_total.Spec.pre i → Payment_post_dd_total i o → L0_dd_total.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_total, Payment_post_dd_total, L0_dd_total.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_total, Payment_post_dd_total, L0_dd_total.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_total Payment_post_dd_total at *; simp_all)
  | (simp_all [Payment_pre_dd_total, Payment_post_dd_total, L0_dd_total.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_tracking_no : ∀ i : L0_dd_tracking_no.Input, L0_dd_tracking_no.Spec.pre i → Payment_pre_dd_tracking_no i := by
  intros
  first
  | (simp_all [Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, L0_dd_tracking_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, L0_dd_tracking_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_tracking_no Payment_post_dd_tracking_no at *; simp_all)
  | (simp_all [Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, L0_dd_tracking_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_post_Payment_dd_tracking_no : ∀ (i : L0_dd_tracking_no.Input) (o : L0_dd_tracking_no.Output), L0_dd_tracking_no.Spec.pre i → Payment_post_dd_tracking_no i o → L0_dd_tracking_no.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, L0_dd_tracking_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_user_id, Payment_post_dd_user_id]; done)
  | (simp_all [Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, L0_dd_tracking_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_user_id, Payment_post_dd_user_id]; omega)
  | (unfold Payment_pre_dd_tracking_no Payment_post_dd_tracking_no at *; simp_all)
  | (simp_all [Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no, L0_dd_tracking_no.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_user_id, Payment_post_dd_user_id]; decide)

theorem trace_pre_Payment_dd_user_id : ∀ i : L0_dd_user_id.Input, L0_dd_user_id.Spec.pre i → Payment_pre_dd_user_id i := by
  intros
  first
  | (simp_all [Payment_pre_dd_user_id, Payment_post_dd_user_id, L0_dd_user_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no]; done)
  | (simp_all [Payment_pre_dd_user_id, Payment_post_dd_user_id, L0_dd_user_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no]; omega)
  | (unfold Payment_pre_dd_user_id Payment_post_dd_user_id at *; simp_all)
  | (simp_all [Payment_pre_dd_user_id, Payment_post_dd_user_id, L0_dd_user_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no]; decide)

theorem trace_post_Payment_dd_user_id : ∀ (i : L0_dd_user_id.Input) (o : L0_dd_user_id.Output), L0_dd_user_id.Spec.pre i → Payment_post_dd_user_id i o → L0_dd_user_id.Spec.post i o := by
  intros
  first
  | (simp_all [Payment_pre_dd_user_id, Payment_post_dd_user_id, L0_dd_user_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no]; done)
  | (simp_all [Payment_pre_dd_user_id, Payment_post_dd_user_id, L0_dd_user_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no]; omega)
  | (unfold Payment_pre_dd_user_id Payment_post_dd_user_id at *; simp_all)
  | (simp_all [Payment_pre_dd_user_id, Payment_post_dd_user_id, L0_dd_user_id.Spec, Payment_pre_dd_credit_card_no, Payment_post_dd_credit_card_no, Payment_pre_dd_e_mail_id, Payment_post_dd_e_mail_id, Payment_pre_dd_item_id, Payment_post_dd_item_id, Payment_pre_dd_item_name, Payment_post_dd_item_name, Payment_pre_dd_name, Payment_post_dd_name, Payment_pre_dd_order_no, Payment_post_dd_order_no, Payment_pre_dd_password, Payment_post_dd_password, Payment_pre_dd_price, Payment_post_dd_price, Payment_pre_dd_quantity, Payment_post_dd_quantity, Payment_pre_dd_text_description, Payment_post_dd_text_description, Payment_pre_dd_total, Payment_post_dd_total, Payment_pre_dd_tracking_no, Payment_post_dd_tracking_no]; decide)

theorem po1_Inventory_Accounts : Contract.Compatible InventoryContract AccountsContract := by
  intro m m' hpre hpost
  cases m with
  | req_1_4_s2 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_1_4_s2 o => cases hpost; exact trivial
  | req_1_4_s3 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_1_4_s3 o => cases hpost; exact trivial
  | req_1_4_s4 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_1_4_s4 o => cases hpost; exact trivial
  | req_3_1_3_s1 i => cases hpost; exact trace_pre_Accounts_3_1_3_s1 i hpre
  | res_3_1_3_s1 o => cases hpost; exact trivial
  | req_3_1_3_s2 i => cases hpost; exact trace_pre_Accounts_3_1_3_s2 i hpre
  | res_3_1_3_s2 o => cases hpost; exact trivial
  | req_3_1_3_s3 i => cases hpost; exact trace_pre_Accounts_3_1_3_s3 i hpre
  | res_3_1_3_s3 o => cases hpost; exact trivial
  | req_3_2_3_s2 i => cases hpost; exact trace_pre_Accounts_3_2_3_s2 i hpre
  | res_3_2_3_s2 o => cases hpost; exact trivial
  | req_3_3_3_s1 i => cases hpost; exact hpre
  | res_3_3_3_s1 o => cases hpost; exact trivial
  | req_3_3_3_s2 i => cases hpost; exact hpre
  | res_3_3_3_s2 o => cases hpost; exact trivial
  | req_3_3_3_s3 i => cases hpost; exact hpre
  | res_3_3_3_s3 o => cases hpost; exact trivial
  | req_3_4_3_s1 i => cases hpost; exact hpre
  | res_3_4_3_s1 o => cases hpost; exact trivial
  | req_3_4_3_s2 i => cases hpost; exact hpre
  | res_3_4_3_s2 o => cases hpost; exact trivial
  | req_3_4_3_s3 i => cases hpost; exact hpre
  | res_3_4_3_s3 o => cases hpost; exact trivial
  | req_3_5_3_s2 i => cases hpost; exact trace_pre_Accounts_3_5_3_s2 i hpre
  | res_3_5_3_s2 o => cases hpost; exact trivial
  | req_5_1_r5 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_5_1_r5 o => cases hpost; exact trivial
  | req_5_3_r3 i => cases hpost; exact trace_pre_Accounts_5_3_r3 i hpre
  | res_5_3_r3 o => cases hpost; exact trivial
  | req_5_3_r5 i => cases hpost; exact trace_pre_Accounts_5_3_r5 i hpre
  | res_5_3_r5 o => cases hpost; exact trivial
  | req_5_5_r5 i => cases hpost; exact trace_pre_Accounts_5_5_r5 i hpre
  | res_5_5_r5 o => cases hpost; exact trivial
  | req_ci_1 i => cases hpost; exact hpre
  | res_ci_1 o => cases hpost; exact trivial
  | req_dd_credit_card_no i => cases hpost; exact hpre
  | res_dd_credit_card_no o => cases hpost; exact trivial
  | req_dd_e_mail_id i => cases hpost; exact hpre
  | res_dd_e_mail_id o => cases hpost; exact trivial
  | req_dd_item_id i => cases hpost; exact hpre
  | res_dd_item_id o => cases hpost; exact trivial
  | req_dd_item_name i => cases hpost; exact hpre
  | res_dd_item_name o => cases hpost; exact trivial
  | req_dd_name i => cases hpost; exact hpre
  | res_dd_name o => cases hpost; exact trivial
  | req_dd_order_no i => cases hpost; exact hpre
  | res_dd_order_no o => cases hpost; exact trivial
  | req_dd_password i => cases hpost; exact hpre
  | res_dd_password o => cases hpost; exact trivial
  | req_dd_price i => cases hpost; exact hpre
  | res_dd_price o => cases hpost; exact trivial
  | req_dd_quantity i => cases hpost; exact hpre
  | res_dd_quantity o => cases hpost; exact trivial
  | req_dd_text_description i => cases hpost; exact hpre
  | res_dd_text_description o => cases hpost; exact trivial
  | req_dd_total i => cases hpost; exact hpre
  | res_dd_total o => cases hpost; exact trivial
  | req_dd_tracking_no i => cases hpost; exact hpre
  | res_dd_tracking_no o => cases hpost; exact trivial
  | req_dd_user_id i => cases hpost; exact hpre
  | res_dd_user_id o => cases hpost; exact trivial
  | req_si_1_2 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_si_1_2 o => cases hpost; exact trivial
  | req_uc_administrator_add_user i => cases hpost; exact trace_pre_Accounts_uc_administrator_add_user i hpre
  | res_uc_administrator_add_user o => cases hpost; exact trivial
  | req_uc_administrator_change_user_properties i => cases hpost; exact trace_pre_Accounts_uc_administrator_change_user_properties i hpre
  | res_uc_administrator_change_user_properties o => cases hpost; exact trivial
  | req_uc_administrator_login_administrator i => cases hpost; exact trace_pre_Accounts_uc_administrator_login_administrator i hpre
  | res_uc_administrator_login_administrator o => cases hpost; exact trivial
  | req_uc_administrator_logout_administrator i => cases hpost; exact trace_pre_Accounts_uc_administrator_logout_administrator i hpre
  | res_uc_administrator_logout_administrator o => cases hpost; exact trivial
  | req_uc_administrator_remove_plug_ins i => cases hpost; exact trace_pre_Accounts_uc_administrator_remove_plug_ins i hpre
  | res_uc_administrator_remove_plug_ins o => cases hpost; exact trivial
  | req_uc_administrator_remove_user i => cases hpost; exact trace_pre_Accounts_uc_administrator_remove_user i hpre
  | res_uc_administrator_remove_user o => cases hpost; exact trivial
  | req_uc_customer_add_item_to_cart i => cases hpost; exact hpre
  | res_uc_customer_add_item_to_cart o => cases hpost; exact trivial
  | req_uc_customer_edit_customer_details i => cases hpost; exact trace_pre_Accounts_uc_customer_edit_customer_details i hpre
  | res_uc_customer_edit_customer_details o => cases hpost; exact trivial
  | req_uc_customer_login_customer i => cases hpost; exact trace_pre_Accounts_uc_customer_login_customer i hpre
  | res_uc_customer_login_customer o => cases hpost; exact trivial
  | req_uc_customer_logout_customer i => cases hpost; exact trace_pre_Accounts_uc_customer_logout_customer i hpre
  | res_uc_customer_logout_customer o => cases hpost; exact trivial
  | req_uc_customer_register_customer i => cases hpost; exact trace_pre_Accounts_uc_customer_register_customer i hpre
  | res_uc_customer_register_customer o => cases hpost; exact trivial
  | req_uc_sales_person_add_product i => cases hpost; exact trace_pre_Accounts_uc_sales_person_add_product i hpre
  | res_uc_sales_person_add_product o => cases hpost; exact trivial
  | req_uc_sales_person_login_sales_person i => cases hpost; exact trace_pre_Accounts_uc_sales_person_login_sales_person i hpre
  | res_uc_sales_person_login_sales_person o => cases hpost; exact trivial
  | req_uc_sales_person_remove_product i => cases hpost; exact trace_pre_Accounts_uc_sales_person_remove_product i hpre
  | res_uc_sales_person_remove_product o => cases hpost; exact trivial
  | req_uc_sales_person_update_product_attributes i => cases hpost; exact trace_pre_Accounts_uc_sales_person_update_product_attributes i hpre
  | res_uc_sales_person_update_product_attributes o => cases hpost; exact trivial

theorem po1_Accounts_ShoppingCart : Contract.Compatible AccountsContract ShoppingCartContract := by
  intro m m' hpre hpost
  cases m with
  | req_1_4_s2 i => cases hpost; exact hpre
  | res_1_4_s2 o => cases hpost; exact trivial
  | req_1_4_s3 i => cases hpost; exact hpre
  | res_1_4_s3 o => cases hpost; exact trivial
  | req_1_4_s4 i => cases hpost; exact hpre
  | res_1_4_s4 o => cases hpost; exact trivial
  | req_3_1_3_s1 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_1_3_s1 o => cases hpost; exact trivial
  | req_3_1_3_s2 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_1_3_s2 o => cases hpost; exact trivial
  | req_3_1_3_s3 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_1_3_s3 o => cases hpost; exact trivial
  | req_3_2_3_s2 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_2_3_s2 o => cases hpost; exact trivial
  | req_3_3_3_s1 i => cases hpost; exact trace_pre_ShoppingCart_3_3_3_s1 i hpre
  | res_3_3_3_s1 o => cases hpost; exact trivial
  | req_3_3_3_s2 i => cases hpost; exact trace_pre_ShoppingCart_3_3_3_s2 i hpre
  | res_3_3_3_s2 o => cases hpost; exact trivial
  | req_3_3_3_s3 i => cases hpost; exact trace_pre_ShoppingCart_3_3_3_s3 i hpre
  | res_3_3_3_s3 o => cases hpost; exact trivial
  | req_3_4_3_s1 i => cases hpost; exact trace_pre_ShoppingCart_3_4_3_s1 i hpre
  | res_3_4_3_s1 o => cases hpost; exact trivial
  | req_3_4_3_s2 i => cases hpost; exact trace_pre_ShoppingCart_3_4_3_s2 i hpre
  | res_3_4_3_s2 o => cases hpost; exact trivial
  | req_3_4_3_s3 i => cases hpost; exact trace_pre_ShoppingCart_3_4_3_s3 i hpre
  | res_3_4_3_s3 o => cases hpost; exact trivial
  | req_3_5_3_s2 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_5_3_s2 o => cases hpost; exact trivial
  | req_5_1_r5 i => cases hpost; exact hpre
  | res_5_1_r5 o => cases hpost; exact trivial
  | req_5_3_r3 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_5_3_r3 o => cases hpost; exact trivial
  | req_5_3_r5 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_5_3_r5 o => cases hpost; exact trivial
  | req_5_5_r5 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_5_5_r5 o => cases hpost; exact trivial
  | req_ci_1 i => cases hpost; exact trace_pre_ShoppingCart_ci_1 i hpre
  | res_ci_1 o => cases hpost; exact trivial
  | req_dd_credit_card_no i => cases hpost; exact hpre
  | res_dd_credit_card_no o => cases hpost; exact trivial
  | req_dd_e_mail_id i => cases hpost; exact hpre
  | res_dd_e_mail_id o => cases hpost; exact trivial
  | req_dd_item_id i => cases hpost; exact hpre
  | res_dd_item_id o => cases hpost; exact trivial
  | req_dd_item_name i => cases hpost; exact hpre
  | res_dd_item_name o => cases hpost; exact trivial
  | req_dd_name i => cases hpost; exact hpre
  | res_dd_name o => cases hpost; exact trivial
  | req_dd_order_no i => cases hpost; exact hpre
  | res_dd_order_no o => cases hpost; exact trivial
  | req_dd_password i => cases hpost; exact hpre
  | res_dd_password o => cases hpost; exact trivial
  | req_dd_price i => cases hpost; exact hpre
  | res_dd_price o => cases hpost; exact trivial
  | req_dd_quantity i => cases hpost; exact hpre
  | res_dd_quantity o => cases hpost; exact trivial
  | req_dd_text_description i => cases hpost; exact hpre
  | res_dd_text_description o => cases hpost; exact trivial
  | req_dd_total i => cases hpost; exact hpre
  | res_dd_total o => cases hpost; exact trivial
  | req_dd_tracking_no i => cases hpost; exact hpre
  | res_dd_tracking_no o => cases hpost; exact trivial
  | req_dd_user_id i => cases hpost; exact hpre
  | res_dd_user_id o => cases hpost; exact trivial
  | req_si_1_2 i => cases hpost; exact hpre
  | res_si_1_2 o => cases hpost; exact trivial
  | req_uc_administrator_add_user i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_administrator_add_user o => cases hpost; exact trivial
  | req_uc_administrator_change_user_properties i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_administrator_change_user_properties o => cases hpost; exact trivial
  | req_uc_administrator_login_administrator i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_administrator_login_administrator o => cases hpost; exact trivial
  | req_uc_administrator_logout_administrator i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_administrator_logout_administrator o => cases hpost; exact trivial
  | req_uc_administrator_remove_plug_ins i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_administrator_remove_plug_ins o => cases hpost; exact trivial
  | req_uc_administrator_remove_user i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_administrator_remove_user o => cases hpost; exact trivial
  | req_uc_customer_add_item_to_cart i => cases hpost; exact trace_pre_ShoppingCart_uc_customer_add_item_to_cart i hpre
  | res_uc_customer_add_item_to_cart o => cases hpost; exact trivial
  | req_uc_customer_edit_customer_details i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_customer_edit_customer_details o => cases hpost; exact trivial
  | req_uc_customer_login_customer i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_customer_login_customer o => cases hpost; exact trivial
  | req_uc_customer_logout_customer i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_customer_logout_customer o => cases hpost; exact trivial
  | req_uc_customer_register_customer i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_customer_register_customer o => cases hpost; exact trivial
  | req_uc_sales_person_add_product i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_sales_person_add_product o => cases hpost; exact trivial
  | req_uc_sales_person_login_sales_person i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_sales_person_login_sales_person o => cases hpost; exact trivial
  | req_uc_sales_person_remove_product i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_sales_person_remove_product o => cases hpost; exact trivial
  | req_uc_sales_person_update_product_attributes i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_sales_person_update_product_attributes o => cases hpost; exact trivial

theorem po1_ShoppingCart_Payment : Contract.Compatible ShoppingCartContract PaymentContract := by
  intro m m' hpre hpost
  cases m with
  | req_1_4_s2 i => cases hpost; exact hpre
  | res_1_4_s2 o => cases hpost; exact trivial
  | req_1_4_s3 i => cases hpost; exact hpre
  | res_1_4_s3 o => cases hpost; exact trivial
  | req_1_4_s4 i => cases hpost; exact hpre
  | res_1_4_s4 o => cases hpost; exact trivial
  | req_3_1_3_s1 i => cases hpost; exact hpre
  | res_3_1_3_s1 o => cases hpost; exact trivial
  | req_3_1_3_s2 i => cases hpost; exact hpre
  | res_3_1_3_s2 o => cases hpost; exact trivial
  | req_3_1_3_s3 i => cases hpost; exact hpre
  | res_3_1_3_s3 o => cases hpost; exact trivial
  | req_3_2_3_s2 i => cases hpost; exact hpre
  | res_3_2_3_s2 o => cases hpost; exact trivial
  | req_3_3_3_s1 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_3_3_s1 o => cases hpost; exact trivial
  | req_3_3_3_s2 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_3_3_s2 o => cases hpost; exact trivial
  | req_3_3_3_s3 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_3_3_s3 o => cases hpost; exact trivial
  | req_3_4_3_s1 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_4_3_s1 o => cases hpost; exact trivial
  | req_3_4_3_s2 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_4_3_s2 o => cases hpost; exact trivial
  | req_3_4_3_s3 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_3_4_3_s3 o => cases hpost; exact trivial
  | req_3_5_3_s2 i => cases hpost; exact hpre
  | res_3_5_3_s2 o => cases hpost; exact trivial
  | req_5_1_r5 i => cases hpost; exact hpre
  | res_5_1_r5 o => cases hpost; exact trivial
  | req_5_3_r3 i => cases hpost; exact hpre
  | res_5_3_r3 o => cases hpost; exact trivial
  | req_5_3_r5 i => cases hpost; exact hpre
  | res_5_3_r5 o => cases hpost; exact trivial
  | req_5_5_r5 i => cases hpost; exact hpre
  | res_5_5_r5 o => cases hpost; exact trivial
  | req_ci_1 i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_ci_1 o => cases hpost; exact trivial
  | req_dd_credit_card_no i => cases hpost; exact trace_pre_Payment_dd_credit_card_no i hpre
  | res_dd_credit_card_no o => cases hpost; exact trivial
  | req_dd_e_mail_id i => cases hpost; exact trace_pre_Payment_dd_e_mail_id i hpre
  | res_dd_e_mail_id o => cases hpost; exact trivial
  | req_dd_item_id i => cases hpost; exact trace_pre_Payment_dd_item_id i hpre
  | res_dd_item_id o => cases hpost; exact trivial
  | req_dd_item_name i => cases hpost; exact trace_pre_Payment_dd_item_name i hpre
  | res_dd_item_name o => cases hpost; exact trivial
  | req_dd_name i => cases hpost; exact trace_pre_Payment_dd_name i hpre
  | res_dd_name o => cases hpost; exact trivial
  | req_dd_order_no i => cases hpost; exact trace_pre_Payment_dd_order_no i hpre
  | res_dd_order_no o => cases hpost; exact trivial
  | req_dd_password i => cases hpost; exact trace_pre_Payment_dd_password i hpre
  | res_dd_password o => cases hpost; exact trivial
  | req_dd_price i => cases hpost; exact trace_pre_Payment_dd_price i hpre
  | res_dd_price o => cases hpost; exact trivial
  | req_dd_quantity i => cases hpost; exact trace_pre_Payment_dd_quantity i hpre
  | res_dd_quantity o => cases hpost; exact trivial
  | req_dd_text_description i => cases hpost; exact trace_pre_Payment_dd_text_description i hpre
  | res_dd_text_description o => cases hpost; exact trivial
  | req_dd_total i => cases hpost; exact trace_pre_Payment_dd_total i hpre
  | res_dd_total o => cases hpost; exact trivial
  | req_dd_tracking_no i => cases hpost; exact trace_pre_Payment_dd_tracking_no i hpre
  | res_dd_tracking_no o => cases hpost; exact trivial
  | req_dd_user_id i => cases hpost; exact trace_pre_Payment_dd_user_id i hpre
  | res_dd_user_id o => cases hpost; exact trivial
  | req_si_1_2 i => cases hpost; exact hpre
  | res_si_1_2 o => cases hpost; exact trivial
  | req_uc_administrator_add_user i => cases hpost; exact hpre
  | res_uc_administrator_add_user o => cases hpost; exact trivial
  | req_uc_administrator_change_user_properties i => cases hpost; exact hpre
  | res_uc_administrator_change_user_properties o => cases hpost; exact trivial
  | req_uc_administrator_login_administrator i => cases hpost; exact hpre
  | res_uc_administrator_login_administrator o => cases hpost; exact trivial
  | req_uc_administrator_logout_administrator i => cases hpost; exact hpre
  | res_uc_administrator_logout_administrator o => cases hpost; exact trivial
  | req_uc_administrator_remove_plug_ins i => cases hpost; exact hpre
  | res_uc_administrator_remove_plug_ins o => cases hpost; exact trivial
  | req_uc_administrator_remove_user i => cases hpost; exact hpre
  | res_uc_administrator_remove_user o => cases hpost; exact trivial
  | req_uc_customer_add_item_to_cart i => obtain ⟨_, rfl, _⟩ := hpost; exact trivial
  | res_uc_customer_add_item_to_cart o => cases hpost; exact trivial
  | req_uc_customer_edit_customer_details i => cases hpost; exact hpre
  | res_uc_customer_edit_customer_details o => cases hpost; exact trivial
  | req_uc_customer_login_customer i => cases hpost; exact hpre
  | res_uc_customer_login_customer o => cases hpost; exact trivial
  | req_uc_customer_logout_customer i => cases hpost; exact hpre
  | res_uc_customer_logout_customer o => cases hpost; exact trivial
  | req_uc_customer_register_customer i => cases hpost; exact hpre
  | res_uc_customer_register_customer o => cases hpost; exact trivial
  | req_uc_sales_person_add_product i => cases hpost; exact hpre
  | res_uc_sales_person_add_product o => cases hpost; exact trivial
  | req_uc_sales_person_login_sales_person i => cases hpost; exact hpre
  | res_uc_sales_person_login_sales_person o => cases hpost; exact trivial
  | req_uc_sales_person_remove_product i => cases hpost; exact hpre
  | res_uc_sales_person_remove_product o => cases hpost; exact trivial
  | req_uc_sales_person_update_product_attributes i => cases hpost; exact hpre
  | res_uc_sales_person_update_product_attributes o => cases hpost; exact trivial

-- NOT PROVED: theorem po2_AccountSys : Contract.Refines ((((InventoryContract).seq AccountsContract).seq ShoppingCartContract).seq PaymentContract) AccountSysSystemSpec
