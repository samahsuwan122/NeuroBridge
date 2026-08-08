import 'package:flutter/material.dart';

import '../widgets/auth_background.dart';

class AiAssistantScreen extends StatefulWidget {
  final String? initialQuestion;

  const AiAssistantScreen({
    super.key,
    this.initialQuestion,
  });

  @override
  State<AiAssistantScreen> createState() =>
      _AiAssistantScreenState();
}

class _AiAssistantScreenState
    extends State<AiAssistantScreen> {
  static const Color _rose = Color(0xFFB87585);
  static const Color _brown = Color(0xFF4F3C38);
  static const Color _muted = Color(0xFF89736F);
  static const Color _border = Color(0xFFEAD8DD);

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'مرحبًا 🌷 أنا مساعد NeuroBridge الذكي.\n\nيمكنني مساعدتك في فهم التطبيق، التمارين، متابعة التقدم واستخدام الميزات.\n\nكيف يمكنني مساعدتك اليوم؟',
      fromUser: false,
    ),
  ];

  bool _typing = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialQuestion != null &&
        widget.initialQuestion!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.text = widget.initialQuestion!;
        _sendMessage();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _typing) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: message,
          fromUser: true,
        ),
      );

      _controller.clear();
      _typing = true;
    });

    _scrollToBottom();

    await Future.delayed(
      const Duration(milliseconds: 850),
    );

    if (!mounted) return;

    final reply = _generateDemoReply(message);

    setState(() {
      _messages.add(
        _ChatMessage(
          text: reply,
          fromUser: false,
        ),
      );

      _typing = false;
    });

    _scrollToBottom();
  }

  String _generateDemoReply(String question) {
    final q = question.toLowerCase();

    if (q.contains('تمرين') ||
        q.contains('exercise')) {
      return 'يمكنك الوصول إلى التمارين من تبويب "التمارين" في أسفل التطبيق. اختر التمرين المناسب ثم اضغط "ابدأ الآن". 🧠\n\nابدأ بخطوات قصيرة ومريحة واتبع توصيات فريق الرعاية.';
    }

    if (q.contains('تقدم') ||
        q.contains('تقدّم') ||
        q.contains('progress')) {
      return 'من صفحة "تقدّمي" يمكنك مشاهدة الجلسات المكتملة، وقت التدريب، النشاط الأسبوعي والإنجازات التي حققتها. 📈';
    }

    if (q.contains('عائلة') ||
        q.contains('مرافق') ||
        q.contains('family')) {
      return 'قسم العائلة مخصص لربط المريض بالأشخاص الداعمين له. لاحقًا سيتمكن المرافق من متابعة المعلومات المسموح بها وإرسال رسائل تشجيع ومتابعة المواعيد. 👨‍👩‍👦';
    }

    if (q.contains('كلمة المرور') ||
        q.contains('password')) {
      return 'إذا نسيت كلمة المرور، اضغط "نسيت كلمة المرور؟" في شاشة تسجيل الدخول، ثم اتبع خطوات رمز التحقق وإنشاء كلمة مرور جديدة.';
    }

    if (q.contains('لغة') ||
        q.contains('language')) {
      return 'يمكنك تغيير اللغة من زر 🌐 الموجود في واجهات التطبيق. NeuroBridge يدعم العربية والإنجليزية والفرنسية والإسبانية والألمانية.';
    }

    if (q.contains('تشخيص') ||
        q.contains('مرض') ||
        q.contains('طبي') ||
        q.contains('diagnosis')) {
      return 'NeuroBridge لا يقدم تشخيصًا طبيًا. التطبيق مصمم لدعم التأهيل والمتابعة فقط، وأي قرار متعلق بحالتك الصحية يجب مناقشته مع الطبيب أو المختص.';
    }

    if (q.contains('حساب') ||
        q.contains('account')) {
      return 'يوجد نوعان أساسيان للحساب: حساب المريض وحساب المرافق/فرد العائلة. كل نوع يحصل على واجهة وصلاحيات تناسب دوره.';
    }

    if (q.contains('مساعدة') ||
        q.contains('help')) {
      return 'يمكنني مساعدتك في:\n\n• استخدام التمارين\n• متابعة التقدم\n• الحساب وتسجيل الدخول\n• ربط العائلة\n• تغيير اللغة\n• شرح ميزات NeuroBridge\n\nاكتب سؤالك بشكل طبيعي وسأحاول مساعدتك. ✨';
    }

    return 'فهمت سؤالك 🌷\n\nأنا الآن في النسخة التجريبية للـFrontend، لذلك ردودي محددة مسبقًا. عند ربط NeuroBridge بالـAI الحقيقي والـBackend سأتمكن من فهم أسئلة أكثر والرد عليها بشكل أذكى.\n\nجرب أن تسألني عن التمارين، التقدم، العائلة، الحساب أو استخدام التطبيق.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: AuthBackground(
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                _buildDisclaimer(),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      15,
                    ),
                    itemCount:
                        _messages.length + (_typing ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (_typing &&
                          index == _messages.length) {
                        return const _TypingBubble();
                      }

                      return _MessageBubble(
                        message: _messages[index],
                      );
                    },
                  ),
                ),

                _buildSuggestions(),

                _buildInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        15,
        10,
        15,
        12,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
          ),

          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE7ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: _rose,
            ),
          ),

          const SizedBox(width: 11),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NeuroBridge AI',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _brown,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: Color(0xFF77A98B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'مساعد ذكي • متاح',
                      style: TextStyle(
                        fontSize: 11,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                _messages
                  ..clear()
                  ..add(
                    const _ChatMessage(
                      text:
                          'بدأنا محادثة جديدة 🌷 كيف يمكنني مساعدتك؟',
                      fromUser: false,
                    ),
                  );
              });
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: _rose,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 17,
      ),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFEACDD4),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: _rose,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'المساعد لدعم استخدام التطبيق وليس للتشخيص الطبي.',
              style: TextStyle(
                fontSize: 11,
                color: _muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 43,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        children: [
          _SuggestionChip(
            text: 'كيف أبدأ تمرين؟',
            onTap: () {
              _controller.text = 'كيف أبدأ تمرين؟';
              _sendMessage();
            },
          ),
          _SuggestionChip(
            text: 'كيف أتابع تقدمي؟',
            onTap: () {
              _controller.text = 'كيف أتابع تقدمي؟';
              _sendMessage();
            },
          ),
          _SuggestionChip(
            text: 'كيف أربط العائلة؟',
            onTap: () {
              _controller.text = 'كيف أربط العائلة؟';
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        10,
        14,
        16,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'اكتب سؤالك هنا...',
                filled: true,
                fillColor:
                    Colors.white.withValues(alpha: .90),
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide:
                      const BorderSide(color: _border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide:
                      const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: const BorderSide(
                    color: _rose,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          SizedBox(
            width: 51,
            height: 51,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: _rose,
                shape: const CircleBorder(),
              ),
              onPressed: _typing ? null : _sendMessage,
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.fromUser
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 440,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: message.fromUser
              ? const Color(0xFFB87585)
              : Colors.white.withValues(alpha: .88),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(
              message.fromUser ? 5 : 20,
            ),
            bottomRight: Radius.circular(
              message.fromUser ? 20 : 5,
            ),
          ),
          border: message.fromUser
              ? null
              : Border.all(
                  color: const Color(0xFFEAD8DD),
                ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 13,
            height: 1.7,
            color: message.fromUser
                ? Colors.white
                : const Color(0xFF5F4B47),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEAD8DD),
          ),
        ),
        child: const Text(
          'NeuroBridge AI يكتب... ✨',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF89736F),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ActionChip(
        onPressed: onTap,
        backgroundColor: const Color(0xFFFFEEF2),
        side: const BorderSide(
          color: Color(0xFFE6CBD2),
        ),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF95606D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool fromUser;

  const _ChatMessage({
    required this.text,
    required this.fromUser,
  });
}