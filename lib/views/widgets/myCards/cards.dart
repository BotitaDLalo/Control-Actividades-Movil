import 'package:flutter/material.dart';
import 'card1.dart';

class CardsExample extends StatelessWidget {
  const CardsExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards Personalizadas - Material 3'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card básica con icono
            CustomCard(
              title: "Card con Icono",
              subtitle: "Esta es una tarjeta básica con un icono de Material Design",
              icon: Icons.credit_card,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card con icono presionada')),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Card con imagen
            CustomCard(
              title: "Card con Imagen",
              subtitle: "Tarjeta que muestra una imagen desde assets",
              imagePath: 'assets/images/sample.jpg', // Asegúrate de tener esta imagen
              elevation: 6.0,
              borderRadius: 20.0,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Card con imagen presionada')),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Card con badge y acciones
            CustomCard(
              title: "Card Premium",
              subtitle: "Tarjeta con badge y botones de acción personalizados",
              icon: Icons.star,
              iconColor: Colors.amber,
              cardColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              hasBadge: true,
              badgeText: "NUEVO",
              elevation: 8.0,
              actions: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Like presionado')),
                    );
                  },
                  icon: Icon(Icons.favorite_border,
                      color: Theme.of(context).colorScheme.primary),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compartir presionado')),
                    );
                  },
                  icon: Icon(Icons.share,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Card con colores personalizados
            CustomCard(
              title: "Card Personalizada",
              subtitle: "Con colores y estilo completamente personalizables",
              icon: Icons.palette,
              iconColor: Colors.white,
              cardColor: Colors.deepPurple,
              elevation: 12.0,
              borderRadius: 24.0,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Card personalizada presionada'),
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}