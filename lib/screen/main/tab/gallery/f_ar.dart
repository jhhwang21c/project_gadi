import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart' as vector64;

class ARFragment extends StatefulWidget {
  final Uint8List imageBytes; // Image bytes
  final double width; // Width in meters
  final double height; // Height in meters
  const ARFragment({
    super.key,
    required this.imageBytes,
    required this.width,
    required this.height,
  });

  @override
  State<ARFragment> createState() => _ARFragmentState();
}

class _ARFragmentState extends State<ARFragment> {
  late ArCoreController arCoreController;


  late final ArCoreNode node;

  bool isImagePlaced = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableUpdateListener: true,
        ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneDetected = _handleOnPlaneDetected;
  }


  void _handleOnPlaneDetected(ArCorePlane plane) {
    if (!isImagePlaced && plane.type == ArCorePlaneType.VERTICAL) {
      _addArt(plane);
      isImagePlaced = true;
    }
  }

  Future _addArt(ArCorePlane plane) async {
    final material = ArCoreMaterial(
      textureBytes: widget.imageBytes.buffer.asUint8List(),
      color: Colors.white,
    );

    final cube = ArCoreCube(
      materials: [material],
      size: vector64.Vector3(widget.width / 100, widget.height / 100, 0.01),
    );
    node = ArCoreNode(
        shape: cube,
        position: plane.centerPose?.translation ?? vector64.Vector3.zero(),
        );

    arCoreController.addArCoreNodeWithAnchor(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}