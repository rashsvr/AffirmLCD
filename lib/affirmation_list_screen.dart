import 'package:flutter/material.dart';

import 'affirmation.dart';
import 'affirmation_service.dart';
import 'affirmation_store.dart';
import 'widget_design.dart';
import 'widget_preview.dart';
import 'widget_update_service.dart';

class AffirmationListScreen extends StatefulWidget {
  const AffirmationListScreen({
    super.key,
    required this.store,
    required this.widgetService,
  });

  final AffirmationStore store;
  final WidgetUpdateService widgetService;

  @override
  State<AffirmationListScreen> createState() => _AffirmationListScreenState();
}

class _AffirmationListScreenState extends State<AffirmationListScreen>
    with WidgetsBindingObserver {
  List<Affirmation> _affirmations = const [];
  String _currentText = AffirmationService.loadingText;
  String? _currentId;
  bool _loading = true;
  bool _storageReady = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load(refreshWidget: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _storageReady) {
      _selectNext();
    }
  }

  Future<void> _load({bool refreshWidget = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (!widget.store.isReady) {
        await widget.store.initialize();
      }
      final affirmations = await widget.store.loadAll();
      final current = await widget.store.currentAffirmation();
      final currentText = current?.text ?? AffirmationService.emptyListText;

      if (!mounted) return;
      setState(() {
        _affirmations = affirmations;
        _currentId = current?.id;
        _currentText = currentText;
        _loading = false;
        _storageReady = true;
      });

      if (refreshWidget) {
        await _selectNext();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _storageErrorMessage(error);
        _loading = false;
        _storageReady = false;
        _currentText = AffirmationService.loadingText;
      });
    }
  }

  Future<void> _selectNext() async {
    if (!_storageReady) return;
    try {
      final next = await widget.widgetService.generateSaveAndUpdate(
        store: widget.store,
        currentId: _currentId,
      );
      await _loadCurrentOnly(next);
    } catch (error) {
      _showStorageError(error);
    }
  }

  Future<void> _loadCurrentOnly(Affirmation? current) async {
    try {
      final affirmations = await widget.store.loadAll();
      if (!mounted) return;
      setState(() {
        _affirmations = affirmations;
        _currentId = current?.id;
        _currentText = current?.text ?? AffirmationService.emptyListText;
        _loading = false;
        _storageReady = true;
        _error = null;
      });
    } catch (error) {
      _showStorageError(error);
    }
  }

  Future<void> _saveNew(String text) async {
    if (!_storageReady) return;
    try {
      final added = await widget.store.add(text);
      await widget.widgetService.saveAffirmationList(
        await widget.store.loadAll(),
      );
      await widget.widgetService.saveAffirmationAndUpdate(added);
      await _loadCurrentOnly(added);
    } catch (error) {
      _showStorageError(error);
    }
  }

  Future<void> _saveEdit(Affirmation affirmation, String text) async {
    if (!_storageReady) return;
    try {
      final updated = await widget.store.update(affirmation.id, text);
      if (updated == null) return;
      final current = await widget.store.currentAffirmation();
      await widget.widgetService.saveAffirmationList(
        await widget.store.loadAll(),
      );
      await widget.widgetService.saveAffirmationAndUpdate(current ?? updated);
      await _loadCurrentOnly(current ?? updated);
    } catch (error) {
      _showStorageError(error);
    }
  }

  Future<void> _delete(Affirmation affirmation) async {
    if (!_storageReady) return;
    try {
      final deletingCurrent = _currentId == affirmation.id;
      await widget.store.delete(affirmation.id);
      final remaining = await widget.store.loadAll();
      await widget.widgetService.saveAffirmationList(remaining);

      if (deletingCurrent) {
        final next = await widget.widgetService.generateSaveAndUpdate(
          store: widget.store,
          currentId: null,
        );
        await _loadCurrentOnly(next);
        return;
      }

      final current = await widget.store.currentAffirmation();
      if (current == null) {
        await widget.widgetService.saveAndUpdate(
          AffirmationService.emptyListText,
        );
      } else {
        await widget.widgetService.saveAffirmationAndUpdate(current);
      }
      await _loadCurrentOnly(current);
    } catch (error) {
      _showStorageError(error);
    }
  }

  Future<void> _openEditor({Affirmation? affirmation}) async {
    if (!_storageReady) {
      _showStorageError();
      return;
    }
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _AffirmationEditorDialog(
        initialText: affirmation?.text ?? '',
        title: affirmation == null ? 'Add affirmation' : 'Edit affirmation',
      ),
    );

    final cleaned = result?.trim();
    if (cleaned == null || cleaned.isEmpty) return;
    if (affirmation == null) {
      await _saveNew(cleaned);
    } else {
      await _saveEdit(affirmation, cleaned);
    }
  }

  void _showStorageError([Object? error]) {
    if (!mounted) return;
    final message = _storageErrorMessage(error);
    setState(() {
      _error = message;
      _storageReady = false;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _storageErrorMessage([Object? error]) {
    if (error is AffirmationStoreException) return error.message;
    return 'Local storage is not ready. Please reopen the app.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WidgetDesign.appBackground,
      appBar: AppBar(
        title: const Text('Affirmations'),
        actions: [
          IconButton(
            tooltip: 'Refresh widget',
            onPressed: _storageReady ? _selectNext : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _storageReady ? () => _openEditor() : null,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _selectNext,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  Center(child: WidgetPreview(text: _currentText)),
                  const SizedBox(height: 18),
                  if (!_storageReady && _error == null)
                    const _StatusMessage(
                      text:
                          'Local storage is not ready. Please reopen the app.',
                    ),
                  if (_error != null)
                    _StatusMessage(text: _error!)
                  else if (_affirmations.isEmpty)
                    const _StatusMessage(text: AffirmationService.emptyListText)
                  else
                    ..._affirmations.map(
                      (affirmation) => _AffirmationTile(
                        affirmation: affirmation,
                        selected: affirmation.id == _currentId,
                        enabled: _storageReady,
                        onTap: () async {
                          if (!_storageReady) return;
                          await widget.store.setCurrentId(affirmation.id);
                          await widget.widgetService.saveAffirmationAndUpdate(
                            affirmation,
                          );
                          await _loadCurrentOnly(affirmation);
                        },
                        onEdit: () => _openEditor(affirmation: affirmation),
                        onDelete: () => _delete(affirmation),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _AffirmationEditorDialog extends StatefulWidget {
  const _AffirmationEditorDialog({
    required this.initialText,
    required this.title,
  });

  final String initialText;
  final String title;

  @override
  State<_AffirmationEditorDialog> createState() =>
      _AffirmationEditorDialogState();
}

class _AffirmationEditorDialogState extends State<_AffirmationEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 5,
        maxLength: 180,
        decoration: const InputDecoration(
          hintText: 'I move with calm confidence ✨',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AffirmationTile extends StatelessWidget {
  const _AffirmationTile({
    required this.affirmation,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Affirmation affirmation;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: selected ? WidgetDesign.lcdBackground : WidgetDesign.appSurface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        enabled: enabled,
        onTap: enabled ? onTap : null,
        iconColor: selected ? WidgetDesign.textPrimary : WidgetDesign.appText,
        textColor: selected ? WidgetDesign.textPrimary : WidgetDesign.appText,
        title: Text(
          affirmation.text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: WidgetDesign.fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.chat_bubble_outline,
        ),
        trailing: PopupMenuButton<_AffirmationAction>(
          enabled: enabled,
          onSelected: (action) {
            switch (action) {
              case _AffirmationAction.edit:
                onEdit();
              case _AffirmationAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: _AffirmationAction.edit, child: Text('Edit')),
            PopupMenuItem(
              value: _AffirmationAction.delete,
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AffirmationAction { edit, delete }

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: WidgetDesign.appTextMuted,
          fontFamily: WidgetDesign.fontFamily,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
