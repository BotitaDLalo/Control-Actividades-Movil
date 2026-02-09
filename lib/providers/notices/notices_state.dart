import 'package:aprende_mas/models/models.dart';

class NoticesState {
  final bool isLoading; // 1. Agregar variable
  final List<NoticeModel> lsNotices;
  final String errorMessage;

  NoticesState({
    this.isLoading = false, // 2. Inicializar en constructor
    this.lsNotices = const [],
    this.errorMessage = '',
  });

  NoticesState copyWith({
    bool? isLoading, // 3. Agregar parámetro opcional
    List<NoticeModel>? lsNotices,
    String? errorMessage,
  }) {
    return NoticesState(
      isLoading: isLoading ?? this.isLoading, // 4. Asignar valor
      lsNotices: lsNotices ?? this.lsNotices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

