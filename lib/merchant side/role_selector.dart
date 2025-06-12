import 'package:flutter/material.dart';
import '../login sign up pages/role_option.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const RoleSelector({super.key, 
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Role',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RoleOption(
                value: 'customer',
                title: 'Customer',
                icon: Icons.person,
                subtitle: 'Join queues & book appointments',
                isSelected: selectedRole == 'customer',
                onTap: () => onRoleChanged('customer'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: RoleOption(
                value: 'merchant',
                title: 'Merchant',
                icon: Icons.business,
                subtitle: 'Manage queues & appointments',
                isSelected: selectedRole == 'merchant',
                onTap: () => onRoleChanged('merchant'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}