# TorciEmail iOS

Client iOS SwiftUI per la gestione di email certificate (EviMail), con architettura MVVM, repository pattern e integrazione backend Vapor.

## Obiettivi del progetto

- comporre e inviare email certificate con opzioni avanzate
- consultare mailbox e dettaglio eventi certificati
- scaricare/aprire allegati e affidavit gia inclusi nel payload API
- gestire autenticazione JWT e sessione utente in modo robusto

## Stack tecnico

- Swift 5 / SwiftUI
- Combine (`@Published`, observer sessione)
- URLSession (client HTTP)
- Keychain (persistenza token JWT)
- QuickLook (`QLPreviewController`) via wrapper SwiftUI

## Architettura (layer a pila)

1. **Presentation (Views)**
   - schermate SwiftUI: mailbox, compose, dettaglio email, certificati.
   - responsabilita: rendering UI, binding stato, dispatch intent utente.

2. **ViewModel (MVVM)**
   - `AuthViewModel`, `MailboxViewModel`, `ComposeMailViewModel`.
   - responsabilita: orchestrazione use-case UI, validazioni, stato asincrono, mapping errori per la view.

3. **Domain**
   - modelli applicativi (`EmailItem`, `EmailDraft`, ecc.).
   - protocolli repository (`AuthRepository`, `EmailRepository`).
   - servizi astratti (`SessionExpirationService`, `FileStorageService`).

4. **Data**
   - implementazioni repository (`AuthRepositoryImpl`, `EmailRepositoryImpl`).
   - DTO request/response.
   - mapper (`EviMailMapper`) da DTO a domain.

5. **Infrastructure**
   - `VaporAPIService` per chiamate HTTP.
   - `KeychainManager` per token.
   - storage file locale in Documents per allegati/certificati.

## Pattern adottati

- **MVVM**: separa UI da logica di presentazione.
- **Repository Pattern**: disaccoppia ViewModel dal datasource remoto.
- **Dependency Injection**: repository/servizi iniettati nei ViewModel.
- **Mapper Pattern**: converte DTO esterni in modelli dominio stabili.

## Flusso dati: composizione e invio email

1. L'utente compila destinatari, oggetto, corpo e opzioni in compose.
2. `ComposeMailViewModel` valida i campi e costruisce `EmailDraft`.
3. Se presente un file, usa `sendEmailWithAttachment`; altrimenti `sendEmail`.
4. `EmailRepositoryImpl` mappa `EmailDraft` in DTO submit e invia tramite `VaporAPIService`.
5. La risposta API ritorna l'`eviId`; il ViewModel aggiorna stato/esito UI.

## Flusso dati: visualizzazione email e download file

1. La mailbox carica lista email (`query-all`) e mappa DTO in `EmailItem`.
2. Il dettaglio email richiede `get-by-id` con inclusione affidavits/allegati.
3. Gli allegati e affidavit arrivano in base64 nel payload (`attachments.data`, `affidavits.bytes`).
4. `MailboxViewModel` decodifica base64, salva in Documents via `FileStorageService`.
5. La view apre il file con `FilePreviewSheet` (QuickLook).

> Nota: il download file lato client non richiede endpoint separati quando i blob sono gia nel dettaglio email.

## Autenticazione JWT

- login via endpoint backend -> token JWT salvato in Keychain.
- token inviato come `Authorization: Bearer <token>` per endpoint protetti.
- gestione scadenza:
  - controllo data `exp` dal JWT lato repository auth.
  - monitoraggio periodico in `AuthViewModel`.
  - gestione `401` centralizzata in `VaporAPIService` con notifica sessione scaduta.

## Confini server-client

### Server (Vapor)
- autenticazione/autorizzazione
- logica applicativa certificazione
- persistenza e integrazione eCertia
- emissione payload strutturati (DTO API)

### Client iOS (TorciEmail)
- esperienza utente e stato locale
- validazioni di input pre-submit
- mapping DTO -> dominio -> presentazione
- gestione file locale e preview

## Struttura cartelle (sintesi)

- `TorciEmail/Views`: UI SwiftUI
- `TorciEmail/ViewModels`: logica di presentazione
- `TorciEmail/Domain`: modelli e contratti applicativi
- `TorciEmail/Data`: networking, repository, DTO, mapper, security

## Convenzioni manutenzione

- le Views non accedono direttamente al networking
- i ViewModel dipendono da protocolli, non da implementazioni concrete
- ogni errore infrastrutturale va mappato in errore di dominio user-friendly
- evitare log di debug permanenti nel codice di produzione

