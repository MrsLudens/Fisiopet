import 'package:flutter/material.dart';
import '../data/app_scope.dart';
import '../widgets/app_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final pet = store.selectedPet;
    final upcoming =
        store.appointments
            .where((a) => !a.done && a.date.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final count = store.sessions.where((s) => s.petId == pet?.id).length;
    return AppPage(
      title: 'FisioPet',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Olá, ${store.name}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text('Um passo de cada vez, juntos.'),
          const SizedBox(height: 24),
          if (pet == null)
            EmptyState(
              title: 'Vamos conhecer seu pet?',
              description:
                  'Cadastre seu companheiro para organizar o acompanhamento.',
              button: 'Cadastrar pet',
              onPressed: () => Navigator.pushNamed(context, '/cadastrar-pet'),
            )
          else ...[
            const PetPicker(),
            InfoCard(
              icon: Icons.pets,
              title: pet.name,
              subtitle:
                  '${pet.species} • ${pet.age} anos • ${pet.weight.toStringAsFixed(1)} kg',
              onTap: () => Navigator.pushNamed(
                context,
                '/detalhes-pet',
                arguments: pet.id,
              ),
            ),
            Row(
              children: [
                Expanded(child: _Metric('$count', 'registros de atividade')),
                const SizedBox(width: 12),
                Expanded(
                  child: _Metric(
                    '${upcoming.where((a) => a.petId == pet.id).length}',
                    'compromissos futuros',
                  ),
                ),
              ],
            ),
          ],
          const SectionTitle('Cuidados no dia a dia'),
          InfoCard(
            icon: Icons.fitness_center,
            title: 'Atividades do plano',
            subtitle: 'Consulte e registre as orientações recebidas',
            onTap: () => Navigator.pushNamed(context, '/exercicios'),
          ),
          InfoCard(
            icon: Icons.insights,
            title: 'Progresso',
            subtitle: 'Histórico e observações por pet',
            onTap: () => Navigator.pushNamed(context, '/progresso'),
          ),
          InfoCard(
            icon: Icons.menu_book,
            title: 'Dicas e organização',
            subtitle: 'Prepare sua rotina de acompanhamento',
            onTap: () => Navigator.pushNamed(context, '/dicas'),
          ),
          const SectionTitle('Próximo compromisso'),
          if (upcoming.isEmpty)
            const Text('Nenhum compromisso futuro. Adicione um na agenda.')
          else
            InfoCard(
              icon: Icons.event,
              title: upcoming.first.title,
              subtitle:
                  '${store.petName(upcoming.first.petId)} • ${dateLabel(upcoming.first.date)} às ${timeLabel(upcoming.first.date)}',
              onTap: () => Navigator.pushNamed(context, '/agenda'),
            ),
          const SizedBox(height: 24),
          const Text(
            'O FisioPet apoia o acompanhamento do plano individual do seu pet. As atividades devem ser orientadas pelo profissional responsável.',
            style: TextStyle(color: Color(0xFF626D7F)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String value, label;
  const _Metric(this.value, this.label);
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
