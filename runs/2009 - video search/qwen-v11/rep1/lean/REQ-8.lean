import ContractForge
open ContractForge

-- REQ-8: Results will be arranged in length/date/alphabetical order by clicking on the column headers.
-- compiles: False · rejects_bad_example: None · checked: False

structure Video where
  title   : String
  length  : Nat
  date    : Nat  -- in seconds since epoch
  deriving DecidableEq, Repr

structure Input where
  videos : List Video
  deriving DecidableEq, Repr

structure Output where
  videos : List Video
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.videos.Nodup
  post := fun i o => List.Pairwise (fun a b => a.length ≤ b.length) o.videos ∧
                     (o.videos.length = i.videos.length →
                      ∀ a b, a ∈ i.videos ∧ b ∈ i.videos ∧ a.length = b.length →
                      ∃ p, a = p.1 ∧ b = p.2 ∧ p.2.date ≤ p.1.date) ∧
                     (o.videos.length = i.videos.length →
                      ∀ a b, a ∈ i.videos ∧ b ∈ i.videos ∧ a.date = b.date →
                      ∃ p, a = p.1 ∧ b = p.2 ∧ p.2.title ≤ p.1.title)

example : Spec.pre { videos := [{ title := "A", length := 10, date := 100 },
                                 { title := "B", length := 10, date := 200 },
                                 { title := "C", length := 20, date := 300 }] } ∧
          Spec.post { videos := [{ title := "A", length := 10, date := 100 },
                                  { title := "B", length := 10, date := 200 },
                                  { title := "C", length := 20, date := 300 }] }
                    { videos := [{ title := "A", length := 10, date := 100 },
                                 { title := "B", length := 10, date := 200 },
                                 { title := "C", length := 20, date := 300 }] } := by
  unfold Spec; decide
