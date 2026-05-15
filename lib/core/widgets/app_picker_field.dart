import 'package:flutter/material.dart';

class PickerOption<T> {
  const PickerOption({required this.value, required this.label, this.subtitle});

  final T value;
  final String label;
  final String? subtitle;
}

class AppPickerField<T> extends StatelessWidget {
  const AppPickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.onSelected,
    this.value,
    this.searchHint = 'Cari data',
  });

  final String label;
  final String hint;
  final List<PickerOption<T>> options;
  final T? value;
  final ValueChanged<T> onSelected;
  final String searchHint;

  @override
  Widget build(BuildContext context) {
    final selected = options.where((item) => item.value == value).toList();
    final selectedLabel = selected.isEmpty ? '' : selected.first.label;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final result = await showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => _PickerSheet<T>(
            label: label,
            options: options,
            initialValue: value,
            searchHint: searchHint,
          ),
        );
        if (result != null) {
          onSelected(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        ),
        child: Text(
          selectedLabel.isEmpty ? hint : selectedLabel,
          style: selectedLabel.isEmpty
              ? Theme.of(context).textTheme.bodyMedium
              : Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.label,
    required this.options,
    required this.initialValue,
    required this.searchHint,
  });

  final String label;
  final List<PickerOption<T>> options;
  final T? initialValue;
  final String searchHint;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options.where((item) {
      final query = _query.toLowerCase();
      return query.isEmpty ||
          item.label.toLowerCase().contains(query) ||
          (item.subtitle?.toLowerCase().contains(query) ?? false);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 4,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('Data tidak ditemukan'))
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final item = filtered[index];
                          final selected = item.value == widget.initialValue;
                          return ListTile(
                            onTap: () => Navigator.pop(context, item.value),
                            contentPadding: EdgeInsets.zero,
                            title: Text(item.label),
                            subtitle: item.subtitle == null
                                ? null
                                : Text(item.subtitle!),
                            trailing: selected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Colors.green,
                                  )
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
