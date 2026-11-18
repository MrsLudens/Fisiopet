import 'package:flutter/material.dart';
import '../data/app_scope.dart';
import '../widgets/app_ui.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final pet = store.selectedPet;
    final list = store.sessions.where((s) => s.petId == pet?.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final today = DateUtils.dateOnly(DateTime.now());
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final counts = days
        .map((d) => list.where((s) => DateUtils.isSameDay(s.date, d)).length)
        .toList();
    final maxCount = counts.fold<int>(1, (max, n) => n > max ? n : max);
    return AppPage(
      title: 'Progresso',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PetPicker(),
          const SectionTitle('Últimos 7 dias'),
          if (pet != null) ...[
            const Text(
              'Registros por dia • frequência não indica recuperação clínica.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  7,
                  (i) => Expanded(
                    child: Semantics(
                      label: '${dateLabel(days[i])}: ${counts[i]} registros',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${counts[i]}'),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor:
                                      .08 + .92 * counts[i] / maxCount,
                                  child: Container(
                                    width: 24,
                                    decoration: BoxDecoration(
                                      color: counts[i] == 0
                                          ? const Color(0xFFE3E7ED)
                                          : accent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              child: Text(
                                '${days[i].day}/${days[i].month}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/registrar-sessao'),
              icon: const Icon(Icons.add),
              label: const Text('Registrar atividade'),
            ),
          ],
          const SectionTitle('Histórico'),
          if (list.isEmpty)
            EmptyState(
              title: 'Nenhum registro ainda',
              description: pet == null
                  ? 'Cadastre um pet para acompanhar o histórico.'
                  : 'Registre uma atividade orientada para começar seu histórico.',
            ),
          ...list.map(
            (s) => Card(
              child: ListTile(
                leading: const Icon(Icons.task_alt, color: accent),
                title: Text(s.activity),
                subtitle: Text(
                  '${dateLabel(s.date)} • percepção do tutor: ${s.comfort}/5${s.notes.isEmpty ? '' : '\n${s.notes}'}',
                ),
                trailing: IconButton(
                  tooltip: 'Excluir registro',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (await confirm(
                          context,
                          'Excluir registro?',
                          s.activity,
                        ) &&
                        context.mounted) {
                      await mutate(context, () => store.deleteSession(s.id));
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
