import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fisiopet/data/app_store.dart';
import 'package:fisiopet/models/models.dart';

void main() {
  Future<AppStore> demo() async {
    final store = AppStore(await SharedPreferences.getInstance());
    await store.enterDemo();
    return store;
  }

  setUp(() => SharedPreferences.setMockInitialValues({}));
  const luna = Pet(
    id: 'luna',
    name: 'Luna',
    species: 'Cão',
    age: 5,
    weight: 21.5,
    professional: 'Profissional de teste',
    plan: 'Plano informado',
  );
  const nina = Pet(
    id: 'nina',
    name: 'Nina',
    species: 'Gato',
    age: 2,
    weight: 4,
  );

  test(
    'Pets, perfil, agenda, sessões e favoritos sobrevivem à reabertura',
    () async {
      final store = await demo();
      await store.saveProfile('Gabriela', '51999999999');
      await store.savePet(luna);
      await store.saveAppointment(
        Appointment(
          id: 'a',
          petId: 'luna',
          title: 'Retorno',
          date: DateTime(2030, 12, 1, 10),
        ),
      );
      await store.addSession(
        Session(
          id: 's',
          petId: 'luna',
          activity: 'Plano individual',
          date: DateTime(2026, 11, 18),
          comfort: 4,
          notes: 'Registro de teste',
        ),
      );
      await store.toggleFavorite('caminhada');
      final restored = await demo();
      expect(restored.name, 'Gabriela');
      expect(restored.pets.single.plan, 'Plano informado');
      expect(restored.appointments.single.date, DateTime(2030, 12, 1, 10));
      expect(restored.sessions.single.notes, 'Registro de teste');
      expect(restored.favorites, {'caminhada'});
      expect(restored.selectedPet?.id, 'luna');
    },
  );
  test('Excluir um pet remove somente os dados vinculados a ele', () async {
    final store = await demo();
    await store.savePet(luna);
    await store.savePet(nina);
    for (final id in ['luna', 'nina']) {
      await store.saveAppointment(
        Appointment(
          id: 'a-$id',
          petId: id,
          title: 'Retorno',
          date: DateTime(2030),
        ),
      );
      await store.addSession(
        Session(
          id: 's-$id',
          petId: id,
          activity: 'Plano',
          date: DateTime(2026),
          comfort: 3,
        ),
      );
    }
    await store.selectPet('luna');
    await store.deletePet('luna');
    expect(store.pets.single.id, 'nina');
    expect(store.appointments.single.petId, 'nina');
    expect(store.sessions.single.petId, 'nina');
    expect(store.selectedPet?.id, 'nina');
    final restored = await demo();
    expect(restored.sessions.single.petId, 'nina');
  });
  test(
    'Editar pet substitui o registro e sair preserva a demonstração',
    () async {
      final store = await demo();
      await store.savePet(luna);
      await store.savePet(
        const Pet(
          id: 'luna',
          name: 'Luna editada',
          species: 'Cão',
          age: 6,
          weight: 22,
        ),
      );
      await store.logout();
      expect(store.signedIn, false);
      expect(store.pets, isEmpty);
      await store.enterDemo();
      expect(store.pets.single.name, 'Luna editada');
      await store.toggleFavorite('caminhada');
      await store.toggleFavorite('caminhada');
      expect(store.favorites, isEmpty);
    },
  );
}
