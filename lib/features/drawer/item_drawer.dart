import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/item_cubit.dart';
import '../../../cubit/item_state.dart';
import '../../../core/database/models/item_model.dart';

class ItemDrawer extends StatefulWidget {
  final ItemModel? item;
  final ScrollController? scrollController;

  const ItemDrawer({
    super.key,
    this.item,
    this.scrollController,
  });

  @override
  State<ItemDrawer> createState() => _ItemDrawerState();
}

class _ItemDrawerState extends State<ItemDrawer> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _valueController;
  late String _selectedCategory;
  late String _selectedStatus;

  final List<String> _categories = [
    'Eletrônicos',
    'Roupas',
    'Alimentos',
    'Livros',
    'Casa',
    'Outros',
  ];

  final List<String> _statuses = ['active', 'inactive', 'pending'];
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'inactive':
        return 'Inativo';
      case 'pending':
        return 'Pendente';
      default:
        return status;
    }
  }

  bool _isLoading = false;
  bool _hasHandledSuccess = false;
  late FocusNode _valueFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    final initialValue = widget.item?.value ?? 0.0;
    String formattedValue = '';
    if (initialValue > 0) {
      final parts = initialValue.toStringAsFixed(2).split('.');
      final integerPart = parts[0];
      final decimalPart = parts[1];
      
      String formattedInteger = '';
      for (int i = integerPart.length - 1; i >= 0; i--) {
        formattedInteger = integerPart[i] + formattedInteger;
        if ((integerPart.length - i) % 3 == 0 && i > 0) {
          formattedInteger = '.' + formattedInteger;
        }
      }
      
      formattedValue = '$formattedInteger,$decimalPart';
    }
    _valueController = TextEditingController(text: formattedValue);
    _selectedCategory = widget.item?.category ?? _categories[0];
    _selectedStatus = widget.item?.status ?? _statuses[0];
    
    _valueFocusNode = FocusNode();
    _valueFocusNode.addListener(() {
      if (!_valueFocusNode.hasFocus) {
        _formatValue();
      } else {
        _unformatValue();
      }
    });
  }
  
  void _formatValue() {
    final text = _valueController.text;
    if (text.isEmpty) return;
    
    String cleanText = text.replaceAll(RegExp(r'[^\d,.]'), '');
    
    bool hasComma = cleanText.contains(',');
    bool hasDot = cleanText.contains('.');
    
    String integerPart = '';
    String decimalPart = '';
    
    if (hasComma || hasDot) {
      cleanText = cleanText.replaceAll('.', ',');
      final parts = cleanText.split(',');
      integerPart = parts[0].replaceAll(RegExp(r'[^\d]'), '');
      decimalPart = parts.length > 1 ? parts[1].replaceAll(RegExp(r'[^\d]'), '') : '';
      
      if (decimalPart.length > 2) {
        decimalPart = decimalPart.substring(0, 2);
      }
    } else {
      integerPart = cleanText.replaceAll(RegExp(r'[^\d]'), '');
    }
    
    if (integerPart.isEmpty) {
      _valueController.text = '';
      return;
    }
    
    String formattedInteger = _formatInteger(integerPart);
    
    String formattedText = formattedInteger;
    if (hasComma || hasDot) {
      if (decimalPart.isNotEmpty) {
        formattedText = '$formattedInteger,$decimalPart';
      } else {
        formattedText = '$formattedInteger,00';
      }
    }
    
    _valueController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
  
  void _unformatValue() {
    final text = _valueController.text;
    if (text.isEmpty) return;
    
    String cleanText = text.replaceAll('.', '');
    _valueController.value = TextEditingValue(
      text: cleanText,
      selection: TextSelection.collapsed(offset: cleanText.length),
    );
  }
  
  String _formatInteger(String integerPart) {
    if (integerPart.isEmpty) {
      return '';
    }
    
    String cleanInteger = integerPart.replaceAll('.', '');
    
    if (cleanInteger.isEmpty) {
      return '';
    }
    
    String formatted = '';
    int digitCount = 0;
    
    for (int i = cleanInteger.length - 1; i >= 0; i--) {
      if (digitCount > 0 && digitCount % 3 == 0) {
        formatted = '.' + formatted;
      }
      formatted = cleanInteger[i] + formatted;
      digitCount++;
    }
    
    return formatted;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasHandledSuccess = false;
    });

    try {
      final cubit = context.read<ItemCubit>();
      final now = DateTime.now();

      final cleanValue = _valueController.text
          .replaceAll(RegExp(r'[^\d,.]'), '')
          .replaceAll(',', '.');

      if (widget.item == null) {
        final newItem = ItemModel(
          id: ItemModel.generateId(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          value: double.parse(cleanValue),
          createdAt: now,
          updatedAt: now,
          status: _selectedStatus,
        );
        await cubit.createItem(newItem).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            if (mounted) {
              _hasHandledSuccess = true;
              setState(() {
                _isLoading = false;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item criado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            }
          },
        );
      } else {
        final updatedItem = widget.item!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          value: double.parse(cleanValue),
          status: _selectedStatus,
          updatedAt: now,
        );
        await cubit.updateItem(updatedItem).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            if (mounted) {
              _hasHandledSuccess = true;
              setState(() {
                _isLoading = false;
              });
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item atualizado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            }
          },
        );
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted && _isLoading && !_hasHandledSuccess) {
        final currentState = cubit.state;
        
        if (currentState is ItemLoaded || currentState is ItemSuccess) {
          _hasHandledSuccess = true;
          setState(() {
            _isLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Operação realizada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        } else if (currentState is ItemError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currentState.message),
              backgroundColor: Colors.red,
              ),
            );
          } else {
            _hasHandledSuccess = true;
          setState(() {
            _isLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Operação concluída'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.item != null;

    return BlocListener<ItemCubit, ItemState>(
      listenWhen: (previous, current) {
        final isSuccess = previous is ItemLoading && current is ItemLoaded;
        final isError = current is ItemError && previous is! ItemError;
        
        return (isSuccess || isError) && _isLoading;
      },
      listener: (context, state) {
        if (!mounted || !_isLoading || _hasHandledSuccess) {
          return;
        }
        
        if (state is ItemLoaded) {
          _hasHandledSuccess = true;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Operação realizada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              });
            }
          });
        } else if (state is ItemError) {
          _hasHandledSuccess = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit : Icons.add,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Editar Item' : 'Novo Item',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome *',
                          hintText: 'Digite o nome do item',
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O nome é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição *',
                          hintText: 'Digite a descrição do item',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'A descrição é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _valueController,
                        focusNode: _valueFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Valor *',
                          hintText: '0,00',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'O valor é obrigatório';
                          }
                          final cleanValue = value.replaceAll(RegExp(r'[^\d,.]'), '').replaceAll(',', '.');
                          final doubleValue = double.tryParse(cleanValue);
                          if (doubleValue == null || doubleValue < 0) {
                            return 'Digite um valor válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoria *',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione uma categoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusLabel(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Selecione um status';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(isEdit ? 'Atualizar' : 'Criar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


