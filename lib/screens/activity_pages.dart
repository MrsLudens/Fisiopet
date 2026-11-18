import 'package:flutter/material.dart';
import '../data/app_scope.dart';
import '../models/models.dart';
import '../widgets/app_ui.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({super.key});
  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  String _query = '';
  bool _favoritesOnly = false;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final list = activities
        .where(
          (a) =>
              a.title.toLowerCase().contains(_query.toLowerCase()) &&
              (!_favoritesOnly || store.favorites.contains(a.id)),
        )
        .toList();
    return AppPage(
      title: 'Atividades do plano',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PetPicker(),
          const SizedBox(height: 16),
          const Text(
            'Escolha apenas atividades orientadas para o seu pet. O catálogo organiza seus registros; consulte o plano individual para saber como realizar cada atividade.',
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar atividade',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          SwitchListTile(
            title: const Text('Somente favoritas'),
            value: _favoritesOnly,
            onChanged: (v) => setState(() => _favoritesOnly = v),
          ),
          if (list.isEmpty)
            const EmptyState(
              title: 'Nenhuma atividade',
              description:
                  'Tente outra busca ou desative o filtro de favoritas.',
            ),
          ...list.map(
            (a) => InfoCard(
              icon: Icons.fitness_center,
              title: a.title,
              subtitle: a.description,
              onTap: () => Navigator.pushNamed(
                context,
                '/detalhes-exercicio',
                arguments: a.id,
              ),
              trailing: IconButton(
                tooltip: store.favorites.contains(a.id)
                    ? 'Remover dos favoritos'
                    : 'Favoritar',
                icon: Icon(
                  store.favorites.contains(a.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: accent,
                ),
                onPressed: store.writing
                    ? null
                    : () => mutate(context, () => store.toggleFavorite(a.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityDetailsPage extends StatelessWidget {
  final String id;
  const ActivityDetailsPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final activity = activities.where((a) => a.id == id).firstOrNull;
    if (activity == null) {
      return const AppPage(
        title: 'Atividade',
        child: EmptyState(
          title: 'Atividade não encontrada',
          description: 'Volte ao catálogo.',
        ),
      );
    }
    return AppPage(
      title: activity.title,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const PetPicker(),
          const SizedBox(height: 24),
          const Icon(Icons.fitness_center, color: accent, size: 64),
          const SizedBox(height: 24),
          Text(activity.description),
          const SectionTitle('Orientações do profissional'),
          Text(
            store.selectedPet?.plan.isNotEmpty == true
                ? store.selectedPet!.plan
                : 'Nenhum plano registrado. Adicione as orientações recebidas no perfil do pet.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Este aplicativo não define repetições, duração ou intensidade. Registre somente o que foi prescrito e realizado.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add_task),
            label: const Text('Registrar atividade realizada'),
            onPressed: store.selectedPet == null
                ? null
                : () => Navigator.pushNamed(
                    context,
                    '/registrar-sessao',
                    arguments: activity.id,
                  ),
          ),
          if (store.selectedPet == null)
            const Text('Cadastre um pet para registrar uma atividade.'),
        ],
      ),
    );
  }
}

class SessionFormPage extends StatefulWidget {
  final String? activityId;
  const SessionFormPage({super.key, this.activityId});
  @override
  State<SessionFormPage> createState() => _SessionFormPageState();
}

class _SessionFormPageState extends State<SessionFormPage> {
  final _form = GlobalKey<FormState>();
  final _activity = TextEditingController(), _notes = TextEditingController();
  String? _petId;
  DateTime _date = DateTime.now();
  int _comfort = 3;
  bool _confirmed = false, _busy = false, _loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _petId = AppScope.of(context).selectedPet?.id;
    _activity.text =
        activities.where((a) => a.id == widget.activityId).firstOrNull?.title ??
        '';
  }

  @override
  void dispose() {
    _activity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    if (!_confirmed) {
      notice(context, 'Confirme que a atividade faz parte do plano orientado.');
      return;
    }
    final store = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await store.addSession(
        Session(
          id: store.newId(),
          petId: _petId!,
          activity: _activity.text.trim(),
          date: _date,
          comfort: _comfort,
          notes: _notes.text.trim(),
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        notice(context, 'Atividade registrada no progresso.');
      }
    } catch (e) {
      if (mounted) notice(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppPage(
      title: 'Registrar atividade',
      child: store.pets.isEmpty
          ? const EmptyState(
              title: 'Cadastre um pet',
              description: 'O registro deve estar vinculado a um pet.',
            )
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _petId,
                    decoration: const InputDecoration(labelText: 'Pet'),
                    items: store.pets
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    validator: (v) => v == null ? 'Escolha um pet.' : null,
                    onChanged: (v) => setState(() => _petId = v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _activity,
                    decoration: const InputDecoration(
                      labelText: 'Atividade realizada',
                    ),
                    validator: requiredText,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dateLabel(_date)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && mounted) {
                        setState(() => _date = picked);
                      }
                    },
                  ),
                  const SectionTitle('Como o pet pareceu?'),
                  const Text(
                    'Percepção do tutor, sem valor de avaliação clínica.',
                  ),
                  Slider(
                    value: _comfort.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: '$_comfort de 5',
                    onChanged: (v) => setState(() => _comfort = v.round()),
                  ),
                  Text(
                    '$_comfort/5 • 1: pouco à vontade; 5: muito à vontade',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notes,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                      alignLabelWithHint: true,
                    ),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _confirmed,
                    title: const Text(
                      'Esta atividade foi orientada pelo profissional que acompanha o pet.',
                    ),
                    onChanged: (v) => setState(() => _confirmed = v ?? false),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(_busy ? 'Salvando…' : 'Salvar registro'),
                  ),
                ],
              ),
            ),
    );
  }
}
