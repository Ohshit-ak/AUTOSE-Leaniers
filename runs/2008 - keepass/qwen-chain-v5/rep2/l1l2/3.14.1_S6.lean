import ContractForge
open ContractForge

-- 3.14.1/S6: Doing this he will be transferred at KeePass website and choose the language he wants for downloading.

-- L0 spec

structure Input where
  language : String
  deriving DecidableEq, Repr

structure Output where
  transferred : Bool
  message     : String
  deriving DecidableEq, Repr

def Spec : Contract Input Output where
  pre  := fun i => i.language ≠ ""
  post := fun i o => (o.transferred = true ↔
    i.language = "en" → o.message = "You have been transferred to the English version of the KeePass website."
    ∨ i.language = "fr" → o.message = "Vous avez été redirigé vers la version française du site web KeePass."
    ∨ i.language = "de" → o.message = "Sie wurden zur deutschen Version der KeePass-Website umgeleitet."
    ∨ i.language = "es" → o.message = "Se ha redirigido a la versión española del sitio web KeePass."
    ∨ i.language = "it" → o.message = "Hai been trasferito alla versione italiana del sito web KeePass."
    ∨ i.language = "ru" → o.message = "Вы были перенаправлены на русскую версию сайта KeePass."
    ∨ i.language = "ja" → o.message = "あなたはKeePassウェブサイトの日本語版に転送されました。"
    ∨ i.language = "zh" → o.message = "您已被转到KeePass网站的中文版本。"
    ∨ o.message = "Unsupported language. Please choose a valid language."
  )

example : Spec.pre { language := "en" } ∧
          Spec.post { language := "en" }
                    { transferred := true, message := "You have been transferred to the English version of the KeePass website." } := by
  unfold Spec; decide

-- L1 architecture (mode=single, success=True)

-- not split (`post` is a single condition): the one component is `Spec` itself
theorem po2 : Contract.Refines Spec Spec :=
  ⟨fun _ h => h, fun _ _ _ h => h⟩

-- L2 Spec (success=True)

def SpecImpl (x : Input) : Output :=
  { transferred := true,
    message := match x.language with
      | "en" => "You have been transferred to the English version of the KeePass website."
      | "fr" => "Vous avez été redirigé vers la version française du site web KeePass."
      | "de" => "Sie wurden zur deutschen Version der KeePass-Website umgeleitet."
      | "es" => "Se ha redirigido a la versión española del sitio web KeePass."
      | "it" => "Hai been trasferito alla versione italiana del sito web KeePass."
      | "ru" => "Вы были перенаправлены на русскую версию сайта KeePass."
      | "ja" => "あなたはKeePassウェブサイトの日本語版に転送されました。"
      | "zh" => "您已被转到KeePass网站的中文版本。"
      | _ => "Unsupported language. Please choose a valid language."
    }

theorem SpecImpl_ok : Spec.Satisfies SpecImpl := by
  discharge_po3 [Spec, SpecImpl]

-- end to end (checked=True)

theorem system_ok : Spec.Satisfies SpecImpl :=
  Contract.refines_sound po2 SpecImpl_ok
