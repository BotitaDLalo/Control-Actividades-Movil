import 'dart:ui';

import 'package:aprende_mas/models/models.dart';
import 'package:aprende_mas/views/widgets/inputs/inputs.dart';

import '../../views/widgets/inputs/color_input.dart';

class FormSubjectsState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final GenericInput subjectName;
  final GenericInput subjectDescription;
  final ColorInput colorCode;
  final Color subPickerColor;
  final List<int> groupsId;
  final Map<int, bool> isSelectedGroup;
  final VerifyEmail? verifyEmail;
  final String errorMessage;

  FormSubjectsState(
      {this.groupsId = const [],
      this.isPosting = false,
      this.isFormPosted = false,
      this.isValid = false,
      this.isSelectedGroup = const {},
      this.subjectName = const GenericInput.pure(),
      this.subjectDescription = const GenericInput.pure(),
      this.colorCode = const ColorInput.pure(),
      this.subPickerColor = const Color.fromARGB(0, 255, 255, 255),
      this.errorMessage = '',
      this.verifyEmail});

  FormSubjectsState copyWith(
          {bool? isPosting,
          bool? isFormPosted,
          bool? isValid,
          Map<int, bool>? isSelectedGroup,
          GenericInput? subjectName,
          GenericInput? subjectDescription,
          ColorInput? colorCode,
          Color? subPickerColor,
          List<int>? groupsId,
          String? errorMessage,
          VerifyEmail? verifyEmail}) =>
      FormSubjectsState(
          isPosting: isPosting ?? this.isPosting,
          isFormPosted: isFormPosted ?? this.isFormPosted,
          isValid: isValid ?? this.isValid,
          isSelectedGroup: isSelectedGroup ?? this.isSelectedGroup,
          subjectName: subjectName ?? this.subjectName,
          subjectDescription: subjectDescription ?? this.subjectDescription,
          colorCode: colorCode ?? this.colorCode,
          subPickerColor: subPickerColor ?? this.subPickerColor,
          groupsId: groupsId ?? this.groupsId,
          errorMessage: errorMessage ?? this.errorMessage,
          verifyEmail: verifyEmail ?? this.verifyEmail
          );
}
