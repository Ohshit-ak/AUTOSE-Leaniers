# L0.5 report — 2009 - video search.xml (qwen)

Compiles: 19/19 · rejects a bad example: 10 · ✅ pass 7 · ⚠️ flagged 9 · ❌ fail 3

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `1.3/S1` | requirement | — |
| ❌ | `1.3/S4` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `1.3/S7` | requirement | — |
| ❌ | `REQ-1` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output |
| ✅ | `REQ-2` | requirement | — |
| ⚠️ | `REQ-3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ❌ | `REQ-4` | requirement | `post` accepted every changed output we tried (each field of the example output changed in turn), so it does not constrain the output; `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-5` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ✅ | `REQ-1#2` | requirement | — |
| ✅ | `REQ-2#2` | requirement | — |
| ⚠️ | `REQ-3#2` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-4#2` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ✅ | `REQ-5#2` | requirement | — |
| ✅ | `REQ-6#2` | requirement | — |
| ⚠️ | `REQ-7#2` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-1#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-2#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-3#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
| ⚠️ | `REQ-5#3` | requirement | `pre` is `True`: the spec assumes nothing about the input |
