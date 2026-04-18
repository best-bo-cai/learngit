// lib/features/chat/chat_screen.dart
import 'package:flutter/material.dart';
import '../../core/services/chat_service.dart';
import '../../core/models/message.dart';

/// 聊天界面（MVP 版本）
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isInitialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await _chatService.initialize();
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('初始化失败：$e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _chatService.isGenerating) return;

    _inputController.clear();
    
    try {
      final stream = _chatService.sendMessage(text);
      
      setState(() {}); // 触发 UI 更新
      
      // 监听流式输出
      await for (final token in stream) {
        setState(() {}); // 实时更新 UI
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败：$e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _clearHistory() {
    _chatService.clearHistory();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EdgeMind AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _chatService.messageHistory.isNotEmpty ? _clearHistory : null,
            tooltip: '清除对话',
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _buildMessageList(),
          ),
          
          // 输入区域
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _chatService.messageHistory;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在初始化 AI 引擎...'),
          ],
        ),
      );
    }

    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '开始与 AI 对话吧！',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '完全离线 · 隐私安全 · 零流量消耗',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == MessageRole.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.smart_toy, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  if (message.isStreaming) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUser ? Colors.white : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.person, color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                maxLines: 1,
                onSubmitted: (_) => _sendMessage(),
                enabled: !_chatService.isGenerating,
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              child: IconButton(
                icon: Icon(
                  _chatService.isGenerating ? Icons.stop : Icons.send,
                  color: Colors.white,
                ),
                onPressed: _chatService.isGenerating ? null : _sendMessage,
                tooltip: _chatService.isGenerating ? '生成中...' : '发送',
              ),
              backgroundColor: _chatService.isGenerating ? Colors.grey : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
