import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/providers/notices/future_notices_provider.dart';
import 'package:aprende_mas/providers/notices/notices_form_provider.dart';
import 'package:aprende_mas/views/widgets/buttons/floating_action_button_custom.dart';
import 'package:aprende_mas/views/widgets/buttons/custom_rounded_button.dart';
import 'package:aprende_mas/views/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherNoticeOptionsScreen extends ConsumerStatefulWidget {
  final int groupId;
  final int subjectId;
  final String? subjectName;

  const TeacherNoticeOptionsScreen({
    super.key,
    this.groupId = 0,
    this.subjectId = 0,
    this.subjectName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoticeOptionsScreenState();
}

class _NoticeOptionsScreenState
    extends ConsumerState<TeacherNoticeOptionsScreen> {
  NoticeModel notice = NoticeModel();
  
  // 1. CONTROLADOR DE BÚSQUEDA
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    // Lógica existente de IDs
    if (widget.groupId != 0) {
      notice = notice.copyWith(groupId: widget.groupId);
    } else if (widget.subjectId != 0) {
      notice = notice.copyWith(subjectId: widget.subjectId);
    }

    if (widget.subjectName != null) {
      notice = notice.copyWith(subjectName: widget.subjectName);
    }

    // 2. LISTENER: Actualiza la variable _searchTerm cada vez que escribes
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

  @override
  Widget build(BuildContext context) {
    // 3. OBTENER DATOS: Pedimos TODOS los avisos al provider (sin filtrar en backend)
    final futureNoticesls = ref.watch(futureNoticesProvider(notice));
    final String appBarTitle = widget.subjectName ?? 'Avisos';


    void requestAgain() {
      ref.refresh(futureNoticesProvider(notice));
    }

    ref.listen(
      noticesFormProvider,
      (previous, next) {
        if ((next.isFormPosted || next.isDeleted) && !next.isPosting) {
          requestAgain();
        }
      },
    );

    return futureNoticesls.when(
      data: (allNotices) {
        
        // 4. FILTRADO LOCAL: Filtramos la lista 'allNotices' aquí mismo
        final filteredNotices = allNotices.where((element) {
          final titleLower = element.title.toLowerCase();
          final descLower = element.description.toLowerCase();
          final searchLower = _searchTerm.toLowerCase();

          return titleLower.contains(searchLower) ||
                 descLower.contains(searchLower);
        }).toList();

        return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: allNotices.isNotEmpty
              ? FloatingActionButtonCustom(
                  voidCallback: () {
                    context.push(
                      '/teacher-create-notice?subjectName=${widget.subjectName}',
                      extra: notice,
                    );
                  },
                  icon: Icons.add,
                )
              : null,
                body: SafeArea(
                  child: Column(
                    children: [
                      // Campo de búsqueda (si hay avisos)
                      if (allNotices.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText: 'Buscar avisos',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              ),
                            ),
                          ),
                        ),

                      // Contenido principal SIEMPRE cubierto por Expanded
                      Expanded(
                        child: allNotices.isEmpty
                            ? Center(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(top: 60.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 180,
                                        child: SvgPicture.asset(
                                          'assets/icons/new_notice.svg',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Aquí podrás publicar anuncios,\nrecordatorios o enlaces\nimportantes para tus estudiantes.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 32),
                                      CustomRoundedButton(
                                        text: 'Crear primer aviso',
                                        onPressed: () {
                                          context.push(
                                            '/teacher-create-notice?subjectName=${widget.subjectName}',
                                            extra: notice,
                                          );
                                        },
                                        backgroundColor: const Color(0xFF283043),
                                        textColor: Colors.white,
                                        borderRadius: 24,
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(horizontal: 32),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : filteredNotices.isEmpty
                                ? const Center(
                                    child: Text('No se encontraron avisos con esa búsqueda.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                    ),
                                    
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    itemCount: filteredNotices.length,
                                    itemBuilder: (context, i) {
                                      final e = filteredNotices[i];
                                      return Column(
                                        children: [
                                          NoticeBody(
                                            optionsIsVisible: true,
                                            noticeId: e.noticeId ?? 0,
                                            teacherName: e.teacherFullName ?? "",
                                            createdDate: e.createdDate.toString(),
                                            title: e.title,
                                            content: e.description,
                                          ),
                                          SizedBox(
                                            height:
                                                MediaQuery.of(context).size.height * 0.02,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                )

        );
      },
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text(error.toString()))),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}