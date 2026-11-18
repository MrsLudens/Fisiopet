import 'package:flutter/material.dart';
import '../data/app_scope.dart';
import '../models/models.dart';
import '../widgets/app_ui.dart';

class PetsPage extends StatelessWidget {
  const PetsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppPage(
      title: 'Meus pets',
      selected: 1,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/cadastrar-pet'),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar pet'),
      ),
      child: store.pets.isEmpty
          ? const EmptyState(
              title: 'Seu primeiro pet',
              description: 'Toque em Adicionar pet para começar.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: store.pets
                  .map(
                    (p) => InfoCard(
                      icon: Icons.pets,
                      title: p.name,
                      subtitle: '${p.species} • ${p.age} anos',
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/detalhes-pet',
                        arguments: p.id,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class PetDetailsPage extends StatelessWidget {
  final String id;
  const PetDetailsPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final pet = store.pets.where((p) => p.id == id).firstOrNull;
    if (pet == null) {
      return const AppPage(
        title: 'Pet',
        selected: 1,
        child: EmptyState(
          title: 'Pet não encontrado',
          description: 'Volte à lista de pets.',
        ),
      );
    }
    return AppPage(
      title: pet.name,
      selected: 1,
      actions: [
        IconButton(
          tooltip: 'Editar pet',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () =>
              Navigator.pushNamed(context, '/editar-pet', arguments: id),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFEDE6FA),
              child: Icon(Icons.pets, size: 45, color: accent),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${pet.species} • ${pet.age} anos • ${pet.weight.toStringAsFixed(1)} kg',
            textAlign: TextAlign.center,
          ),
          const SectionTitle('Informações do acompanhamento'),
          InfoCard(
            icon: Icons.description_outlined,
            title: 'Condição informada pelo tutor',
            subtitle: pet.condition.isEmpty ? 'Não informada' : pet.condition,
          ),
          InfoCard(
            icon: Icons.flag_outlined,
            title: 'Objetivo informado',
            subtitle: pet.goal.isEmpty ? 'Não informado' : pet.goal,
          ),
          InfoCard(
            icon: Icons.medical_services_outlined,
            title: 'Profissional responsável',
            subtitle: pet.professional.isEmpty
                ? 'Não informado'
                : pet.professional,
          ),
          InfoCard(
            icon: Icons.assignment_outlined,
            title: 'Plano e orientações recebidas',
            subtitle: pet.plan.isEmpty
                ? 'Adicione as orientações recebidas ao editar o pet.'
                : pet.plan,
          ),
          FilledButton.tonal(
            onPressed: () async {
              try {
                await store.selectPet(id);
                if (context.mounted) Navigator.pushNamed(context, '/progresso');
              } catch (e) {
                if (context.mounted) notice(context, errorMessage(e));
              }
            },
            child: const Text('Ver progresso deste pet'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              if (!await confirm(
                context,
                'Remover ${pet.name}?',
                'Os compromissos e registros deste pet também serão removidos.',
              )) {
                return;
              }
              if (!context.mounted) return;
              try {
                await store.deletePet(id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) notice(context, errorMessage(e));
              }
            },
            child: const Text('Remover pet'),
          ),
        ],
      ),
    );
  }
}

class PetFormPage extends StatefulWidget {
  final String? id;
  const PetFormPage({super.key, this.id});
  @override
  State<PetFormPage> createState() => _PetFormPageState();
}

class _PetFormPageState extends State<PetFormPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _age = TextEditingController(),
      _weight = TextEditingController();
  final _condition = TextEditingController(),
      _goal = TextEditingController(),
      _professional = TextEditingController(),
      _plan = TextEditingController();
  String _species = 'Cão';
  bool _loaded = false, _busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final p = AppScope.of(
      context,
    ).pets.where((p) => p.id == widget.id).firstOrNull;
    if (p != null) {
      _name.text = p.name;
      _age.text = '${p.age}';
      _weight.text = '${p.weight}';
      _species = p.species;
      _condition.text = p.condition;
      _goal.text = p.goal;
      _professional.text = p.professional;
      _plan.text = p.plan;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _age,
      _weight,
      _condition,
      _goal,
      _professional,
      _plan,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    final store = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await store.savePet(
        Pet(
          id: widget.id ?? store.newId(),
          name: _name.text.trim(),
          species: _species,
          age: int.parse(_age.text),
          weight: double.parse(_weight.text.replaceAll(',', '.')),
          condition: _condition.text.trim(),
          goal: _goal.text.trim(),
          professional: _professional.text.trim(),
          plan: _plan.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) notice(context, errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: widget.id == null ? 'Cadastrar pet' : 'Editar pet',
    selected: 1,
    child: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nome do pet'),
            validator: requiredText,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _species,
            decoration: const InputDecoration(labelText: 'Espécie'),
            items: [
              'Cão',
              'Gato',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _species = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Idade em anos completos',
            ),
            validator: (v) {
              final n = int.tryParse(v ?? '');
              return n == null || n < 0 || n > 40
                  ? 'Informe uma idade entre 0 e 40.'
                  : null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Peso (kg)'),
            validator: (v) {
              final n = double.tryParse((v ?? '').replaceAll(',', '.'));
              return n == null || !n.isFinite || n <= 0 || n > 150
                  ? 'Informe um peso válido.'
                  : null;
            },
          ),
          const SectionTitle('Questionário de acompanhamento'),
          const Text(
            'Copie as informações recebidas do profissional. Estes dados não geram um diagnóstico nem uma prescrição.',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _condition,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Condição ou diagnóstico informado (opcional)',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _goal,
            decoration: const InputDecoration(
              labelText: 'Objetivo do acompanhamento (opcional)',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _professional,
            decoration: const InputDecoration(
              labelText: 'Profissional responsável (opcional)',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _plan,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Plano e orientações recebidas (opcional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Salvando…' : 'Salvar pet'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}
