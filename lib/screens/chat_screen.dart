import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class ChatScreen extends StatefulWidget {
  final String propertyId;
  final String propertyTitle;
  final String otherUserId;
  final String otherUserName;
  const ChatScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  static const quickMsgs = [
    'هل العقار متوفر لسه؟',
    'هل السعر قابل للتفاوض؟',
    'حاب أحدد موعد معاينة',
    'ممكن ترسللي الموقع بالضبط؟',
    'شو شروط الإيجار؟',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await SupabaseService.fetchThread(widget.propertyId, widget.otherUserId);
      setState(() { _messages = list; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();
    await SupabaseService.sendMessage(receiverId: widget.otherUserId, propertyId: widget.propertyId, body: text.trim());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final myId = SupabaseService.currentUser?.id;
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.otherUserName, style: const TextStyle(fontSize: 15)),
          Text(widget.propertyTitle, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      )),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('ابدأ المحادثة — جرب سؤال جاهز تحت 👇', style: TextStyle(color: AppColors.muted)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final m = _messages[i];
                          final mine = m['sender_id'] == myId;
                          return Align(
                            alignment: mine ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: mine ? AppColors.orange : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: mine ? null : Border.all(color: AppColors.bluePale),
                              ),
                              child: Text(m['body'] ?? '', style: TextStyle(color: mine ? Colors.white : AppColors.ink)),
                            ),
                          );
                        },
                      ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: quickMsgs.map((q) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(label: Text(q, style: const TextStyle(fontSize: 12)), onPressed: () => _send(q)),
                  )).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    decoration: const InputDecoration(hintText: 'اكتب رسالة...', filled: true, fillColor: Colors.white),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.orange,
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: () => _send(_inputCtrl.text)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
