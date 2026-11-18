# Conectar seu Firebase

Esta configuração ativa **Firebase Authentication (e-mail e senha)** e **Cloud Firestore**. Sem ela, o aplicativo oferece demonstração local, sem autenticação real.

1. No Console Firebase, crie ou selecione o projeto do FisioPet.
2. Registre o aplicativo Web e copie sua configuração de cliente. Para Android, registre o app Android e use o `appId` correspondente. O app usa `Firebase.initializeApp(options: ...)` com os valores fornecidos, sem gerar `firebase_options.dart`.
3. Em Authentication → Sign-in method, habilite E-mail/senha. Em domínios autorizados, inclua o domínio usado para testes Web (por exemplo, localhost).
4. Crie o banco **Cloud Firestore**. Publique as regras de `firestore.rules` na aba Regras. Não deixe o banco em modo de teste aberto.
5. Copie `firebase.config.example.json` para `firebase.config.json` e preencha os valores. Use um arquivo por plataforma se os IDs forem diferentes. O arquivo real está no `.gitignore`.

```powershell
Copy-Item firebase.config.example.json firebase.config.json
flutter run -d chrome --dart-define-from-file=firebase.config.json
```

Campos esperados:

| Campo | Configuração Firebase |
|---|---|
| FIREBASE_API_KEY | apiKey |
| FIREBASE_APP_ID | appId, específico da plataforma |
| FIREBASE_MESSAGING_SENDER_ID | messagingSenderId |
| FIREBASE_PROJECT_ID | projectId |
| FIREBASE_AUTH_DOMAIN | authDomain (Web) |
| FIREBASE_STORAGE_BUCKET | storageBucket, se disponível |

São valores de configuração de cliente. Não coloque chaves privadas, contas de serviço ou segredos administrativos nesse arquivo. Os dados são protegidos pelas regras do Firestore e pelo UID autenticado, não pelo sigilo da chave pública de cliente.

## Testar a integração

- Criar conta; sair; entrar de novo com a mesma conta.
- Criar um pet, compromisso e registro; sair e confirmar que os dados retornam após novo login.
- Recuperar senha e concluir o fluxo pelo e-mail recebido.
- Criar outra conta e confirmar que ela não vê os dados da primeira.
- Tentar acessar `/users/UID-DE-OUTRO-USUARIO` via cliente autenticado e conferir a negação pelas regras.
- Confirmar que falhas de gravação exibem aviso e não deixam uma alteração aparentemente salva.

Dados reais: documento `users/{uid}` com perfil, lista de pets, agenda, sessões e favoritos. As gravações precisam de conexão. Para um piloto, mantenha baixo o volume de registros; antes de produção, use subcoleções e paginação para evitar o limite de tamanho do documento e conflitos entre dispositivos.

## Pendências de serviço

Esta atualização não cria nem publica um projeto Firebase e não ativa faturamento. Push/FCM, notificações agendadas, anexos e exclusão de conta não foram implementados. O campo `FIREBASE_MESSAGING_SENDER_ID` é exigido pela configuração do Firebase, mas não significa que notificações estão ativas.

Referências oficiais: [Configuração Flutter](https://firebase.google.com/docs/flutter/setup), [Authentication](https://firebase.google.com/docs/auth/flutter/password-auth), [Regras Firestore](https://firebase.google.com/docs/firestore/security/get-started).
