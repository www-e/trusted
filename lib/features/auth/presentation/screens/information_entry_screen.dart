import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:trusted/core/constants/app_constants.dart';
import 'package:trusted/features/auth/domain/notifiers/signup_form_notifier.dart';
import 'package:trusted/features/auth/presentation/widgets/progress_bar.dart';

/// Screen for entering user information during the sign-up process
class InformationEntryScreen extends ConsumerStatefulWidget {
  /// Constructor
  const InformationEntryScreen({super.key});

  @override
  ConsumerState<InformationEntryScreen> createState() => _InformationEntryScreenState();
}

class _InformationEntryScreenState extends ConsumerState<InformationEntryScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late final provider;
  
  @override
  void initState() {
    super.initState();
    // We'll initialize the provider in didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get user data from route arguments
    final userData = ModalRoute.of(context)?.settings.arguments as ({String name, String email})?;
    // Create a provider instance with user data
    provider = signupFormProvider(userData ?? (name: '', email: ''));
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signupFormState = ref.watch(provider);
    final formData = signupFormState.formData;
    final selectedRole = formData.role;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال المعلومات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(provider.notifier).goToPreviousStep();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressBar(
                currentStep: 2,
                totalSteps: 3,
                stepLabels: const [
                  'اختيار الدور',
                  'المعلومات',
                  'التأكيد',
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'أدخل معلوماتك',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'يرجى إدخال المعلومات المطلوبة',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: {
                    'name': formData.name,
                    'email': formData.email,
                    'phone_number': formData.phoneNumber,
                    'secondary_phone_number': formData.secondaryPhoneNumber ?? '',
                    'nickname': formData.nickname,
                    'country': formData.country,
                    'business_name': formData.businessName ?? '',
                    'business_description': formData.businessDescription ?? '',
                    'working_solo': formData.workingSolo,
                    'associate_ids': formData.associateIds ?? '',
                    'whatsapp_number': formData.whatsappNumber ?? '',
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic information section
                        _buildSectionTitle('المعلومات الأساسية'),
                        const SizedBox(height: 16),
                        
                        // Name field (pre-filled from Google account)
                        FormBuilderTextField(
                          name: 'name',
                          decoration: const InputDecoration(
                            labelText: 'الاسم الكامل',
                            prefixIcon: Icon(Icons.person),
                          ),
                          enabled: false, // Disabled because it's pre-filled
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال الاسم الكامل',
                            ),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // Email field (pre-filled from Google account)
                        FormBuilderTextField(
                          name: 'email',
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email),
                          ),
                          enabled: false, // Disabled because it's pre-filled
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال البريد الإلكتروني',
                            ),
                            FormBuilderValidators.email(
                              errorText: 'الرجاء إدخال بريد إلكتروني صحيح',
                            ),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // Phone number field
                        FormBuilderTextField(
                          name: 'phone_number',
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال رقم الهاتف',
                            ),
                          ]),
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(provider.notifier)
                                  .updatePhoneNumber(value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Secondary phone number field (optional)
                        FormBuilderTextField(
                          name: 'secondary_phone_number',
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف الثانوي (اختياري)',
                            prefixIcon: Icon(Icons.phone_android),
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            ref.read(provider.notifier)
                                .updateSecondaryPhoneNumber(value);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Nickname field
                        FormBuilderTextField(
                          name: 'nickname',
                          decoration: const InputDecoration(
                            labelText: 'اللقب',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال اللقب',
                            ),
                          ]),
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(provider.notifier)
                                  .updateNickname(value);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Country field
                        FormBuilderTextField(
                          name: 'country',
                          decoration: const InputDecoration(
                            labelText: 'البلد',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(
                              errorText: 'الرجاء إدخال البلد',
                            ),
                          ]),
                          onChanged: (value) {
                            if (value != null) {
                              ref.read(provider.notifier)
                                  .updateCountry(value);
                            }
                          },
                        ),
                        
                        // Merchant-specific fields
                        if (selectedRole == AppConstants.roleMerchant) ...[
                          const SizedBox(height: 24),
                          _buildSectionTitle('معلومات التاجر'),
                          const SizedBox(height: 16),
                          
                          // Business name field
                          FormBuilderTextField(
                            name: 'business_name',
                            decoration: const InputDecoration(
                              labelText: 'اسم النشاط التجاري',
                              prefixIcon: Icon(Icons.business),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'الرجاء إدخال اسم النشاط التجاري',
                              ),
                            ]),
                            onChanged: (value) {
                              ref.read(provider.notifier)
                                  .updateBusinessName(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Business description field
                          FormBuilderTextField(
                            name: 'business_description',
                            decoration: const InputDecoration(
                              labelText: 'وصف النشاط التجاري',
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'الرجاء إدخال وصف النشاط التجاري',
                              ),
                            ]),
                            onChanged: (value) {
                              ref.read(provider.notifier)
                                  .updateBusinessDescription(value);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Working solo field
                          FormBuilderRadioGroup(
                            name: 'working_solo',
                            decoration: const InputDecoration(
                              labelText: 'هل تعمل بمفردك؟',
                            ),
                            options: const [
                              FormBuilderFieldOption(
                                value: true,
                                child: Text('نعم، أعمل بمفردي'),
                              ),
                              FormBuilderFieldOption(
                                value: false,
                                child: Text('لا، أعمل مع آخرين'),
                              ),
                            ],
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'الرجاء اختيار إجابة',
                              ),
                            ]),
                            onChanged: (value) {
                              ref.read(provider.notifier)
                                  .updateWorkingSolo(value as bool?);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Associate IDs field (only if not working solo)
                          if (formData.workingSolo == false)
                            FormBuilderTextField(
                              name: 'associate_ids',
                              decoration: const InputDecoration(
                                labelText: 'معرفات الشركاء',
                                prefixIcon: Icon(Icons.people),
                                hintText: 'أدخل معرفات الشركاء مفصولة بفواصل',
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(
                                  errorText: 'الرجاء إدخال معرفات الشركاء',
                                ),
                              ]),
                              onChanged: (value) {
                                ref.read(provider.notifier)
                                    .updateAssociateIds(value);
                              },
                            ),
                        ],
                        
                        // Mediator-specific fields
                        if (selectedRole == AppConstants.roleMediator) ...[
                          const SizedBox(height: 24),
                          _buildSectionTitle('معلومات الوسيط'),
                          const SizedBox(height: 16),
                          
                          // WhatsApp number field
                          FormBuilderTextField(
                            name: 'whatsapp_number',
                            decoration: const InputDecoration(
                              labelText: 'رقم الواتساب',
                              prefixIcon: Icon(Icons.phone_android),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'الرجاء إدخال رقم الواتساب',
                              ),
                            ]),
                            onChanged: (value) {
                              ref.read(provider.notifier)
                                  .updateWhatsappNumber(value);
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    if (ref.read(provider.notifier).goToNextStep()) {
                      Navigator.pushReplacementNamed(
                        context, 
                        '/signup/confirmation',
                        arguments: (name: formData.name, email: formData.email),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('التالي'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
