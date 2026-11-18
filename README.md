# FisioPet

Aplicativo Flutter de apoio à organização do acompanhamento domiciliar de cães e gatos. Mantém a identidade azul/roxo das primeiras telas e acrescenta o restante do fluxo de interface, com dados persistentes.

## Executar no VS Code / Windows

Use Flutter 3.35.7 ou superior compatível com o projeto. Abra esta pasta no VS Code, com as extensões Flutter e Dart, e execute:

```powershell
flutter pub get
flutter run -d chrome
```

Na tela Entrar, toque em **Explorar demonstração**. Não é necessário cadastrar senha. Cadastre um pet para usar agenda e histórico. O perfil de demonstração permanece no mesmo navegador/dispositivo após fechar e abrir o aplicativo. Limpar o armazenamento do navegador remove esses dados. O cadastro sem Firebase cria apenas um perfil local de teste, claramente identificado na interface.

Requisitos nativos ajustados para Android 6 (API 23) e iOS 15. Para Android, abra um emulador e execute `flutter run`. Esta atualização preserva os arquivos Android e iOS existentes; Android/iOS precisam de validação nas respectivas plataformas.

## Funcionalidades

- Start Page, escolha de acesso, cadastro e recuperação de senha.
- Login, cadastro e recuperação reais por Firebase Authentication quando configurado.
- Home com seleção de pet, contagem de registros e próximo compromisso.
- Múltiplos pets: cadastrar, editar, excluir e consultar perfil.
- Questionário descritivo: condição informada, objetivo, profissional e plano recebido.
- Catálogo para organizar atividades orientadas, com busca e favoritos.
- Registro de atividade realizada, data, percepção subjetiva do tutor e observações.
- Agenda: criar, editar, excluir e concluir compromissos por pet; filtro para todos.
- Progresso: gráfico dos últimos sete dias e histórico separado por pet.
- Dicas de organização com busca; perfil editável e saída da sessão.
- Demonstração salva localmente; dados reais em documento privado do Firestore por usuário.
- Formulários em português, validação, estados vazios e feedback de erro/salvamento.

O catálogo não contém prescrição, dosagem, vídeos ou exercícios personalizados gerados automaticamente. O tutor registra as orientações que recebeu do profissional. A percepção subjetiva de 1 a 5 e o número de registros não representam avaliação clínica.

## Configurar Firebase

Leia [docs/FIREBASE.md](docs/FIREBASE.md). Sem configuração, o aplicativo abre normalmente no modo demonstração. O projeto não contém credenciais administrativas.

## Rotas

| Rota | Tela |
|---|---|
| `/` | Boas-vindas |
| `/login-select` | Escolha de acesso |
| `/login` | Entrar |
| `/cadastro` | Cadastro / perfil local de teste |
| `/recuperar-senha` | Recuperação |
| `/home` | Início |
| `/pets` | Meus pets |
| `/cadastrar-pet` | Cadastro e questionário do pet |
| `/detalhes-pet` | Perfil do pet; argumento: ID |
| `/editar-pet` | Edição; argumento: ID |
| `/exercicios` | Atividades e favoritos |
| `/detalhes-exercicio` | Detalhe; argumento: ID da atividade |
| `/registrar-sessao` | Registro; argumento opcional: ID da atividade |
| `/agenda` | Agenda |
| `/novo-compromisso` | Criar compromisso |
| `/editar-compromisso` | Editar; argumento: ID |
| `/progresso` | Histórico do pet selecionado |
| `/dicas` | Dicas de organização |
| `/perfil` | Perfil do tutor |

Rotas internas exigem sessão de demonstração ou conta autenticada. Após sair, o histórico de navegação é limpo. A barra inferior permite alternar entre Início, Pets, Agenda e Perfil.

## Validação

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Os testes verificam persistência local, exclusão vinculada ao pet correto, navegação, validação e isolamento do progresso. O workflow GitHub Actions repete análise, testes e compilação Web. A integração Firebase precisa de um projeto real ou de testes próprios com emuladores antes de disponibilizar para usuários.

## Limitações atuais

- Agenda sem push/FCM ou notificações em segundo plano.
- Sem envio de fotos, portal de profissionais ou exportação de relatório.
- Marca provisória de patinha: ainda é necessário o arquivo original da logo.
- Armazenamento Firestore inicial em um documento por tutor, apropriado para piloto pequeno. Não edite simultaneamente em mais de um dispositivo: a última gravação substitui o documento. Para produção, migrar pets, sessões e compromissos para subcoleções com paginação; documentos Firestore têm limite de tamanho.
- O modo de demonstração guarda apenas um perfil local por instalação. Não use dados sensíveis para demonstrações compartilhadas.

## Atualizar no GitHub

Se baixar o projeto como ZIP, copie os arquivos para o clone existente e revise as alterações antes de enviar:

```powershell
git status
git add .
git commit -m "Completa fluxo do FisioPet"
git push
```
