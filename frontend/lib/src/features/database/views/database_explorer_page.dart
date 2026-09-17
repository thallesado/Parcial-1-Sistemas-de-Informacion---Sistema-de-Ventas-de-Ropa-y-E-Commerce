import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../models/schema_definition.dart';
import '../services/schema_catalog_service.dart';

class DatabaseExplorerPage extends StatefulWidget {
  const DatabaseExplorerPage({super.key});

  @override
  State<DatabaseExplorerPage> createState() => _DatabaseExplorerPageState();
}

class _DatabaseExplorerPageState extends State<DatabaseExplorerPage> {
  final tables = const SchemaCatalogService().load();
  String group = 'Todas';
  String query = '';
  SchemaTable? selected;

  List<String> get groups => [
        'Todas',
        ...{for (final table in tables) table.group}
      ];
  List<SchemaTable> get visible => tables.where((table) {
        final byGroup = group == 'Todas' || table.group == group;
        final q = query.toLowerCase();
        return byGroup &&
            (q.isEmpty ||
                table.name.contains(q) ||
                table.purpose.toLowerCase().contains(q));
      }).toList();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    selected ??= tables.first;
    return ColoredBox(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF101010)
          : const Color(0xFFF0F1F3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ARQUITECTURA DE INFORMACIÓN',
                style: TextStyle(letterSpacing: 1.8, fontSize: 11)),
            const SizedBox(height: 8),
            Text('Explorador conceptual de datos',
                style: Theme.of(context)
                    .textTheme
                    .headlineLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
                '${tables.length} tablas · ${groups.length - 1} dominios · toca una tabla para inspeccionarla'),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar tabla o responsabilidad'),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: groups
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                              label: Text(item),
                              selected: group == item,
                              onSelected: (_) => setState(() => group = item)),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            if (wide)
              SizedBox(
                height: 680,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 4, child: _tableGrid()),
                    const SizedBox(width: 18),
                    Expanded(flex: 3, child: _TableInspector(table: selected!)),
                  ],
                ),
              )
            else ...[
              _tableGrid(),
              const SizedBox(height: 18),
              _TableInspector(table: selected!),
            ],
            const SizedBox(height: 24),
            const _Legend(),
          ],
        ),
      ),
    );
  }

  Widget _tableGrid() => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 270,
            childAspectRatio: 1.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: visible.length,
        itemBuilder: (_, index) {
          final table = visible[index];
          final active = table.name == selected?.name;
          return InkWell(
            onTap: () => setState(() => selected = table),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.wine
                    : Theme.of(context).colorScheme.surface,
                border: Border.all(
                    color: active
                        ? AppColors.wine
                        : Theme.of(context).dividerColor),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.table_chart_outlined,
                          size: 18, color: active ? Colors.white : null),
                      const Spacer(),
                      Text('${table.fields.length} campos',
                          style: TextStyle(
                              fontSize: 10,
                              color: active ? Colors.white70 : null)),
                    ]),
                    const Spacer(),
                    Text(table.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: active ? Colors.white : null,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(table.group,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: active
                                ? Colors.white70
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontSize: 11)),
                  ]),
            ),
          );
        },
      );
}

class _TableInspector extends StatelessWidget {
  const _TableInspector({required this.table});
  final SchemaTable table;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 500),
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(table.group.toUpperCase(),
            style: const TextStyle(
                letterSpacing: 1.5,
                color: AppColors.wine,
                fontWeight: FontWeight.w700,
                fontSize: 11)),
        const SizedBox(height: 8),
        SelectableText(table.name,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(table.purpose),
        const SizedBox(height: 24),
        const Row(children: [
          Expanded(
              flex: 4,
              child:
                  Text('CAMPO', style: TextStyle(fontWeight: FontWeight.w700))),
          Expanded(
              flex: 3,
              child:
                  Text('TIPO', style: TextStyle(fontWeight: FontWeight.w700))),
          SizedBox(
              width: 42,
              child:
                  Text('CLAVE', style: TextStyle(fontWeight: FontWeight.w700)))
        ]),
        const Divider(),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: table.fields.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final field = table.fields[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(children: [
                Expanded(
                    flex: 4,
                    child: Tooltip(
                        message: field.note,
                        child: Text('${field.name}${field.nullable ? '?' : ''}',
                            overflow: TextOverflow.ellipsis))),
                Expanded(
                    flex: 3,
                    child: Text(field.type,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12))),
                SizedBox(
                    width: 42,
                    child: field.key.isEmpty
                        ? null
                        : Container(
                            color: field.key == 'PK'
                                ? AppColors.wine
                                : AppColors.ink,
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Text(field.key,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)))),
              ]),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text('RELACIONES', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
            spacing: 6,
            runSpacing: 6,
            children: table.relations.isEmpty
                ? [const Chip(label: Text('Sin relaciones directas'))]
                : table.relations
                    .map((item) => Chip(
                        avatar: const Icon(Icons.link, size: 15),
                        label: Text(item)))
                    .toList()),
      ]),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        color: Theme.of(context).colorScheme.surface,
        child: const Wrap(spacing: 24, runSpacing: 10, children: [
          Text('PK  Clave primaria'),
          Text('FK  Clave foránea'),
          Text('UQ  Valor único'),
          Text('?  Campo opcional'),
          Text('JSONB  Datos flexibles controlados')
        ]),
      );
}
