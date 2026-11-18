class Pet {
  final String id;
  final String name;
  final String species;
  final int age;
  final double weight;
  final String condition;
  final String goal;
  final String professional;
  final String plan;
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.weight,
    this.condition = '',
    this.goal = '',
    this.professional = '',
    this.plan = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'age': age,
    'weight': weight,
    'condition': condition,
    'goal': goal,
    'professional': professional,
    'plan': plan,
  };
  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
    id: j['id'],
    name: j['name'],
    species: j['species'],
    age: j['age'],
    weight: (j['weight'] as num).toDouble(),
    condition: j['condition'] ?? '',
    goal: j['goal'] ?? '',
    professional: j['professional'] ?? '',
    plan: j['plan'] ?? '',
  );
}

class Appointment {
  final String id;
  final String petId;
  final String title;
  final DateTime date;
  final String notes;
  final bool done;
  const Appointment({
    required this.id,
    required this.petId,
    required this.title,
    required this.date,
    this.notes = '',
    this.done = false,
  });
  Appointment toggle() => Appointment(
    id: id,
    petId: petId,
    title: title,
    date: date,
    notes: notes,
    done: !done,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'title': title,
    'date': date.toIso8601String(),
    'notes': notes,
    'done': done,
  };
  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
    id: j['id'],
    petId: j['petId'],
    title: j['title'],
    date: DateTime.parse(j['date']),
    notes: j['notes'] ?? '',
    done: j['done'] ?? false,
  );
}

class Session {
  final String id;
  final String petId;
  final String activity;
  final DateTime date;
  final int comfort;
  final String notes;
  const Session({
    required this.id,
    required this.petId,
    required this.activity,
    required this.date,
    required this.comfort,
    this.notes = '',
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'petId': petId,
    'activity': activity,
    'date': date.toIso8601String(),
    'comfort': comfort,
    'notes': notes,
  };
  factory Session.fromJson(Map<String, dynamic> j) => Session(
    id: j['id'],
    petId: j['petId'],
    activity: j['activity'],
    date: DateTime.parse(j['date']),
    comfort: j['comfort'],
    notes: j['notes'] ?? '',
  );
}

class Activity {
  final String id, title, description;
  const Activity(this.id, this.title, this.description);
}

const activities = [
  Activity(
    'caminhada',
    'Caminhada orientada',
    'Organize os registros da caminhada que o profissional incluiu no plano do pet.',
  ),
  Activity(
    'mobilidade',
    'Mobilidade',
    'Registre a atividade de mobilidade ensinada presencialmente pelo profissional.',
  ),
  Activity(
    'equilibrio',
    'Equilíbrio',
    'Acompanhe a atividade de equilíbrio que foi individualmente orientada para o pet.',
  ),
  Activity(
    'outro',
    'Outra atividade do plano',
    'Use o nome e as observações para registrar outra atividade prescrita.',
  ),
];

const tips = <({String title, String category, String text})>[
  (
    title: 'Tenha o plano sempre à mão',
    category: 'Organização',
    text:
        'Anote o nome do profissional, as atividades e as orientações recebidas no perfil do pet. O aplicativo organiza essas informações e não gera prescrições.',
  ),
  (
    title: 'Prepare o registro da sessão',
    category: 'Rotina',
    text:
        'Antes de começar, consulte o plano individual. Depois, registre o que foi realizado e suas observações, sem transformar metas do aplicativo em obrigação.',
  ),
  (
    title: 'Leve suas anotações à consulta',
    category: 'Acompanhamento',
    text:
        'O histórico reúne datas, atividades e observações do tutor. Compartilhe essas informações com quem acompanha o pet; elas não substituem avaliação clínica.',
  ),
  (
    title: 'Organize os próximos encontros',
    category: 'Organização',
    text:
        'Cadastre consultas e sessões na agenda. Os compromissos ficam visíveis no aplicativo. Esta versão não envia notificações em segundo plano.',
  ),
];
