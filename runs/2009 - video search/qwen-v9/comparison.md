# Before/after: `qwen-v8` → `qwen-v9`

Document: `2009 - video search.xml` · model: `qwen`

## Totals

| | qwen-v8 | qwen-v9 | Δ |
|---|---|---|---|
| entries | 19 | 21 | +2 |
| compile | 19 (100%) | 17 (81%) | -2 |
| rejects a bad example | 10 (53%) | 9 (43%) | -1 |
| L0 OK (checked) | 15 (79%) | 13 (62%) | -2 |
| L0 failed | 4 (21%) | 8 (38%) | +4 |
| L0.5 ✅ pass | 7 (37%) | 9 (43%) | +2 |
| L0.5 ⚠️ flag | 9 (47%) | 4 (19%) | -5 |
| L0.5 ❌ fail | 3 (16%) | 8 (38%) | +5 |
| first-attempt OK | 11 (58%) | 11 (52%) | +0 |
| mean attempts | 2.32 | 2.71 | +0.39 |
| total seconds | 382 | 606 | +224 |

On the 16 entries present in both runs: L0 OK 13 → 13, L0.5 pass 5 → 9, L0.5 fail 2 → 3.

## Entries added / removed by the parser

| | Entry | Text | L0.5 |
|---|---|---|---|
| + | `REQ-6` | Results will be arranged in size/date/alphabetical order by clicking on the column headers | ❌ |
| + | `REQ-8` | Results will be arranged in length/date/alphabetical order by clicking on the column heade | ❌ |
| + | `REQ-4#3` | Any torrent result with 0 seeds will not be displayed. | ❌ |
| + | `REQ-6#3` | A results page will display 100 results. | ❌ |
| + | `REQ-7#3` | Any torrent result with a rating of less than 1 will not be displayed. | ❌ |
| − | `1.3/S1` | This Video Searching software will be a system that uses an active internet connection to  | (was ✅) |
| − | `1.3/S4` | It provides tools to help when navigating through search results which will save time and  | (was ❌) |
| − | `1.3/S7` | The system will contain databases of the different websites that will be used within the s | (was ✅) |

## Improved (5)

| Entry | L0 qwen-v8 → qwen-v9 | L0.5 | Reasons now |
|---|---|---|---|
| `REQ-3` | OK → OK | ⚠️ → ✅ | — |
| `REQ-5` | OK → OK | ⚠️ → ✅ | — |
| `REQ-3#2` | OK → OK | ⚠️ → ✅ | — |
| `REQ-4#2` | OK → OK | ⚠️ → ✅ | — |
| `REQ-7#2` | FAILED → OK | ⚠️ → ✅ | — |

## Regressed (1)

| Entry | L0 qwen-v8 → qwen-v9 | L0.5 | Reasons now |
|---|---|---|---|
| `REQ-6#2` | OK → FAILED | ✅ → ❌ | does not compile |

## Failing L0.5 in qwen-v9 (8)

| Entry | Text | Reasons |
|---|---|---|
| `REQ-1` | Torrent search will share the same search bar with the streaming search. | does not compile |
| `REQ-4` | Query will retrieve the no. of seed and peers, size of the file, date posted and a link to | `post` accepts an output the requirement forbids: example : Spec.pre { query := "test", torrents := [{ seed := 1, peer := 1, size := 1, date := "", link := "http://example.com" }] } ∧ ¬ Spec.post { qu |
| `REQ-6` | Results will be arranged in size/date/alphabetical order by clicking on the column headers | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| `REQ-6#2` | Query to video link sites will retrieve the show's name, episode name and a link to the we | does not compile |
| `REQ-8` | Results will be arranged in length/date/alphabetical order by clicking on the column heade | does not compile |
| `REQ-4#3` | Any torrent result with 0 seeds will not be displayed. | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output; `pre` is `True`: the spec assumes nothing about the input |
| `REQ-6#3` | A results page will display 100 results. | does not compile |
| `REQ-7#3` | Any torrent result with a rating of less than 1 will not be displayed. | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |

Model output varies from run to run, so single-entry flips are noisy; compare totals and patterns.
