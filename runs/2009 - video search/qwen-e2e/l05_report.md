# L0.5 report — 2009 - video search.xml (qwen)

Compiles: 18/21 · rejects a bad example: 12 · ✅ pass 14 · ⚠️ flagged 1 · ❌ fail 6

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `REQ-1` | requirement | — |
| ✅ | `REQ-2` | requirement | — |
| ✅ | `REQ-3` | requirement | — |
| ✅ | `REQ-4` | requirement | — |
| ✅ | `REQ-5` | requirement | — |
| ❌ | `REQ-6` | requirement | does not compile |
| ❌ | `REQ-1#2` | requirement | `post` accepts an output the requirement forbids: example : Spec.pre { query := "streaming_video_123" } ∧ ¬ Spec.post { query := "streaming_video_123" } { results := ["torrent_search_result_1", "torrent_search_result_2"], message := "Results found." } := by unfold Spec; decide |
| ✅ | `REQ-2#2` | requirement | — |
| ✅ | `REQ-3#2` | requirement | — |
| ✅ | `REQ-4#2` | requirement | — |
| ⚠️ | `REQ-5#2` | requirement | could not test whether `post` rejects anything (no field types to vary) |
| ❌ | `REQ-6#2` | requirement | does not compile |
| ✅ | `REQ-7#2` | requirement | — |
| ❌ | `REQ-8` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `REQ-1#3` | requirement | — |
| ✅ | `REQ-2#3` | requirement | — |
| ✅ | `REQ-3#3` | requirement | — |
| ✅ | `REQ-4#3` | requirement | — |
| ✅ | `REQ-5#3` | requirement | — |
| ❌ | `REQ-6#3` | requirement | does not compile |
| ❌ | `REQ-7#3` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
