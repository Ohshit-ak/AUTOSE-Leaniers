# L0.5 report — 1998 - themas.xml (qwen)

Compiles: 22/30 · rejects a bad example: 17 · ✅ pass 19 · ⚠️ flagged 3 · ❌ fail 8

| | Entry | Kind | Reasons |
|---|---|---|---|
| ✅ | `2.4/S4` | requirement | — |
| ✅ | `3.1.1.1.3/S1` | requirement | — |
| ✅ | `3.1.1.2.1/S1` | requirement | — |
| ✅ | `3.1.1.2.3/S2` | requirement | — |
| ✅ | `3.1.1.3.1/S1` | requirement | — |
| ✅ | `3.1.1.3.3/S1` | requirement | — |
| ❌ | `3.1.1.3.3/S2` | requirement | does not compile |
| ✅ | `3.1.3.3/S1` | requirement | — |
| ✅ | `3.1.3.3/S3` | requirement | — |
| ❌ | `3.1.3.3/S4` | requirement | does not compile |
| ❌ | `3.1.3.3/S6` | requirement | does not compile |
| ✅ | `3.1.4.1.1/S1` | requirement | — |
| ⚠️ | `3.1.4.1.3/S1` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { reportedTemp := 101, setting := 100, upperLimit := 150, lowerLimit := 50 } { status := "within limits" }` holds, but the requirement forbids this output for this input (The requirement states that the system shall detect when the temperatur |
| ⚠️ | `3.1.4.1.3/S2` | requirement | `pre` is `True`, but the requirement states a condition (if / when / only / unless / logged in …) |
| ✅ | `3.1.5.1.1/S2` | requirement | — |
| ✅ | `3.1.5.1.3/S3` | requirement | — |
| ✅ | `3.1.5.1.3/S4` | requirement | — |
| ✅ | `3.1.5.1.3/S5` | requirement | — |
| ✅ | `3.1.5.1.3/S6` | requirement | — |
| ❌ | `3.1.5.1.3/S7` | requirement | does not compile |
| ✅ | `3.1.5.3.3/S2` | requirement | — |
| ✅ | `3.1.6.3/S1` | requirement | — |
| ✅ | `3.1.6.3/S5` | requirement | — |
| ❌ | `3.1.6.3/S6` | requirement | does not compile |
| ✅ | `3.1.7.3/S1` | requirement | — |
| ❌ | `3.1.7.3/S2` | requirement | does not compile |
| ⚠️ | `3.1.7.3/S5` | requirement | compiles, but the generation loop's own checks failed: L0.5: your spec accepts a forbidden behaviour: `Spec.post { temperatureLimitExceeded := true, temperature := 10, limit := 5 } { beepFrequency := 1000 }` holds, but the requirement forbids this output for this input (The requirement states that the system shall output a continuous series of alternati |
| ❌ | `3.1.9.1/S1` | requirement | does not compile |
| ✅ | `3.1.10.3/S3` | requirement | — |
| ❌ | `3.1.10.3/I2` | requirement | does not compile |
