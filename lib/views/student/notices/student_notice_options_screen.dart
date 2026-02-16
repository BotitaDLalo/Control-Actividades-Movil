import 'package:aprende_mas/config/data/key_value_storage_service_impl.dart';
import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/activities_body/notice/notice_body/notice_body.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aprende_mas/providers/notices/future_notices_provider.dart';

class StudentNoticeOptionsScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int subjectId;
  const StudentNoticeOptionsScreen(
      {super.key, this.groupId = 0, this.subjectId = 0});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StudentNoticeOptionsScreenState();
}

class _StudentNoticeOptionsScreenState
    extends ConsumerState<StudentNoticeOptionsScreen> {
  NoticeModel notice = NoticeModel();
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    if (widget.groupId != 0) {
      notice = notice.copyWith(groupId: widget.groupId);
    } else if (widget.subjectId != 0) {
      notice = notice.copyWith(subjectId: widget.subjectId);
    }
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper para parsear fechas y validar vigencia
  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // Separar fecha de hora si existe (ej: "20-02-2026 00:00:00")
        final datePart = dateStr.split(' ')[0];

        // Soporte para dd-MM-yyyy
        final parts = datePart.split('-');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
        // Soporte para dd/MM/yyyy
        final partsSlash = datePart.split('/');
        if (partsSlash.length == 3) {
          return DateTime(int.parse(partsSlash[2]), int.parse(partsSlash[1]), int.parse(partsSlash[0]));
        }
      } catch (e) {
        debugPrint("Error parsing date: $dateStr");
      }
    }
    return null;
  }

  bool _isNoticeActive(NoticeModel notice) {
    if (notice.startDate == null || notice.endDate == null) return true;
    final start = _parseDate(notice.startDate!);
    final end = _parseDate(notice.endDate!);
    if (start == null || end == null) return true;
    final now = DateTime.now();
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  @override
  Widget build(BuildContext context) {
    final subjectColor = getSubjectColor(widget.subjectId);
    final futureNotices = ref.watch(futureNoticesProvider(notice));

    return Scaffold(
      body: futureNotices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        data: (allNotices) {
          // Filtrado local
          final filteredNotices = allNotices.where((element) {
            // 1. Validar vigencia
            if (!_isNoticeActive(element)) return false;

            final titleLower = element.title.toLowerCase();
            final descLower = element.description.toLowerCase();
            final searchLower = _searchTerm.toLowerCase();

            return titleLower.contains(searchLower) ||
                   descLower.contains(searchLower);
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                // Campo de búsqueda (si hay avisos)
                if (allNotices.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: '  Buscar avisos',
                        prefixIconConstraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
                        prefixIcon: Padding(padding: EdgeInsets.only(left: 8, right: 8), child: SvgPicture.asset('assets/icons/buscar.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn))),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: subjectColor, width: 2.0),
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                      ),
                    ),
                  ),

                // Contenido principal con Expanded
                Expanded(
                  child: allNotices.isEmpty
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/campanaZ.svg',
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(subjectColor, BlendMode.srcIn),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Sin Avisos, \nespera a que tu profesor te envíe un Aviso",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : filteredNotices.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron avisos con esa búsqueda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: filteredNotices.length,
                              itemBuilder: (context, i) {
                                final e = filteredNotices[i];
                                return Column(
                                  children: [
                                    NoticeBody(
                                        optionsIsVisible: false,
                                        notice: e),
                                    SizedBox(height: 12)
                                  ],
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
