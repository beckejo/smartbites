import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class GetScaleReadingPage extends StatefulWidget {
  const GetScaleReadingPage({Key? key}) : super(key: key);

  @override
  State<GetScaleReadingPage> createState() => _GetScaleReadingPageState();
}

class _GetScaleReadingPageState extends State<GetScaleReadingPage> {
  // Status variables
  bool _isScanning = false;
  String _statusMessage = 'Ready to scan';
  double? _weightReading;
  double? _initialWeight;
  double? _finalWeight;
  double? _amountUsed;
  
  // Workflow step
  int _currentStep = 0;
  
  // BLE references
  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  
  // Scale UUIDs - these match your Python code
  final String _weightUuid = "0000FFF4-0000-1000-8000-00805F9B34FB";
  final String _writeUuid = "000036F5-0000-1000-8000-00805F9B34FB";
  
  // Commands
  final Map<String, List<int>> _commands = {
    'tare': [0x03, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x0C],
  };

  @override
  void initState() {
    super.initState();
    // Initialize BLE
    _initBle();
  }

  @override
  void dispose() {
    // Clean up subscriptions
    _scanSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    // Disconnect from device if connected
    _connectedDevice?.disconnect();
    super.dispose();
  }

  Future<void> _initBle() async {
    // Check if Bluetooth is available
    try {
      await FlutterBluePlus.adapterState.first;
    } catch (e) {
      setState(() {
        _statusMessage = 'Bluetooth adapter not available';
      });
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for BLE scales...';
    });

    try {
      // Check for permissions first (required on most platforms)
      await FlutterBluePlus.turnOn();
      
      // Start scanning with timeout - this will automatically stop after the timeout
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );
      
      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          // Look for devices with the name "Decent Scale" or other scale names
          for (ScanResult result in results) {
            debugPrint('Found device: ${result.device.platformName}');
            
            // Check if this is our scale - modify this condition based on your scale's name
            if (result.device.platformName.contains('Scale') ||
                result.device.platformName.contains('Decent')) {
              if (mounted) {  // Add mounted check
                _connectToDevice(result.device);
                break;
              }
            }
          }
        },
        onError: (e) {
          if (mounted) {  // Add mounted check
            setState(() {
              _isScanning = false;
              _statusMessage = 'Scan error: $e';
            });
          }
        },
      );

      // Listen for when the scan completes (after timeout)
      FlutterBluePlus.isScanning.listen((isScanning) {
        if (!isScanning && mounted) {
          setState(() {
            _isScanning = false;
            if (_connectedDevice == null) {
              _statusMessage = 'No compatible scale found. Try again?';
            }
          });
        }
      });
      
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Failed to start scan: $e';
      });
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Stop scanning when connecting
      if (_isScanning) {
        await FlutterBluePlus.stopScan();
      }
      
      if (!mounted) return;  // Add mounted check
      
      setState(() {
        _statusMessage = 'Connecting to ${device.platformName}...';
      });

      // Connect to device
      await device.connect();
      
      if (!mounted) return;  // Add mounted check
      
      _connectedDevice = device;
      setState(() {
        _statusMessage = 'Connected to ${device.platformName}';
        _currentStep = 1; // Move to first step after connection
      });
      
      // Monitor connection state
      _connectionStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected && mounted) {  // Add mounted check
          setState(() {
            _statusMessage = 'Device disconnected';
            _connectedDevice = null;
            _currentStep = 0; // Reset to beginning if disconnected
          });
          _connectionStateSubscription?.cancel();
        }
      });
      
      // Discover services
      await _discoverServices(device);
    } catch (e) {
      if (mounted) {  // Add mounted check
        setState(() {
          _statusMessage = 'Connection error: $e';
        });
      }
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    if (!mounted) return;  // Add mounted check
    
    setState(() {
      _statusMessage = 'Discovering services...';
    });
    
    try {
      List<BluetoothService> services = await device.discoverServices();
      
      if (!mounted) return;  // Add mounted check
      
      setState(() {
        _statusMessage = 'Please press TARE to begin';  // Better initial prompt
        _currentStep = 1;
      });
      
      // Debug log all services and characteristics
      for (BluetoothService service in services) {
        debugPrint('Service UUID: ${service.uuid}');
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          debugPrint('  - Characteristic: ${characteristic.uuid}');
        }
      }
      
      // Find the weight service and characteristic - improve UUID matching
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          // Check if this is the weight characteristic - use case-insensitive comparison
          String charUuid = characteristic.uuid.toString().toUpperCase();
          debugPrint('Checking characteristic: $charUuid');
          
          // More flexible UUID matching
          if (charUuid.endsWith("FFF4") || charUuid == _weightUuid) {
            // Subscribe to notifications for weight readings
            debugPrint('Found weight characteristic: $charUuid');
            await characteristic.setNotifyValue(true);
            
            // Listen for weight updates
            characteristic.onValueReceived.listen((value) {
              if (mounted) {  // Add mounted check
                _handleWeightData(value);
              }
            });
            
            debugPrint('Subscribed to weight characteristic');
          }
          
          // Match write characteristic
          if (charUuid.endsWith("36F5") || charUuid == _writeUuid) {
            debugPrint('Found write characteristic: $charUuid');
          }
        }
      }
    } catch (e) {
      if (mounted) {  // Add mounted check
        setState(() {
          _statusMessage = 'Error discovering services: $e';
        });
      }
    }
  }
  
  void _handleWeightData(List<int> data) {
    // Parse the weight data using same logic as your Python code
    try {
      debugPrint('Received weight data: $data');
      
      if (data.length == 10) { // Firmware 1.2+ expects 10-byte messages
        int weightRaw = (data[2] << 8 | data[3]);
        // Handle signed values correctly
        if (weightRaw > 32767) {
          weightRaw = weightRaw - 65536;
        }
        double weight = weightRaw / 10.0; // Convert to grams
        
        debugPrint('Parsed weight: $weight g');
        
        if (mounted) {  // Add mounted check
          setState(() {
            _weightReading = weight;
          });
        }
      } else {
        debugPrint('Unexpected data length: ${data.length}');
      }
    } catch (e) {
      debugPrint('Error parsing weight data: $e');
    }
  }

  Future<void> _sendTareCommand() async {
    try {
      if (_connectedDevice == null) {
        debugPrint('No device connected');
        return;
      }
      
      // Find the write characteristic
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      
      BluetoothCharacteristic? writeCharacteristic;
      
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          String charUuid = characteristic.uuid.toString().toUpperCase();
          
          // More flexible UUID matching
          if (charUuid.endsWith("36F5") || charUuid == _writeUuid) {
            writeCharacteristic = characteristic;
            debugPrint('Found write characteristic for tare: $charUuid');
            break;
          }
        }
        if (writeCharacteristic != null) break;
      }
      
      if (writeCharacteristic != null) {
        // Send tare command twice with a delay (as in Python code)
        await writeCharacteristic.write(_commands['tare']!);
        debugPrint('First tare command sent');
        await Future.delayed(const Duration(milliseconds: 300));
        await writeCharacteristic.write(_commands['tare']!);
        debugPrint('Second tare command sent');
        
        if (mounted) {  // Add mounted check
          setState(() {
            _statusMessage = 'Scale tared';
          });
        }
      } else {
        debugPrint('Write characteristic not found');
        if (mounted) {  // Add mounted check
          setState(() {
            _statusMessage = 'Error: Could not find tare control';
          });
        }
      }
    } catch (e) {
      debugPrint('Error in tare command: $e');
      if (mounted) {  // Add mounted check
        setState(() {
          _statusMessage = 'Error sending tare command: $e';
        });
      }
    }
  }

  // Record the initial weight and move to next step
  void _recordInitialWeight() {
    setState(() {
      _initialWeight = _weightReading;
      _statusMessage = 'Initial weight recorded: ${_initialWeight?.toStringAsFixed(1)} g';
      _currentStep = 2; // Move to next step
    });
  }

  // Record the final weight and calculate amount used
  void _recordFinalWeight() {
    if (_initialWeight != null && _weightReading != null) {
      setState(() {
        _finalWeight = _weightReading;
        _amountUsed = _initialWeight! - _finalWeight!;
        _statusMessage = 'Amount used: ${_amountUsed?.toStringAsFixed(1)} g';
        _currentStep = 3; // Move to completed step
      });
    } else {
      setState(() {
        _statusMessage = 'Error: Missing weight data';
      });
    }
  }

  // Reset the workflow to start over
  void _resetWorkflow() {
    setState(() {
      _initialWeight = null;
      _finalWeight = null;
      _amountUsed = null;
      _currentStep = 1; // Reset to first weighing step
      _statusMessage = 'Ready to weigh ingredients';
    });
  }

  // Return result and close page
  void _finishAndReturn() {
    // Return the amount used to the calling page
    Navigator.pop(context, _amountUsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Weighing'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
              
              // Current weight display
              if (_weightReading != null)
                Column(
                  children: [
                    const Text(
                      'Current Weight:',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${_weightReading?.toStringAsFixed(1)} g',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_amountUsed != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Amount Used: ${_amountUsed?.toStringAsFixed(1)} g',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ],
                ),
              
              const SizedBox(height: 30),
              
              // Step-specific buttons
              _buildStepButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepButtons() {
    // If not connected, show scan button
    if (_currentStep == 0) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        onPressed: _isScanning ? null : _startScan,
        child: _isScanning
            ? const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Scanning...'),
                ],
              )
            : const Text('Connect to Scale'),
      );
    } 
    // Step 1: Initial weight measurement
    else if (_currentStep == 1) {
      return Column(
        children: [
          Text(
            'Step 1: Place ingredient on scale',
            style: TextStyle(fontSize: 18, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 8),
          // Add clear instruction about needing to tare first
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: const Text(
              'Press TARE first to begin reading weights',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _sendTareCommand,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,  // Make the tare button more prominent
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tare Scale'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _weightReading != null ? _recordInitialWeight : null,
                child: const Text('Record Initial Weight'),
              ),
            ],
          ),
        ],
      );
    } 
    // Step 2: Final weight measurement
    else if (_currentStep == 2) {
      return Column(
        children: [
          Text(
            'Step 2: Use ingredient, then place remainder back on scale',
            style: TextStyle(fontSize: 18, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 10),
          Text(
            'Initial weight: ${_initialWeight?.toStringAsFixed(1)} g',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _sendTareCommand,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                ),
                child: const Text('Tare Scale'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _weightReading != null ? _recordFinalWeight : null,
                child: const Text('Record Final Weight'),
              ),
            ],
          ),
        ],
      );
    } 
    // Step 3: Result display
    else {
      return Column(
        children: [
          // Use Column instead of Row for buttons to avoid overflow
          ElevatedButton(
            onPressed: _resetWorkflow,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade400,
              minimumSize: const Size(200, 48),  // Set a fixed width
            ),
            child: const Text('Weigh Another Ingredient'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _finishAndReturn,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: const Size(200, 48),  // Set a fixed width
            ),
            child: const Text('Use This Amount'),
          ),
        ],
      );
    }
  }
}