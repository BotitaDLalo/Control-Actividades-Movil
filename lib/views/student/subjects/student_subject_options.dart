import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/responsive_utils.dart';
import 'package:aprende_mas/models/models.dart';

class StudentSubjectOptions extends StatelessWidget {
  final List<GroupSubjectWidgetOption> lsSubjectOptions;
  final ValueChanged<int> onOptionSelected;
  final int selectedOptionIndex;
  final int subjectId;
  const StudentSubjectOptions({
    super.key,
    required this.lsSubjectOptions,
    required this.onOptionSelected,
    required this.selectedOptionIndex,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    final subjectColor = getSubjectColor(subjectId);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: lsSubjectOptions
                .map(
                  (e) => Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            onOptionSelected(e.optionId); // Llama al callback
                          },
                          child: Column(
                            children: [
                              Text(
                                e.optionText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedOptionIndex == e.optionId
                                      ? subjectColor
                                      : Colors.black,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                height: 2,
                                width:
                                    selectedOptionIndex == e.optionId ? 90 : 0,
                                color: subjectColor,
                                curve: Curves.easeInOut,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList()),
      ),
    );
  }
}
