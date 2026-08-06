import 'package:flutter/material.dart';

import '../../widgets/caregiver_ui.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() =>
      _AddMemoryScreenState();
}

class _AddMemoryScreenState
    extends State<AddMemoryScreen> {
  String privacy = 'العائلة والمريض';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CaregiverPage(
          child: Column(
            children: [
              const CaregiverHeader(
                title: 'إضافة ذكرى',
              ),

              const SizedBox(height: 22),

              CaregiverCard(
                onTap: () {},
                child: const SizedBox(
                  height: 135,
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .add_photo_alternate_outlined,
                          size: 40,
                          color:
                              CaregiverColors.rose,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'اختيار صورة',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const _MemoryField(
                label: 'عنوان الذكرى',
              ),

              const SizedBox(height: 12),

              const _MemoryField(
                label: 'التاريخ',
                icon:
                    Icons.calendar_today_outlined,
              ),

              const SizedBox(height: 12),

              const _MemoryField(
                label: 'المكان',
                icon:
                    Icons.location_on_outlined,
              ),

              const SizedBox(height: 12),

              const _MemoryField(
                label: 'الأشخاص الموجودون',
                icon: Icons.people_outline,
              ),

              const SizedBox(height: 12),

              const _MemoryField(
                label: 'وصف قصير',
                maxLines: 4,
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mic_none_rounded,
                  ),
                  label: const Text(
                    'إضافة وصف صوتي',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: privacy,
                decoration: InputDecoration(
                  labelText: 'مستوى الخصوصية',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'العائلة والمريض',
                    child: Text(
                      'العائلة والمريض',
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'المريض فقط',
                    child: Text(
                      'المريض فقط',
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    privacy =
                        value ?? privacy;
                  });
                },
              ),

              const SizedBox(height: 15),

              const _MemoryField(
                label: 'وقت ظهور الذكرى',
                icon: Icons.schedule_outlined,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        CaregiverColors.rose,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم حفظ الذكرى تجريبيًا ❤️',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'حفظ الذكرى',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
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
}

class _MemoryField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final int maxLines;

  const _MemoryField({
    required this.label,
    this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon == null ? null : Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}