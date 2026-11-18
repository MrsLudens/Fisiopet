import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/app_ui.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});
  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final filtered = tips
        .where(
          (t) => '${t.title} ${t.category} ${t.text}'.toLowerCase().contains(
            _query.toLowerCase(),
          ),
        )
        .toList();
    return AppPage(
      title: 'Dicas e organização',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar dica',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyState(
              title: 'Nenhuma dica encontrada',
              description: 'Tente outra palavra.',
            ),
          ...filtered.map(
            (t) => Card(
              child: ExpansionTile(
                leading: const Icon(Icons.menu_book, color: accent),
                title: Text(t.title),
                subtitle: Text(t.category),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(t.text),
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
