import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia/features/products/data/product_models.dart';
import 'product_form_controller.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? existingProduct;
  const ProductFormScreen({super.key, this.existingProduct});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      _nameController.text = widget.existingProduct!.name;
      _descController.text = widget.existingProduct!.description;
      _priceController.text = widget.existingProduct!.price.toInt().toString();
      _stockController.text = widget.existingProduct!.stock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final price = double.tryParse(_priceController.text) ?? -1;
    final stock = int.tryParse(_stockController.text) ?? -1;

    if (_nameController.text.isEmpty || price < 0 || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid input. Price and stock must be >= 0.'),
        ),
      );
      return;
    }

    await ref
        .read(productFormControllerProvider.notifier)
        .submit(
          name: _nameController.text,
          description: _descController.text,
          price: price,
          stock: stock,
        );

    final state = ref.read(productFormControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error.toString())));
    } else if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productFormControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Product Name',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Price (Rp)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Stock'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: state.isLoading ? null : _handleSubmit,
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}
