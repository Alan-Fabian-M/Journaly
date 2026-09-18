import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/journal/data/api_journal_repository.dart';
import 'features/journal/providers/journal_provider.dart';
import 'features/journal/screens/record_journal_screen.dart';
import 'features/journal/screens/summary_screen.dart';
import 'features/psychologists/data/api_psychologist_repository.dart';
import 'features/psychologists/providers/psychologist_provider.dart';
import 'features/psychologists/screens/psychologists_screen.dart';
import 'shared/theme/app_theme.dart';
import 'shared/widgets/bottom_nav_bar.dart';

void main() {
  runApp(const JournalyApp());
}

class JournalyApp extends StatelessWidget {
  const JournalyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => JournalProvider(repository: ApiJournalRepository())),
        ChangeNotifierProvider(
          create: (_) => PsychologistProvider(repository: ApiPsychologistRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Journaly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const RootShell(),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _navIndex = 0;

  void _goTo(int index) => setState(() => _navIndex = index);

  @override
  Widget build(BuildContext context) {
    final screens = [
      RecordJournalScreen(onJournalReady: () => _goTo(1)),
      const SummaryScreen(),
      const PsychologistsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _navIndex, children: screens),
      bottomNavigationBar: JournalyBottomNavBar(
        currentIndex: _navIndex,
        onTap: _goTo,
      ),
    );
  }
}
