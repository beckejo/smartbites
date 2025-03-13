import 'package:flutter/material.dart';
import 'package:smartbites/screens/get_scale_reading_page.dart';

class WeightMeasurementScreen extends StatefulWidget {
  const WeightMeasurementScreen({super.key});

  @override
  _WeightMeasurementScreenState createState() =>
      _WeightMeasurementScreenState();
}

class _WeightMeasurementScreenState extends State<WeightMeasurementScreen> {
  final TextEditingController initialWeightController = TextEditingController();
  final TextEditingController finalWeightController = TextEditingController();
  double? scaleAmountUsed;

  void _calculateWeightUsed() {
    // If we already have a scale measurement, use that
    if (scaleAmountUsed != null) {
      Navigator.pop(context, scaleAmountUsed);
      return;
    }
    
    // Otherwise use manual calculations
    final initialWeight = double.tryParse(initialWeightController.text) ?? 0;
    final finalWeight = double.tryParse(finalWeightController.text) ?? 0;
    final weightUsed = initialWeight - finalWeight;

    Navigator.pop(context, weightUsed);
  }
  
  Future<void> _useBluetoothScale() async {
    // Navigate to scale reading page and await result
    final amountUsed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GetScaleReadingPage()),
    );
    
    // If we got a valid measurement back
    if (amountUsed != null && amountUsed is double) {
      setState(() {
        scaleAmountUsed = amountUsed;
        // Also update the text controllers so user can see the values
        initialWeightController.text = "Measured with scale";
        finalWeightController.text = "Amount used: ${amountUsed.toStringAsFixed(1)}g";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Measurement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scale option section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smart Scale Option',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Connect to a Bluetooth scale to automatically measure ingredient weights',
                  ),
                  const SizedBox(height: 16),
                  if (scaleAmountUsed != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 10),
                          Text(
                            'Measured: ${scaleAmountUsed!.toStringAsFixed(1)}g used',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _useBluetoothScale,
                      icon: const Icon(Icons.bluetooth),
                      label: const Text('Use BLE Scale'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('OR', style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
            
            // Manual entry section
            const Text(
              'Manual Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: initialWeightController,
              decoration: const InputDecoration(
                labelText: 'Initial Weight (grams)',
                enabled: true,
              ),
              keyboardType: TextInputType.number,
              enabled: scaleAmountUsed == null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: finalWeightController,
              decoration: const InputDecoration(
                labelText: 'Final Weight (grams)',
              ),
              keyboardType: TextInputType.number,
              enabled: scaleAmountUsed == null,
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _calculateWeightUsed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                scaleAmountUsed != null ? 'Use Scale Measurement' : 'Calculate & Continue',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            if (scaleAmountUsed != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    scaleAmountUsed = null;
                    initialWeightController.clear();
                    finalWeightController.clear();
                  });
                },
                child: const Text('Cancel Scale Measurement'),
              ),
          ],
        ),
      ),
    );
  }
}
