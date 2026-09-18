import '../../journal/models/emotion_result.dart';
import '../models/psicologo.dart';

/// Mock psychologist directory.
///
/// TODO: reemplazar por una llamada a la API real de psicólogos/agenda
/// (listado, disponibilidad y reserva de citas).
final List<Psicologo> mockPsicologos = [
  Psicologo(
    id: 'p1',
    name: 'Dra. Camila Reyes',
    initials: 'CR',
    specialty: 'Ansiedad y estrés',
    rating: 4.8,
    bio:
        'Psicóloga clínica con 8 años de experiencia en manejo de ansiedad, '
        'estrés laboral y técnicas de regulación emocional.',
    availability: ['Lun 10:00', 'Mié 15:00', 'Vie 09:00'],
    focusEmotions: [EmotionType.estres, EmotionType.ansiedad],
  ),
  Psicologo(
    id: 'p2',
    name: 'Lic. Andrés Torres',
    initials: 'AT',
    specialty: 'Duelo y tristeza',
    rating: 4.6,
    bio:
        'Especialista en procesos de duelo y acompañamiento emocional, '
        'con enfoque humanista.',
    availability: ['Mar 11:00', 'Jue 16:30'],
    focusEmotions: [EmotionType.tristeza],
  ),
  Psicologo(
    id: 'p3',
    name: 'Dra. Valentina Cruz',
    initials: 'VC',
    specialty: 'Bienestar y hábitos',
    rating: 4.9,
    bio:
        'Trabaja con terapia cognitivo-conductual para construir hábitos '
        'saludables y mejorar el bienestar general.',
    availability: ['Lun 14:00', 'Mié 09:30', 'Sáb 10:00'],
    focusEmotions: [EmotionType.calma, EmotionType.alegria],
  ),
  Psicologo(
    id: 'p4',
    name: 'Lic. Mateo Fernández',
    initials: 'MF',
    specialty: 'Relaciones y autoestima',
    rating: 4.7,
    bio:
        'Acompaña procesos de autoestima, relaciones interpersonales y '
        'comunicación asertiva.',
    availability: ['Mar 08:30', 'Vie 17:00'],
    focusEmotions: [EmotionType.ansiedad, EmotionType.tristeza],
  ),
];
