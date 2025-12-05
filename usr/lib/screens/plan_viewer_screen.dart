import 'package:flutter/material.dart';
import '../models/project_data.dart';

class PlanViewerScreen extends StatefulWidget {
  final Plan plan;

  const PlanViewerScreen({super.key, required this.plan});

  @override
  State<PlanViewerScreen> createState() => _PlanViewerScreenState();
}

class _PlanViewerScreenState extends State<PlanViewerScreen> {
  // Liste locale des points pour la démo (sera remplacée par Supabase)
  List<SnagPoint> snags = [];
  final TransformationController _transformationController = TransformationController();

  void _addSnag(TapUpDetails details, BoxConstraints constraints) {
    // Calcul des coordonnées relatives (0.0 à 1.0)
    final double relativeX = details.localPosition.dx / constraints.maxWidth;
    final double relativeY = details.localPosition.dy / constraints.maxHeight;

    _showAddSnagDialog(relativeX, relativeY);
  }

  void _showAddSnagDialog(double x, double y) {
    final TextEditingController descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle Reprise #${snags.length + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description du problème',
                hintText: 'Ex: Peinture écaillée, Prise non fixée...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Simulation prise de photo
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ajouter une photo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                snags.add(SnagPoint(
                  id: DateTime.now().toString(),
                  x: x,
                  y: y,
                  number: snags.length + 1,
                  description: descController.text.isEmpty ? 'Sans description' : descController.text,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Placer le point'),
          ),
        ],
      ),
    );
  }

  void _showSnagDetails(SnagPoint snag) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Text('${snag.number}', style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                Text('Reprise #${snag.number}', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      snags.remove(snag);
                    });
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            const Divider(height: 32),
            Text('Description:', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(snag.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.photo, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Aucune photo jointe', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plan.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              // TODO: Afficher la liste des reprises
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1000 / 800, // Ratio de l'image placeholder
                child: LayoutBuilder(
                  builder: (context, imageConstraints) {
                    return GestureDetector(
                      onTapUp: (details) => _addSnag(details, imageConstraints),
                      child: Stack(
                        children: [
                          // Le Plan (Image de fond)
                          Image.network(
                            widget.plan.imageUrl,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.broken_image, size: 50)),
                              );
                            },
                          ),
                          
                          // Les Points de situation (Markers)
                          ...snags.map((snag) => Positioned(
                            left: snag.x * imageConstraints.maxWidth - 15, // -15 pour centrer l'icône (30px)
                            top: snag.y * imageConstraints.maxHeight - 15,
                            child: GestureDetector(
                              onTap: () => _showSnagDetails(snag),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${snag.number}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Reset zoom
          _transformationController.value = Matrix4.identity();
        },
        icon: const Icon(Icons.center_focus_strong),
        label: const Text('Recentrer'),
      ),
    );
  }
}
