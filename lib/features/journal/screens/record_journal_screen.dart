import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/journal.dart';
import '../providers/journal_provider.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/top_notice.dart';
import '../widgets/date_carousel.dart';
import '../widgets/journal_detail_sheet.dart';
import '../widgets/mic_button.dart';

class RecordJournalScreen extends StatefulWidget {
  const RecordJournalScreen({super.key, required this.onJournalReady});

  /// Called once a recording/text journal has finished processing, so the
  /// root shell can navigate to the summary tab.
  final VoidCallback onJournalReady;

  @override
  State<RecordJournalScreen> createState() => _RecordJournalScreenState();
}

class _RecordJournalScreenState extends State<RecordJournalScreen> {
  DateTime _selectedDate = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDate(DateTime date) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }

  void _onDateSelected(BuildContext context, DateTime date) {
    setState(() => _selectedDate = date);

    final journals = context.read<JournalProvider>().journals;
    Journal? journalOfDay;
    for (final journal in journals) {
      if (_isSameDay(journal.date, date)) {
        journalOfDay = journal;
        break;
      }
    }

    if (journalOfDay != null) {
      showJournalDetailSheet(context, journalOfDay);
      return;
    }

    showTopNotice(context, 'No tienes un journal registrado ese día');
  }

  Future<void> _openTextJournalSheet(BuildContext context) async {
    final controller = TextEditingController();
    final provider = context.read<JournalProvider>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escribe tu journal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '¿Qué pasó hoy? ¿Cómo te sientes?',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(sheetContext).pop();
                  await provider.submitTextJournal(text);
                  widget.onJournalReady();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Guardar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final journalProvider = context.watch<JournalProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            DateCarousel(
              selectedDate: _selectedDate,
              onDateSelected: (date) => _onDateSelected(context, date),
              journals: journalProvider.journals,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _isSameDay(_selectedDate, DateTime.now())
                    ? 'Hoy, ${_formatDate(_selectedDate)}'
                    : _formatDate(_selectedDate),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '¿Cómo te sientes hoy?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  if (journalProvider.status != RecordingStatus.idle)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 170),
                          child: SingleChildScrollView(
                            reverse: true,
                            child: Text(
                              journalProvider.liveTranscript.isEmpty
                                  ? 'Escuchando...'
                                  : journalProvider.liveTranscript,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    alignment: journalProvider.status == RecordingStatus.idle
                        ? Alignment.center
                        : const Alignment(0, 0.7),
                    child: MicButton(
                      status: journalProvider.status,
                      onStart: () => journalProvider.startRecording(),
                      onStop: () async {
                        await journalProvider.stopRecordingAndAnalyze();
                        widget.onJournalReady();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Text(
              switch (journalProvider.status) {
                RecordingStatus.idle => 'Toca el micrófono para empezar a hablar',
                RecordingStatus.recording => 'Escuchando... toca para detener',
                RecordingStatus.processing => 'Analizando tu journal...',
              },
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: journalProvider.status == RecordingStatus.idle
                  ? () => _openTextJournalSheet(context)
                  : null,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Escribir en texto'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
