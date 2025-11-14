import 'package:aprende_mas/config/utils/app_theme.dart';
import 'package:flutter/material.dart';

class CardHeaderV2 extends StatelessWidget {
	final String title;
	final String? accessCode;
	final double height;

	const CardHeaderV2({
		super.key,
		required this.title,
		this.accessCode,
		this.height = 150,
	});

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			height: height,
			padding: const EdgeInsets.all(8.0),
			decoration: BoxDecoration(
				color: AppTheme.mainColor,
				borderRadius: const BorderRadius.only(
					topLeft: Radius.circular(12),
					topRight: Radius.circular(12),
				),
			),
			child: Row(
				children: [
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Text(
									title,
									style: const TextStyle(
										color: Colors.black,
										fontSize: 22,
										fontWeight: FontWeight.bold,
										overflow: TextOverflow.ellipsis,
									),
								),
								if (accessCode != null && accessCode!.isNotEmpty)
									Padding(
										padding: const EdgeInsets.only(top: 6.0),
										child: Row(
											children: [
												const Text(
													'Código de clase: ',
													style: TextStyle(color: Colors.black),
												),
												Text(
													accessCode!,
													style: const TextStyle(
															color: Colors.black, fontWeight: FontWeight.bold),
												)
											],
										),
									),
							],
						),
					),

				],
			),
		);
	}
}

