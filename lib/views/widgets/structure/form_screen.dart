import 'package:aprende_mas/config/utils/packages.dart';
import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:aprende_mas/views/widgets/structure/app_bar_home.dart';

class FormScreen extends ConsumerWidget {
  final Widget form;
  final String? title;
  const FormScreen({super.key, required this.form, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: title != null
            ? AppBarHome(
                title: title!,
                showSettings: false,
                leading: IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    context.pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              )
            : AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      context.pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromARGB(255, 255, 255, 255),
                    )),
              ),
        body: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: form,
          ),
        ),
      ),
    );
  }
}
