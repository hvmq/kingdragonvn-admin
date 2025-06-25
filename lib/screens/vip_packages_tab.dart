import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_list_response.dart';
import '../providers/vip_provider.dart';

class VipPackagesTab extends StatefulWidget {
  const VipPackagesTab({super.key});

  @override
  State<VipPackagesTab> createState() => _VipPackagesTabState();
}

class _VipPackagesTabState extends State<VipPackagesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VipProvider>(context, listen: false).fetchVipPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VipProvider>(
      builder: (context, vipProvider, child) {
        if (vipProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vipProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lỗi: ${vipProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    vipProvider.clearError();
                    vipProvider.fetchVipPackages();
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quản lý gói VIP',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => vipProvider.fetchVipPackages(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: vipProvider.packages.isEmpty
                    ? const Center(
                        child: Text(
                          'Không có gói VIP nào',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: vipProvider.packages.length,
                        itemBuilder: (context, index) {
                          final package = vipProvider.packages[index];
                          return VipPackageCard(
                            package: package,
                            onEdit: () => _showEditDialog(context, package),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, VipPackage package) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: Provider.of<VipProvider>(context, listen: false),
        child: VipPackageEditDialog(package: package),
      ),
    );
  }
}

class VipPackageCard extends StatelessWidget {
  final VipPackage package;
  final VoidCallback onEdit;

  const VipPackageCard({
    super.key,
    required this.package,
    required this.onEdit,
  });

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} VNĐ';
  }

  String _formatDuration(int duration) {
    if (duration < 30) {
      return '$duration ngày';
    } else if (duration < 365) {
      final months = (duration / 30).round();
      return '$months tháng';
    } else {
      final years = (duration / 365).round();
      return '$years năm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: package.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        package.isActive ? 'Hoạt động' : 'Tạm dừng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Chỉnh sửa',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giá:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _formatPrice(package.price),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thời hạn:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      _formatDuration(package.duration),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mô tả:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quyền lợi:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...package.benefits.map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(color: Colors.green)),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VipPackageEditDialog extends StatefulWidget {
  final VipPackage package;

  const VipPackageEditDialog({super.key, required this.package});

  @override
  State<VipPackageEditDialog> createState() => _VipPackageEditDialogState();
}

class _VipPackageEditDialogState extends State<VipPackageEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;
  late List<TextEditingController> _benefitControllers;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.package.name);
    _priceController =
        TextEditingController(text: widget.package.price.toString());
    _durationController =
        TextEditingController(text: widget.package.duration.toString());
    _descriptionController =
        TextEditingController(text: widget.package.description);
    _benefitControllers = widget.package.benefits
        .map((benefit) => TextEditingController(text: benefit))
        .toList();
    _isActive = widget.package.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    for (var controller in _benefitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addBenefit() {
    setState(() {
      _benefitControllers.add(TextEditingController());
    });
  }

  void _removeBenefit(int index) {
    if (_benefitControllers.length > 1) {
      setState(() {
        _benefitControllers[index].dispose();
        _benefitControllers.removeAt(index);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = int.tryParse(_priceController.text.trim());
    final duration = int.tryParse(_durationController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giá phải là số nguyên dương'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời hạn phải là số nguyên dương'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final benefits = _benefitControllers
        .map((controller) => controller.text.trim())
        .where((benefit) => benefit.isNotEmpty)
        .toList();

    if (benefits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phải có ít nhất một quyền lợi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedPackage = widget.package.copyWith(
        name: _nameController.text.trim(),
        price: price,
        duration: duration,
        description: _descriptionController.text.trim(),
        benefits: benefits,
        isActive: _isActive,
      );

      await Provider.of<VipProvider>(context, listen: false)
          .updateVipPackage(widget.package.id, updatedPackage);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật gói VIP thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        log('Lỗi cập nhật: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chỉnh sửa gói VIP',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên gói VIP',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Giá (VNĐ)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !_isLoading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Thời hạn (ngày)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !_isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isActive,
                          onChanged: _isLoading
                              ? null
                              : (value) => setState(() => _isActive = value!),
                        ),
                        const Text('Gói đang hoạt động'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quyền lợi:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          onPressed: _isLoading ? null : _addBenefit,
                          icon: const Icon(Icons.add),
                          tooltip: 'Thêm quyền lợi',
                        ),
                      ],
                    ),
                    ..._benefitControllers.asMap().entries.map(
                      (entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: 'Quyền lợi ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  enabled: !_isLoading,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => _removeBenefit(index),
                                icon: const Icon(Icons.remove),
                                tooltip: 'Xóa quyền lợi',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
