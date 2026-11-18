import 'package:flutter/material.dart';
import '../data/app_scope.dart';
import '../models/models.dart';
import '../widgets/app_ui.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});
  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  bool _all = false;
  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final list =
        store.appointments
            .where((a) => _all || a.petId == store.selectedPet?.id)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return AppPage(
      title: 'Agenda',
      selected: 2,
      floatingActionButton: store.pets.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/novo-compromisso'),
              icon: const Icon(Icons.add),
              label: const Text('Agendar'),
            ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          if (store.pets.isNotEmpty) const PetPicker(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mostrar todos os pets'),
            value: _all,
            onChanged: (v) => setState(() => _all = v),
          ),
          const Text(
            'A agenda organiza seus compromissos. Notificações em segundo plano ainda não estão disponíveis.',
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            EmptyState(
              title: 'Agenda livre',
              description: store.pets.isEmpty
                  ? 'Cadastre um pet antes de agendar.'
                  : 'Toque em Agendar para adicionar uma consulta ou atividade.',
            ),
          ...list.map(
            (a) => Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      a.title,
                      style: TextStyle(
                        decoration: a.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      '${store.petName(a.petId)}\n${dateLabel(a.date)} às ${timeLabel(a.date)}${a.notes.isEmpty ? '' : '\n${a.notes}'}',
                    ),
                    isThreeLine: true,
                    leading: Checkbox(
                      value: a.done,
                      onChanged: store.writing
                          ? null
                          : (_) => mutate(
                              context,
                              () => store.saveAppointment(a.toggle()),
                            ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/editar-compromisso',
                          arguments: a.id,
                        ),
                        child: const Text('Editar'),
                      ),
                      IconButton(
                        tooltip: 'Excluir compromisso',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (await confirm(
                                context,
                                'Excluir compromisso?',
                                a.title,
                              ) &&
                              context.mounted) {
                            await mutate(
                              context,
                              () => store.deleteAppointment(a.id),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentFormPage extends StatefulWidget {
  final String? id;
  const AppointmentFormPage({super.key, this.id});
  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(), _notes = TextEditingController();
  String? _petId;
  DateTime _date = DateTime.now().add(const Duration(hours: 1));
  bool _loaded = false, _busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final store = AppScope.of(context);
    final item = store.appointments.where((a) => a.id == widget.id).firstOrNull;
    _petId = item?.petId ?? store.selectedPet?.id;
    if (item != null) {
      _title.text = item.title;
      _notes.text = item.notes;
      _date = item.date;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final day = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (time == null || !mounted) return;
    setState(
      () => _date = DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    if (_date.isBefore(DateTime.now())) {
      notice(context, 'Escolha uma data e horário futuros.');
      return;
    }
    final store = AppScope.of(context);
    final old = store.appointments.where((a) => a.id == widget.id).firstOrNull;
    setState(() => _busy = true);
    try {
      await store.saveAppointment(
        Appointment(
          id: widget.id ?? store.newId(),
          petId: _petId!,
          title: _title.text.trim(),
          date: _date,
          notes: _notes.text.trim(),
          done: old?.done ?? false,
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
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    return AppPage(
      title: widget.id == null ? 'Novo compromisso' : 'Editar compromisso',
      selected: 2,
      child: store.pets.isEmpty
          ? const EmptyState(
              title: 'Cadastre um pet',
              description: 'A agenda precisa de um pet vinculado.',
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
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: requiredText,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text('${dateLabel(_date)} às ${timeLabel(_date)}'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observações (opcional)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(_busy ? 'Salvando…' : 'Salvar compromisso'),
                  ),
                ],
              ),
            ),
    );
  }
}
