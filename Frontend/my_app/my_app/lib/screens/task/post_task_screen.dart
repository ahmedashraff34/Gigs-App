import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/theme.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../utils/location.dart';
import '../../widgets/inputBox.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/cloudinary.dart';

class PostTaskScreen extends StatefulWidget {
  final TaskResponse? taskToEdit;
  const PostTaskScreen({Key? key, this.taskToEdit}) : super(key: key);

  @override
  _PostTaskScreenState createState() => _PostTaskScreenState();
}

class _PostTaskScreenState extends State<PostTaskScreen>
    with TickerProviderStateMixin {
  double latitude = 0.0;
  double longitude = 0.0;
  GoogleMapController? _mapController;
  void _loadLocation() async {
    final position = await getCurrentLocation();
    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;
      print('Latitude: $latitude, Longitude: $longitude');
    } else {
      print('Could not get location');
    }
  }

  // Step control
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Section completion flags
  bool _categoryDone = false;
  bool _basicInfoDone = false;
  bool _detailsDone = false;

  // Form controllers and state
  Category? _selectedCategory = Category.Cleaning;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final Map<String, TextEditingController> _attrCtrls = {};
  final _fixedPayCtrl = TextEditingController();
  final _peopleCtrl = TextEditingController();
  final _locationDetailCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  bool _isSubmitting = false;
  LatLng? _pickedLocation;
  // Add requirements state
  List<String> _requirements = [];
  final List<TextEditingController> _requirementCtrls = [];

  // Image picker and Cloudinary state
  final List<File> _pickedImages = [];
  final List<String> _existingImageUrls = [];
  final List<String> _newlyUploadedCloudinaryUrls = [];
  final ImagePicker _picker = ImagePicker();
  final Set<int> _imagesMarkedForRemoval = {};

  bool _aiStarActive = false;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Slow color change
      value: 0.0,
    );
    _loadLocation();
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _selectedCategory = t.category;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      latitude = t.latitude;
      longitude = t.longitude;
      _pickedLocation = LatLng(t.latitude,
          t.longitude); // Set picked location to saved location when editing
      // Prefill requirements
      _requirements = [];
      _requirementCtrls.clear();
      if (t.additionalRequirements.isNotEmpty) {
        t.additionalRequirements.forEach((key, value) {
          _requirements.add(value.toString());
          _requirementCtrls.add(TextEditingController(text: value.toString()));
        });
      }
      // Prefill regular or event fields
      if (_selectedCategory == Category.EVENT_STAFFING) {
        _fixedPayCtrl.text = t.fixedPay?.toString() ?? '';
        _peopleCtrl.text = t.requiredPeople?.toString() ?? '';
        _locationDetailCtrl.text = t.location ?? '';
        _startDateCtrl.text = t.startDate ?? '';
        _endDateCtrl.text = t.endDate ?? '';
        _daysCtrl.text = t.numberOfDays?.toString() ?? '';
      } else {
        _amountCtrl.text = t.amount?.toString() ?? '';
        final schema = regularSchemas[_selectedCategory] ?? [];
        for (var field in schema) {
          _attrCtrls[field.key] = TextEditingController(
            text: t.additionalAttributes?[field.key]?.toString() ?? '',
          );
        }
      }
      // Prefill images
      if (t.imageUrls != null && t.imageUrls!.isNotEmpty) {
        _existingImageUrls.addAll(t.imageUrls!);
      }
    } else {
      // Initialize _attrCtrls for the default category if not EVENT_STAFFING
      if (_selectedCategory != null &&
          _selectedCategory != Category.EVENT_STAFFING) {
        final schema = regularSchemas[_selectedCategory] ?? [];
        for (var field in schema) {
          _attrCtrls[field.key] = TextEditingController();
        }
        // Set default for suppliesProvided to 'false' if not already set
        if (_attrCtrls['suppliesProvided'] == null ||
            _attrCtrls['suppliesProvided']!.text.isEmpty) {
          _attrCtrls['suppliesProvided'] = TextEditingController(text: 'false');
        }
      }
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _attrCtrls.values.forEach((c) => c.dispose());
    _fixedPayCtrl.dispose();
    _peopleCtrl.dispose();
    _locationDetailCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _daysCtrl.dispose();
    _requirementCtrls.forEach((c) => c.dispose());
    super.dispose();
  }

  void _onCategoryChanged(Category? cat) {
    if (cat == null) return;
    setState(() {
      _selectedCategory = cat;
      _attrCtrls.clear();
      if (cat != Category.EVENT_STAFFING) {
        final schema = regularSchemas[cat] ?? [];
        for (var field in schema) {
          _attrCtrls[field.key] = TextEditingController();
        }
      }
    });
  }

  Widget _buildRequirementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _requirements.add('');
              _requirementCtrls.add(TextEditingController());
            });
          },
          child: Row(
            children: [
              const Text('Add Requirements',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4F46E5))),
              const Spacer(),
              const Icon(Icons.add, color: Color(0xFF4F46E5))
            ],
          ),
        ),
        SizedBox(
          height: AppTheme.paddingMedium,
        ),
        ..._requirements.asMap().entries.map((entry) {
          int idx = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _requirementCtrls[idx],
                    onChanged: (val) {
                      _requirements[idx] = val;
                    },
                    decoration: InputDecoration(
                      hintText: 'Add a requirement',
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF4F46E5)),
                  onPressed: () {
                    setState(() {
                      _requirements.removeAt(idx);
                      _requirementCtrls.removeAt(idx).dispose();
                    });
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _pickImage({required ImageSource source}) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _pickedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _imagesMarkedForRemoval.add(index);
    });
  }

  void _removeNewImage(int index) async {
    // If already uploaded, delete from Cloudinary
    if (index < _newlyUploadedCloudinaryUrls.length) {
      final url = _newlyUploadedCloudinaryUrls[index];
      final publicId = CloudinaryService.extractPublicId(url);
      await CloudinaryService.deleteImageFromCloudinary(publicId);
      _newlyUploadedCloudinaryUrls.removeAt(index);
    }
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) return;
    setState(() => _isSubmitting = true);
    // Upload all picked images to Cloudinary
    List<String> uploadedImageUrls = [];
    for (final file in _pickedImages) {
      final url = await CloudinaryService.uploadImageToCloudinary(file);
      if (url != null) {
        uploadedImageUrls.add(url);
        _newlyUploadedCloudinaryUrls.add(url);
      }
    }
    // Remove images marked for removal from Cloudinary and from the list
    List<String> keptExistingImages = [];
    for (int i = 0; i < _existingImageUrls.length; i++) {
      if (_imagesMarkedForRemoval.contains(i)) {
        final url = _existingImageUrls[i];
        final publicId = CloudinaryService.extractPublicId(url);
        await CloudinaryService.deleteImageFromCloudinary(publicId);
      } else {
        keptExistingImages.add(_existingImageUrls[i]);
      }
    }
    // Combine with new images
    final allImageUrls = [...keptExistingImages, ...uploadedImageUrls];
    final prefs = await SharedPreferences.getInstance();
    final userId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;
    // Convert requirements to map
    final requirementsMap = {
      for (int i = 0; i < _requirements.length; i++)
        'R${i + 1}': _requirements[i]
    };
    dynamic taskRequest;
    if (_selectedCategory == Category.EVENT_STAFFING) {
      taskRequest = EventStaffingTask(
        taskPoster: userId,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        latitude: latitude,
        longitude: longitude,
        additionalRequirements: requirementsMap,
        fixedPay: double.tryParse(_fixedPayCtrl.text) ?? 0.0,
        requiredPeople: int.tryParse(_peopleCtrl.text) ?? 0,
        location: _locationDetailCtrl.text,
        startDate: _startDateCtrl.text,
        endDate: _endDateCtrl.text,
        numberOfDays: int.tryParse(_daysCtrl.text) ?? 0,
        imageUrls: allImageUrls,
      );
    } else {
      taskRequest = RegularTask(
        category: _selectedCategory!,
        taskPoster: userId,
        title: _titleCtrl.text,
        description: _descCtrl.text,
        latitude: latitude,
        longitude: longitude,
        amount: double.tryParse(_amountCtrl.text) ?? 0.0,
        additionalRequirements: requirementsMap,
        additionalAttributes: {
          for (var schema in regularSchemas[_selectedCategory]!)
            schema.key: () {
              final text = _attrCtrls[schema.key]?.text ?? '';
              switch (schema.type) {
                case InputType.number:
                  return int.tryParse(text) ?? 0;
                case InputType.boolean:
                  return text.toLowerCase() == 'true';
                case InputType.date:
                  return text;
                case InputType.text:
                default:
                  return text;
              }
            }()
        },
        imageUrls: allImageUrls,
      );
    }
    final service = TaskService();
    bool success;
    if (widget.taskToEdit != null) {
      // Edit mode
      success = await service.editTask(widget.taskToEdit!.taskId, taskRequest);
    } else {
      // New task
      success = await service.postTask(taskRequest);
    }
    setState(() => _isSubmitting = false);
    if (success) {
      Navigator.pushNamed(context, "/poster-home");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create/edit task')),
      );
    }
  }

  // Progress bar widget
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 32), // More space below
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final isActive = i <= _currentStep;
          final isNext = i > _currentStep;
          return Expanded(
            child: Container(
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color:
                    isActive ? AppTheme.primaryColor : AppTheme.disabledColor,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Step 1: Category selection
  Widget _buildCategorySection() {
    if (widget.taskToEdit != null) {
      // Show as label if editing
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor),
            ),
            child: Text(_selectedCategory?.name ?? '',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      );
    }
    final categories = Category.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Pick a Category', style: AppTheme.headerTextStyle),
        const SizedBox(height: AppTheme.paddingMedium),
        Center(
          child: SizedBox(
            width: 340, // To center grid and limit width
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final label = cat == Category.EVENT_STAFFING
                    ? 'Event Staffing'
                    : cat.name;
                final isSelected = _selectedCategory == cat;
                // Use custom icons for each category
                IconData icon;
                switch (cat) {
                  case Category.Cleaning:
                    icon = HugeIcons.strokeRoundedClean;
                    break;
                  case Category.Delivery:
                    icon = HugeIcons.strokeRoundedShippingTruck01;
                    break;
                  case Category.Assembly:
                    icon = HugeIcons.strokeRoundedTools;
                    break;
                  case Category.Handyman:
                    icon = HugeIcons.strokeRoundedLegalHammer;
                    break;
                  case Category.Lifting:
                    icon = HugeIcons.strokeRoundedPackageRemove;
                    break;
                  case Category.Custom:
                    icon = HugeIcons.strokeRoundedIdea01;
                    break;
                  case Category.EVENT_STAFFING:
                    icon = Icons.event;
                    break;
                  default:
                    icon = Icons.category;
                }
                return GestureDetector(
                  onTap: () => _onCategoryChanged(cat),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor.withOpacity(0.15)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon,
                            size: 36,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textColor1),
                        const SizedBox(height: 10),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textColor1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = _currentStep - 1;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedCategory != null
                    ? () {
                        setState(() {
                          _categoryDone = true;
                          _currentStep = 1;
                        });
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 2: Basic Info
  Widget _buildBasicInfoSection() {
    final isRegular = _selectedCategory != Category.EVENT_STAFFING;
    final isTitleFilled = _titleCtrl.text.trim().isNotEmpty;
    final isDescFilled = _descCtrl.text.trim().isNotEmpty;
    final amountText = _amountCtrl.text.trim();
    final isAmountFilled = !isRegular || amountText.isNotEmpty;
    final isAmountNumber = !isRegular || double.tryParse(amountText) != null;
    final canContinue =
        isTitleFilled && isDescFilled && isAmountFilled && isAmountNumber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        InputBox(
            maxLines: 1,
            label: 'Title',
            hintText: 'Enter task title',
            obscure: false,
            controller: _titleCtrl,
            onChanged: (_) => setState(() {})),
        const SizedBox(height: AppTheme.paddingMedium),
        // Requirements
        _buildRequirementsSection(),
        const SizedBox(height: AppTheme.paddingMedium),
        // Description with AI star (only for non-event categories)
        InputBox(
          label: 'Describe Your Task',
          hintText: 'Enter task description',
          obscure: false,
          controller: _descCtrl,
          onChanged: (_) => setState(() {}),
          minLines: 3,
          maxLines: 10,
          suffixIcon: _selectedCategory == Category.EVENT_STAFFING
              ? null
              : IconButton(
                  onPressed: () async {
                    setState(() => _aiStarActive = true);
                    final requirementsMap = {
                      for (int i = 0; i < _requirements.length; i++)
                        'R${i + 1}': _requirements[i]
                    };
                    final additionalAttributes = {
                      for (var schema in regularSchemas[_selectedCategory]!)
                        schema.key: () {
                          final text = _attrCtrls[schema.key]?.text ?? '';
                          switch (schema.type) {
                            case InputType.number:
                              return int.tryParse(text) ?? 0;
                            case InputType.boolean:
                              return text.toLowerCase() == 'true';
                            case InputType.date:
                              return text;
                            case InputType.text:
                            default:
                              return text;
                          }
                        }()
                    };
                    final payload = {
                      "title": _titleCtrl.text,
                      "type": _selectedCategory?.name, // pass as-is
                      "description": "",
                      "additionalRequirements": requirementsMap,
                      "additionalAttributes": additionalAttributes,
                    };
                    final service = TaskService();
                    final aiResult = await service.generateAIDescription(payload);
                    if (aiResult != null) {
                      setState(() {
                        _descCtrl.text = aiResult;
                        _aiStarActive = false;
                      });
                    } else {
                      setState(() => _aiStarActive = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to generate AI description')),
                      );
                    }
                  },
                  icon: AnimatedBuilder(
                    animation: _starController,
                    builder: (context, child) {
                      final color = ColorTween(
                        begin: Colors.amber,
                        end: Colors.purple,
                      ).animate(CurvedAnimation(
                        parent: _starController,
                        curve: Curves.easeInOut,
                      ));
                      return Icon(
                        Icons.auto_awesome,
                        size: 28,
                        color: color.value,
                      );
                    },
                  ),
                  tooltip: 'Suggest Description (AI)',
                ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        // Price (if regular)
        if (isRegular) ...[
          InputBox(
            label: 'Price',
            hintText: 'Enter amount',
            obscure: false,
            controller: _amountCtrl,
            isNumber: true,
            onChanged: (_) => setState(() {}),
            suffixIcon: IconButton(
              icon: Icon(Icons.auto_awesome, size: 28, color: Colors.amber),
              onPressed: () async {
                // Build requirements map
                final requirementsMap = {
                  for (int i = 0; i < _requirements.length; i++)
                    'R${i + 1}': _requirements[i]
                };
                // Build additionalAttributes map
                final additionalAttributes = {
                  for (var schema in regularSchemas[_selectedCategory]!)
                    schema.key: () {
                      final text = _attrCtrls[schema.key]?.text ?? '';
                      switch (schema.type) {
                        case InputType.number:
                          return int.tryParse(text) ?? 0;
                        case InputType.boolean:
                          return text.toLowerCase() == 'true';
                        case InputType.date:
                          return text;
                        case InputType.text:
                        default:
                          return text;
                      }
                    }()
                };
                final payload = {
                  "title": _titleCtrl.text,
                  "type": _selectedCategory?.name, // pass as-is
                  "description": _descCtrl.text,
                  "additionalRequirements": requirementsMap,
                  "additionalAttributes": additionalAttributes,
                };
                final service = TaskService();
                final aiResult = await service.generateAIPrice(payload);
                if (aiResult != null) {
                  setState(() {
                    _amountCtrl.text = aiResult;
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to generate AI price')),
                  );
                }
              },
              tooltip: 'Suggest Price (AI)',
            ),
          ),
          if (amountText.isNotEmpty && !isAmountNumber)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                'Amount must be a valid number',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
        ],
        const SizedBox(height: 16),
        // Photos
        Text('Task Photos',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF4F46E5))),
        const SizedBox(height: AppTheme.paddingSmall),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _existingImageUrls.length + _pickedImages.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              if (idx == _existingImageUrls.length + _pickedImages.length) {
                // Add button
                return GestureDetector(
                  onTap: () async {
                    final selected = await showModalBottomSheet<ImageSource>(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Pick from Gallery'),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.gallery),
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take a Photo'),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.camera),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (selected != null) {
                      await _pickImage(source: selected);
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF4F46E5)),
                    ),
                    child:
                        const Icon(Icons.add_a_photo, color: Color(0xFF4F46E5)),
                  ),
                );
              }
              if (idx < _existingImageUrls.length) {
                // Existing image
                final url = _existingImageUrls[idx];
                final isMarked = _imagesMarkedForRemoval.contains(idx);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Opacity(
                      opacity: isMarked ? 0.4 : 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 30),
                          ),
                        ),
                      ),
                    ),
                    if (!isMarked)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () => _removeExistingImage(idx),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.remove_circle,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    if (isMarked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child:
                                Icon(Icons.remove, color: Colors.red, size: 36),
                          ),
                        ),
                      ),
                  ],
                );
              } else {
                // New image
                final newIdx = idx - _existingImageUrls.length;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _pickedImages[newIdx],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(newIdx),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = _currentStep - 1;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: canContinue
                    ? () {
                        setState(() {
                          _basicInfoDone = true;
                          _currentStep = 3;
                        });
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    final places =
        GoogleMapsPlaces(apiKey: 'AIzaSyAvO4lBfjSkQIDLk-4gP7KMwIA5sQAbINQ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<Prediction>(
          builder: (context, controller, focusNode) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search for a place',
                  style:
                      AppTheme.textStyle1.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppTheme.paddingSmall),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: AppTheme.textStyle2,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF4F46E5)),
                    hintText: 'Type a location...',
                    hintStyle: AppTheme.textStyle2
                        .copyWith(color: AppTheme.textColor1.withOpacity(0.7)),
                    filled: true,
                    fillColor: AppTheme.dividerColor,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.paddingSmall),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.paddingSmall),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.paddingSmall),
                      borderSide:
                          BorderSide(color: AppTheme.primaryColor, width: 1),
                    ),
                  ),
                ),
              ],
            );
          },
          suggestionsCallback: (pattern) async {
            final response = await places.autocomplete(
              pattern,
              components: [Component(Component.country, 'eg')],
            );
            return response.predictions;
          },
          itemBuilder: (context, prediction) {
            return ListTile(
              title: Text(prediction.description ?? ''),
            );
          },
          onSelected: (prediction) async {
            final detail =
                await places.getDetailsByPlaceId(prediction.placeId!);
            final location = detail.result.geometry?.location;
            if (location != null) {
              final latLng = LatLng(location.lat, location.lng);
              setState(() {
                _pickedLocation = latLng;
                latitude = location.lat;
                longitude = location.lng;
              });
              // Move the map camera to the selected location
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(latLng),
              );
            }
          },
        ),
        SizedBox(
          height: AppTheme.paddingMedium,
        ),
        SizedBox(
          height: 350,
          child: FutureBuilder<LatLng?>(
            future: _pickedLocation != null
                ? Future.value(_pickedLocation)
                : getCurrentLatLng(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final LatLng initialPosition = _pickedLocation ?? snapshot.data!;
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPosition,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: (LatLng position) {
                  setState(() {
                    _pickedLocation = position;
                    latitude = position.latitude;
                    longitude = position.longitude;
                  });
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(position),
                  );
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('picked-location'),
                    position: _pickedLocation ?? snapshot.data!,
                  ),
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.paddingLarge),
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = _currentStep - 1;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = _currentStep + 1;
                  });
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Details (Event or Regular)
  Widget _buildDetailsSection() {
    if (_selectedCategory == Category.EVENT_STAFFING) {
      // Validation: all fields must be filled
      final isFixedPayFilled = _fixedPayCtrl.text.trim().isNotEmpty;
      final isPeopleFilled = _peopleCtrl.text.trim().isNotEmpty;
      final isLocationFilled = _locationDetailCtrl.text.trim().isNotEmpty;
      final isStartDateFilled = _startDateCtrl.text.trim().isNotEmpty;
      final isEndDateFilled = _endDateCtrl.text.trim().isNotEmpty;
      final isDaysFilled = _daysCtrl.text.trim().isNotEmpty;
      final canContinue = isFixedPayFilled &&
          isPeopleFilled &&
          isLocationFilled &&
          isStartDateFilled &&
          isEndDateFilled &&
          isDaysFilled;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputBox(
            label: 'Fixed Pay',
            hintText: 'Enter fixed pay',
            obscure: false,
            controller: _fixedPayCtrl,
            onChanged: (_) => setState(() {}),
            isNumber: true,
          ),
          const SizedBox(height: 12),
          InputBox(
            label: 'Required People',
            hintText: 'Enter number of people',
            obscure: false,
            controller: _peopleCtrl,
            onChanged: (_) => setState(() {}),
            isNumber: true,
          ),
          const SizedBox(height: 12),
          InputBox(
            label: 'Location',
            hintText: 'Enter event location',
            obscure: false,
            controller: _locationDetailCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _startDateCtrl,
            readOnly: true,
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                String formatted =
                    "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                setState(() {
                  _startDateCtrl.text = formatted;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'Start Date',
              hintText: 'YYYY-MM-DD',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endDateCtrl,
            readOnly: true,
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                String formatted =
                    "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                setState(() {
                  _endDateCtrl.text = formatted;
                });
              }
            },
            decoration: InputDecoration(
              labelText: 'End Date',
              hintText: 'YYYY-MM-DD',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
          ),
          const SizedBox(height: 12),
          InputBox(
            label: 'Number of Days',
            hintText: 'Enter total days',
            obscure: false,
            controller: _daysCtrl,
            onChanged: (_) => setState(() {}),
            isNumber: true,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = _currentStep - 1;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () {
                          setState(() {
                            _detailsDone = true;
                            _currentStep = 2;
                          });
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Task Information', style: AppTheme.headerTextStyle),
          const SizedBox(height: AppTheme.paddingMedium),
          for (var schema in regularSchemas[_selectedCategory]!) ...[
            if (schema.type == InputType.boolean)
              // Custom styled toggle for Supplies Provided
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        schema.label,
                        style: AppTheme.textStyle1
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Switch(
                      value:
                          _attrCtrls[schema.key]?.text.toLowerCase() == 'true',
                      activeColor: AppTheme.primaryColor,
                      inactiveThumbColor: AppTheme.textColor1,
                      inactiveTrackColor: AppTheme.disabledColor,
                      onChanged: (val) {
                        setState(() {
                          _attrCtrls[schema.key]?.text = val.toString();
                        });
                      },
                    ),
                  ],
                ),
              )
            else if (schema.type == InputType.boolean)
              DropdownButtonFormField<bool>(
                value: (_attrCtrls[schema.key]?.text.toLowerCase() == 'true'),
                items: const [
                  DropdownMenuItem(value: true, child: Text('Yes')),
                  DropdownMenuItem(value: false, child: Text('No')),
                ],
                onChanged: (value) {
                  setState(() {
                    _attrCtrls[schema.key]?.text = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: schema.label,
                  border: const OutlineInputBorder(),
                ),
              )
            else if (schema.type == InputType.date)
              TextField(
                controller: _attrCtrls[schema.key],
                readOnly: true,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    String isoDate = picked.toIso8601String();
                    setState(() {
                      _attrCtrls[schema.key]?.text = isoDate;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: schema.label,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              )
            else
              InputBox(
                label: schema.label,
                hintText: 'Enter ${schema.label.toLowerCase()}',
                obscure: false,
                controller: _attrCtrls[schema.key],
                isNumber: schema.type ==
                    InputType.number, // Make rooms/bathrooms number only
              ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = _currentStep - 1;
                      });
                    },
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _detailsDone = true;
                      _currentStep = 2;
                    });
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  // Step 4: Review & Submit
  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Review your task', style: AppTheme.headerTextStyle),
        const SizedBox(height: 16),
        Text('Category: ${_selectedCategory?.name ?? ''}'),
        Text('Title: ${_titleCtrl.text}'),
        Text('Description: ${_descCtrl.text}'),
        if (_selectedCategory == Category.EVENT_STAFFING) ...[
          Text('Fixed Pay: ${_fixedPayCtrl.text}'),
          Text('Required People: ${_peopleCtrl.text}'),
          Text('Location: ${_locationDetailCtrl.text}'),
          Text('Start Date: ${_startDateCtrl.text}'),
          Text('End Date: ${_endDateCtrl.text}'),
          Text('Number of Days: ${_daysCtrl.text}'),
        ] else ...[
          Text('Amount: ${_amountCtrl.text}'),
          Text('Additional Attributes:'),
          for (var schema in regularSchemas[_selectedCategory]!)
            Text('${schema.label}: ${_attrCtrls[schema.key]?.text ?? ''}'),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = _currentStep - 1;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Task'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit a Task' : 'Post a Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressBar(),
            if (_currentStep == 0) _buildCategorySection(),
            if (_currentStep == 1) _buildDetailsSection(),
            if (_currentStep == 2) _buildBasicInfoSection(),
            if (_currentStep == 3) _buildMapSection(),
            if (_currentStep == 4) _buildReviewSection(),
          ],
        ),
      ),
    );
  }
}
