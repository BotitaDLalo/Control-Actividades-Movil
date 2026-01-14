import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  // Propiedades personalizables
  final String title;
  final String subtitle;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final Color? cardColor;
  final double elevation;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? actions;
  final bool hasBadge;
  final String? badgeText;

  const CustomCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.imagePath,
    this.icon,
    this.iconColor,
    this.cardColor,
    this.elevation = 3.0,
    this.borderRadius = 16.0,
    this.onTap,
    this.onLongPress,
    this.actions,
    this.hasBadge = false,
    this.badgeText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: elevation,
      color: cardColor ?? colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icono/imagen
                  Row(
                    children: [
                      // Icono o imagen
                      if (imagePath != null)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: AssetImage(imagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (icon != null)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: iconColor ?? colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            color: iconColor ?? colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                      
                      const SizedBox(width: 12),
                      
                      // Título y subtítulo
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Acciones (botones)
                  if (actions != null && actions!.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions!
                          .map((action) => Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: action,
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
          
          // Badge (opcional)
          if (hasBadge && badgeText != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}