import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qless_app/bloc/user/user_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:qless_app/bloc/user/user_state.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _pickedImageFile;

  bool _isEditing = false;
  final String _profileImageUrl = 'https://via.placeholder.com/120';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });

      // TODO: Upload to Firebase or update user profile
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image selected: ${pickedFile.name}")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No image selected.")));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userState = context.watch<UserBloc>().state;
    if (userState is UserLoaded) {
      _nameController.text = (userState).user.name;
      _emailController.text = (userState).user.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is UserError) {
          return Scaffold(body: Center(child: Text("Error: ${state.message}")));
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (_isEditing) {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isEditing = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Profile saved successfully")),
                      );
                    }
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
                child: Text(
                  _isEditing ? 'Save' : 'Edit',
                  style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfilePictureSection(),
                  SizedBox(height: 30),
                  _buildSectionCard(
                    title: 'Personal Information',
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        enabled: _isEditing,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter name' : null,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val != null && val.contains('@')
                            ? null
                            : 'Enter valid email',
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val != null && val.length >= 10
                            ? null
                            : 'Enter valid phone number',
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _dobController,
                        label: 'Date of Birth',
                        icon: Icons.calendar_today_outlined,
                        enabled: _isEditing,
                        onTap: _isEditing ? () => _selectDate(context) : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Address Information',
                    children: [
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.location_on_outlined,
                        enabled: _isEditing,
                        maxLines: 2,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Account Settings',
                    children: [
                      _buildSettingTile(
                        title: 'Notifications',
                        subtitle: 'Receive booking updates',
                        icon: Icons.notifications_outlined,
                        trailing: Switch(
                          value: true,
                          onChanged: (value) {},
                          activeColor: Color(0xFF6366F1),
                        ),
                      ),
                      _buildSettingTile(
                        title: 'SMS Alerts',
                        subtitle: 'Get SMS notifications',
                        icon: Icons.sms_outlined,
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {},
                          activeColor: Color(0xFF6366F1),
                        ),
                      ),
                      _buildSettingTile(
                        title: 'Privacy Settings',
                        subtitle: 'Manage your privacy',
                        icon: Icons.privacy_tip_outlined,
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(),
                    icon: Icon(Icons.logout),
                    label: Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      backgroundColor: Colors.red[50],
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red[200]!),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: _pickedImageFile != null
                ? FileImage(_pickedImageFile!)
                : NetworkImage(_profileImageUrl),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 4,
              child: GestureDetector(
                onTap: _pickImage, // ✅ Call the image picker function
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onTap: onTap,
      validator: validator,
      readOnly: onTap != null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF6366F1)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Color(0xFF6366F1), size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF6366F1)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Logout'),
            onPressed: () {
              Navigator.pop(context);
              // Implement logout functionality here
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }
}
