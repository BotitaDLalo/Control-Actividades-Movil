import 'package:aprende_mas/config/utils/packages.dart';

class FormScreen extends ConsumerWidget {
  final Widget form;
  const FormScreen({super.key, required this.form});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          // toolbarHeight: 60,
          // backgroundColor: Colors.transparent,
          // flexibleSpace: Container(
          //   decoration: const BoxDecoration(gradient: AppTheme.degradedBlue),
          // ),
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
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
