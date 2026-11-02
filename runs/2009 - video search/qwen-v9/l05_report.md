# L0.5 report — 2009 - video search.xml (qwen)

Compiles: 17/21 · rejects a bad example: 9 · ✅ pass 9 · ⚠️ flagged 4 · ❌ fail 8

| | Entry | Kind | Reasons |
|---|---|---|---|
| ❌ | `REQ-1` | requirement | does not compile |
| ✅ | `REQ-2` | requirement | — |
| ✅ | `REQ-3` | requirement | — |
| ❌ | `REQ-4` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { query := "test", torrents := [{ seed := 1, peer := 1, size := 1, date := "", link := "http://example.com" }] } ∧ ¬ Spec.post { query := "test", torrents := [{ seed := 1, peer := 1, size := 1, date := "", link := "http://example.com" }] } { results := [{ seed := 1, peer := 1, size := 1, date := "", link := "http://example.com" }], message := "Results found." } := by unfold Spec; decide |
| ✅ | `REQ-5` | requirement | — |
| ❌ | `REQ-6` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `REQ-1#2` | requirement | — |
| ✅ | `REQ-2#2` | requirement | — |
| ✅ | `REQ-3#2` | requirement | — |
| ✅ | `REQ-4#2` | requirement | — |
| ✅ | `REQ-5#2` | requirement | — |
| ❌ | `REQ-6#2` | requirement | does not compile |
| ✅ | `REQ-7#2` | requirement | — |
| ❌ | `REQ-8` | requirement | does not compile |
| ⚠️ | `REQ-1#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-2#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-3#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ❌ | `REQ-4#3` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output; `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-5#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ❌ | `REQ-6#3` | requirement | does not compile |
| ❌ | `REQ-7#3` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
