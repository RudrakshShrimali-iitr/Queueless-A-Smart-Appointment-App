// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qless_app/merchant%20side/merchant_dashboard.dart';

class BusinessSetupForm extends StatefulWidget {
  @override
  _BusinessSetupFormState createState() => _BusinessSetupFormState();
}

class _BusinessSetupFormState extends State<BusinessSetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCategory = 'Salon';
  final List<String> _categories = [
    'Salon',
    'Spa',
    'Fitness',
    'Healthcare',
    'Restaurant',
    'Retail',
    'Government Office',
    'Bank',
    'Other',
  ];

  final List<Service> _services = [];
  TimeOfDay _openTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _closeTime = TimeOfDay(hour: 18, minute: 0);
  int _slotDuration = 30;
  bool _autoApproval = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Business Setup',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard('Business Information', Icons.business, [
                _buildTextField(
                  _businessNameController,
                  'Business Name',
                  Icons.store,
                ),
                SizedBox(height: 16),
                _buildDropdown(),
                SizedBox(height: 16),
                _buildTextField(
                  _addressController,
                  'Address',
                  Icons.location_on,
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                _buildTextField(_phoneController, 'Phone Number', Icons.phone),
                SizedBox(height: 16),
                _buildTextField(_emailController, 'Email', Icons.email),
              ]),

              SizedBox(height: 20),

              _buildSectionCard('Services Offered', Icons.room_service, [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    return _buildServiceCard(_services[index], index);
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addService,
                  icon: Icon(Icons.add),
                  label: Text('Add Service'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ]),

              SizedBox(height: 20),

              _buildSectionCard(
                'Working Hours & Preferences',
                Icons.access_time,
                [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeSelector('Opening Time', _openTime, (
                          time,
                        ) {
                          setState(() => _openTime = time);
                        }),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeSelector('Closing Time', _closeTime, (
                          time,
                        ) {
                          setState(() => _closeTime = time);
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildSlotDurationSelector(),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Auto-approve bookings'),
                    subtitle: Text(
                      'Automatically accept customer appointments',
                    ),
                    value: _autoApproval,
                    onChanged: (value) => setState(() => _autoApproval = value),
                    activeColor: Colors.blue[600],
                  ),
                ],
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save & Continue to Dashboard',
                          style: TextStyle(fontSize: 16),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[600], size: 24),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Business Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(value: category, child: Text(category));
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value!),
    );
  }

  Widget _buildServiceCard(Service service, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(service.name),
        subtitle: Text('₹${service.price} • ${service.duration} min'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => setState(() => _services.removeAt(index)),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final newTime = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (newTime != null) onChanged(newTime);
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(time.format(context), style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Slot Duration (minutes)',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
        Row(
          children: [15, 30, 45, 60].map((duration) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('${duration}m'),
                  selected: _slotDuration == duration,
                  onSelected: (selected) {
                    if (selected) setState(() => _slotDuration = duration);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _addService() {
    showDialog(context: context, builder: (context) => AddServiceDialog()).then(
      (service) {
        if (service != null) {
          setState(() => _services.add(service));
        }
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _services.isNotEmpty) {
      setState(() => _isLoading = true);

      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;

        final docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('businesses')
            .add({
              'businessName': _businessNameController.text.trim(),
              'category': _selectedCategory,
              'address': _addressController.text.trim(),
              'phone': _phoneController.text.trim(),
              'email': _emailController.text.trim(),
              'services': _services.map((s) => s.toMap()).toList(),
              'openingTime': '${_openTime.hour}:${_openTime.minute}',
              'closingTime': '  ${_closeTime.hour}:${_closeTime.minute}',
              'slotDuration': _slotDuration,
              'autoApproval': _autoApproval,
              'createdAt': FieldValue.serverTimestamp(),
            });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MerchantDashboard(businessId: docRef.id, merchantId: ''),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving business: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and add at least one service'),
        ),
      );
    }
  }
}

class AddServiceDialog extends StatefulWidget {
  @override
  _AddServiceDialogState createState() => _AddServiceDialogState();
}

class _AddServiceDialogState extends State<AddServiceDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _duration = 30;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Service'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Service Name'),
          ),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price (₹)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
            maxLines: 2,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Duration: '),
              DropdownButton<int>(
                value: _duration,
                items: [15, 30, 45, 60, 90, 120].map((duration) {
                  return DropdownMenuItem(
                    value: duration,
                    child: Text('$duration min'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _duration = value!),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _priceController.text.isNotEmpty) {
              Navigator.pop(
                context,
                Service(
                  name: _nameController.text,
                  price: double.parse(_priceController.text),
                  duration: _duration,
                  description: _descriptionController.text,
                ),
              );
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class Service {
  final String name;
  final double price;
  final int duration;
  final String description;

  Service({
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
    };
  }
}
