import 'package:flutter/material.dart';
import '../widgets/plant_grid_widget.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도감'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const PlantGridWidget(),
    );
  }
}


