import '../models/emotion_result.dart';
import '../models/journal.dart';

/// Mock history used to seed the app before any real journal is recorded.
///
/// Covers most (not all) of the last 10 days so the date carousel in
/// `RecordJournalScreen` has gaps to demonstrate the "no journal that day"
/// state too. `intensity`/`keywords`/`durationSeconds` simulate the extra
/// fields a real AI analysis would return.
///
/// TODO: reemplazar por una consulta a un `JournalRepository` real
/// (base de datos local o API) que devuelva el historial del usuario.
final List<Journal> mockJournals = [
  Journal(
    id: 'j0',
    date: DateTime.now(),
    entryType: JournalEntryType.voz,
    transcript:
        'Hoy en la mañana tuve un pico de ansiedad antes de una llamada importante, '
        'pero logré calmarme respirando un par de minutos antes de entrar.',
    shortSummary: 'Ansiedad antes de una llamada, logré calmarme.',
    durationSeconds: 96,
    emotionResult: const EmotionResult(
      emotion: EmotionType.ansiedad,
      feedbackText: 'Hoy tu registro muestra un pico de ansiedad que lograste manejar.',
      intensity: 0.58,
      keywords: ['llamada de trabajo', 'respiración', 'nervios'],
      suggestions: [
        'Repite la técnica de respiración antes de otras situaciones similares.',
        'Anota qué la disparó para identificar patrones.',
      ],
    ),
  ),
  Journal(
    id: 'j1',
    date: DateTime.now().subtract(const Duration(days: 1)),
    entryType: JournalEntryType.voz,
    transcript:
        'Hoy tuve demasiadas reuniones seguidas y sentí que no llegaba a nada, '
        'terminé el día agotado y con la cabeza saturada.',
    shortSummary: 'Día saturado de reuniones, sensación de agobio.',
    durationSeconds: 142,
    emotionResult: const EmotionResult(
      emotion: EmotionType.estres,
      feedbackText:
          'Notamos que tuviste un día estresante. Aquí tienes algunas recomendaciones:',
      intensity: 0.82,
      keywords: ['reuniones', 'sobrecarga', 'cansancio'],
      suggestions: [
        'Haz una pausa de 5 minutos de respiración profunda entre tareas.',
        'Anota las 3 prioridades reales del día siguiente antes de dormir.',
        'Evita revisar el correo apenas te despiertes.',
      ],
    ),
  ),
  Journal(
    id: 'j2',
    date: DateTime.now().subtract(const Duration(days: 2)),
    entryType: JournalEntryType.texto,
    transcript:
        'Estoy un poco preocupado por una presentación que tengo la próxima semana, '
        'no dejo de pensar en todo lo que puede salir mal.',
    shortSummary: 'Preocupación anticipada por una presentación.',
    emotionResult: const EmotionResult(
      emotion: EmotionType.ansiedad,
      feedbackText: 'Detectamos algo de ansiedad anticipatoria en tu registro.',
      intensity: 0.47,
      keywords: ['presentación', 'anticipación', 'trabajo'],
      suggestions: [
        'Practica la presentación en voz alta al menos una vez.',
        'Escribe el peor escenario y cómo lo resolverías, suele reducir la ansiedad.',
      ],
    ),
  ),
  Journal(
    id: 'j3',
    date: DateTime.now().subtract(const Duration(days: 3)),
    entryType: JournalEntryType.voz,
    transcript:
        'Extrañé mucho a mi familia hoy, ha pasado tiempo desde que los veo en persona.',
    shortSummary: 'Nostalgia por la distancia con la familia.',
    durationSeconds: 78,
    emotionResult: const EmotionResult(
      emotion: EmotionType.tristeza,
      feedbackText: 'Parece que hoy la distancia con tu familia pesó un poco más.',
      intensity: 0.65,
      keywords: ['familia', 'distancia', 'nostalgia'],
      suggestions: [
        'Agenda una videollamada corta esta semana.',
        'Permítete sentir la nostalgia sin juzgarla, es una emoción válida.',
      ],
    ),
  ),
  Journal(
    id: 'j4',
    date: DateTime.now().subtract(const Duration(days: 4)),
    entryType: JournalEntryType.texto,
    transcript: 'Salí a caminar por la mañana y me sentí en paz, sin apuro por nada.',
    shortSummary: 'Caminata matutina, sensación de calma.',
    emotionResult: const EmotionResult(
      emotion: EmotionType.calma,
      feedbackText: '¡Qué bien! Hoy tu registro refleja un estado de calma.',
      intensity: 0.71,
      keywords: ['caminata', 'mañana', 'aire libre'],
      suggestions: [
        'Identifica qué hizo posible este momento para repetirlo más seguido.',
      ],
    ),
  ),
  // Día -5 queda sin journal a propósito, para probar el estado
  // "No tienes un journal registrado ese día" en el carrusel de fechas.
  Journal(
    id: 'j5',
    date: DateTime.now().subtract(const Duration(days: 6)),
    entryType: JournalEntryType.voz,
    transcript: 'Recibí buenas noticias sobre un proyecto y quería celebrarlo.',
    shortSummary: 'Buenas noticias, ganas de celebrar.',
    durationSeconds: 54,
    emotionResult: const EmotionResult(
      emotion: EmotionType.alegria,
      feedbackText: 'Se nota alegría en tu registro de hoy, ¡disfrútalo!',
      intensity: 0.88,
      keywords: ['proyecto', 'buenas noticias', 'celebración'],
      suggestions: [
        'Comparte esta buena noticia con alguien cercano.',
      ],
    ),
  ),
  Journal(
    id: 'j6',
    date: DateTime.now().subtract(const Duration(days: 7)),
    entryType: JournalEntryType.texto,
    transcript:
        'Discutí con un compañero de equipo por un malentendido y me quedé pensando en eso todo el día.',
    shortSummary: 'Malentendido con un compañero, día pesado.',
    emotionResult: const EmotionResult(
      emotion: EmotionType.estres,
      feedbackText: 'Notamos tensión relacionada a un conflicto interpersonal.',
      intensity: 0.6,
      keywords: ['conflicto', 'equipo', 'comunicación'],
      suggestions: [
        'Considera aclarar el malentendido directamente cuando estés más calmado.',
        'Escribe qué necesitabas de esa conversación para la próxima vez.',
      ],
    ),
  ),
  // Día -8 también queda sin journal a propósito.
  Journal(
    id: 'j7',
    date: DateTime.now().subtract(const Duration(days: 9)),
    entryType: JournalEntryType.voz,
    transcript:
        'Dormí mal casi toda la semana y hoy sentí que me costó concentrarme en todo.',
    shortSummary: 'Mala calidad de sueño, dificultad para concentrarme.',
    durationSeconds: 63,
    emotionResult: const EmotionResult(
      emotion: EmotionType.tristeza,
      feedbackText: 'Tu energía parece haber estado baja hoy, posiblemente por el sueño.',
      intensity: 0.53,
      keywords: ['sueño', 'concentración', 'energía baja'],
      suggestions: [
        'Prueba mantener un horario de sueño más regular esta semana.',
        'Evita pantallas al menos 30 minutos antes de dormir.',
      ],
    ),
  ),
];
