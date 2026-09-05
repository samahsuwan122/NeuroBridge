import 'package:flutter/material.dart';

import '../../core/services/gemini_assistant_service.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/app_colors.dart';

class AiAssistantOverlay extends StatefulWidget {
  final Widget child;
  final Map<String, dynamic>? user;

  const AiAssistantOverlay({
    super.key,
    required this.child,
    this.user,
  });

  @override
  State<AiAssistantOverlay> createState() => _AiAssistantOverlayState();
}

class _AiMessage {
  final String role;
  final String text;
  const _AiMessage(this.role, this.text);
}

class _AiAssistantOverlayState extends State<AiAssistantOverlay> {
  final controller = TextEditingController();
  final scrollController = ScrollController();
  final messages = <_AiMessage>[];
  bool open = false;
  bool sending = false;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    if (currentUser == null) _loadUser();
  }

  Future<void> _loadUser() async {
    final loaded = await SessionService.getUser();
    if (mounted) setState(() => currentUser = loaded);
  }

  bool get isArabic {
    final value = currentUser?['preferred_language']?.toString().toLowerCase();
    return value == null || value == '' || value == 'ar';
  }

  bool get isFamily {
    final role = currentUser?['role']?.toString().toLowerCase() ?? '';
    return role == 'caregiver' || role == 'family';
  }

  String get welcome => isArabic
      ? isFamily
          ? 'أهلًا! أنا مساعد NeuroBridge. يمكنني مساعدتك في فهم معلومات الرعاية وإعداد رسائل داعمة.'
          : 'أهلًا! أنا مساعد NeuroBridge. اسألني عن التمارين والعادات الصحية والمعلومات العامة.'
      : isFamily
          ? 'Hello! I am the NeuroBridge assistant. I can help explain care information and draft supportive messages.'
          : 'Hello! I am the NeuroBridge assistant. Ask me about exercises, healthy habits, and general information.';

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      open = !open;
      if (open && messages.isEmpty) messages.add(_AiMessage('assistant', welcome));
    });
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty || sending) return;
    controller.clear();
    setState(() {
      messages.add(_AiMessage('user', text));
      sending = true;
    });
    _scrollDown();
    try {
      final history = messages
          .take(messages.length - 1)
          .map((message) => {'role': message.role, 'text': message.text})
          .toList();
      final answer = await GeminiAssistantService.send(
        message: text,
        history: history,
      );
      if (mounted) setState(() => messages.add(_AiMessage('assistant', answer)));
    } catch (exception) {
      if (mounted) {
        setState(() => messages.add(_AiMessage(
          'assistant',
          exception.toString().replaceFirst('Exception: ', ''),
        )));
      }
    } finally {
      if (mounted) setState(() => sending = false);
      _scrollDown();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = currentUser?['role']?.toString().toLowerCase() ?? '';
    final allowed = role == 'patient' || role == 'caregiver' || role == 'family';
    if (!allowed) return widget.child;
    final rtl = isArabic;
    final size = MediaQuery.sizeOf(context);
    final panelWidth = size.width < 520 ? size.width - 24 : 430.0;
    final panelHeight = size.height < 700 ? size.height * .76 : 590.0;
    return Directionality(
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          if (open)
            Positioned(
              right: 16,
              bottom: 88,
              child: Material(
                elevation: 24,
                color: Colors.transparent,
                child: Container(
                  width: panelWidth,
                  height: panelHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: .7)),
                  ),
                  child: Column(children: [
                    _header(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                      color: AppColors.secondary.withValues(alpha: .12),
                      child: Text(
                        rtl
                            ? 'معلومات عامة فقط؛ لا يستبدل الطبيب أو المعالج.'
                            : 'General guidance only; it does not replace your doctor or therapist.',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(14),
                        itemCount: messages.length + (sending ? 1 : 0),
                        itemBuilder: (_, index) {
                          if (index == messages.length) return _thinking();
                          return _bubble(messages[index]);
                        },
                      ),
                    ),
                    _composer(),
                  ]),
                ),
              ),
            ),
          Positioned(
            right: 18,
            bottom: 18,
            child: FloatingActionButton.extended(
              heroTag: 'neurobridge-global-ai',
              onPressed: toggle,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: Icon(open ? Icons.close_rounded : Icons.smart_toy_outlined),
              label: Text(open ? (rtl ? 'إغلاق' : 'Close') : 'NeuroBridge AI'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Container(
    padding: const EdgeInsets.all(15),
    color: AppColors.primary,
    child: Row(children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .14), shape: BoxShape.circle),
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
      ),
      const SizedBox(width: 11),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NeuroBridge Assistant', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
        Text('● Online • Gemini', style: TextStyle(color: Color(0xFFDDE8C9), fontSize: 11)),
      ])),
      IconButton(onPressed: toggle, icon: const Icon(Icons.close, color: Colors.white)),
    ]),
  );

  Widget _bubble(_AiMessage message) {
    final mine = message.role == 'user';
    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: mine ? AppColors.secondary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(17),
        ),
        child: SelectableText(message.text, style: TextStyle(height: 1.55, color: mine ? AppColors.textPrimary : null)),
      ),
    );
  }

  Widget _thinking() => const Align(
    alignment: AlignmentDirectional.centerStart,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );

  Widget _composer() => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => send(),
            decoration: InputDecoration(
              hintText: isArabic ? 'اكتب رسالتك...' : 'Type your message...',
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: sending ? null : send,
          icon: const Icon(Icons.send_rounded),
        ),
      ]),
    ),
  );
}
