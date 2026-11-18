import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fisiopet/main.dart';
import 'package:fisiopet/data/app_store.dart';
import 'package:fisiopet/models/models.dart';

void main() {
  testWidgets(
    'Fluxo completo de entrada, pet e registro no tamanho de celular',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final store = AppStore(await SharedPreferences.getInstance());
      await tester.pumpWidget(FisioPetApp(store: store));
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Explorar demonstração'));
      await tester.tap(find.text('Explorar demonstração'));
      await tester.pumpAndSettle();
      expect(find.text('Olá, Tutor!'), findsOneWidget);
      await tester.tap(find.text('Cadastrar pet'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do pet'),
        'Luna',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Idade em anos completos'),
        '5',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Peso (kg)'),
        '21,5',
      );
      await tester.scrollUntilVisible(
        find.text('Salvar pet'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Salvar pet'));
      await tester.pumpAndSettle();
      expect(store.pets.single.name, 'Luna');
      expect(find.text('Luna'), findsWidgets);
      await tester.scrollUntilVisible(
        find.text('Progresso'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Progresso'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Registrar atividade'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Atividade realizada'),
        'Atividade prescrita de teste',
      );
      await tester.scrollUntilVisible(
        find.text('Salvar registro'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.scrollUntilVisible(
        find.text('Salvar registro'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar registro'));
      await tester.pumpAndSettle();
      expect(store.sessions.single.activity, 'Atividade prescrita de teste');
      await tester.scrollUntilVisible(
        find.text('Atividade prescrita de teste'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Atividade prescrita de teste'), findsOneWidget);
      // Framework reports render errors at the end of the test.
    },
  );
  testWidgets('Rotas internas são protegidas e telas vazias não falham', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(FisioPetApp(store: store));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/home');
    await tester.pumpAndSettle();
    expect(find.text('Explorar demonstração'), findsOneWidget);
    await store.enterDemo();
    for (final route in [
      '/home',
      '/pets',
      '/agenda',
      '/perfil',
      '/exercicios',
      '/progresso',
      '/dicas',
      '/cadastrar-pet',
      '/novo-compromisso',
      '/registrar-sessao',
      '/detalhes-pet',
    ]) {
      navigator.pushNamed(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
      navigator.pop();
      await tester.pumpAndSettle();
    }
  });
  testWidgets('Validação de campos e separação do progresso por pet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore(await SharedPreferences.getInstance());
    await store.enterDemo();
    await store.savePet(
      const Pet(id: 'a', name: 'Luna', species: 'Cão', age: 5, weight: 20),
    );
    await store.savePet(
      const Pet(id: 'b', name: 'Nina', species: 'Gato', age: 2, weight: 4),
    );
    await store.addSession(
      Session(
        id: 's',
        petId: 'a',
        activity: 'Somente Luna',
        date: DateTime.now(),
        comfort: 3,
      ),
    );
    await tester.pumpWidget(FisioPetApp(store: store));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/progresso');
    await tester.pumpAndSettle();
    expect(find.text('Somente Luna'), findsNothing);
    await store.selectPet('a');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Somente Luna'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Somente Luna'), findsOneWidget);
    navigator.pushNamed('/cadastrar-pet');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Salvar pet'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Salvar pet'));
    await tester.pumpAndSettle();
    expect(store.pets.length, 2);
  });
}
