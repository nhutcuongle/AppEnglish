import 'package:flutter/material.dart';

class UnitDetailScreen extends StatefulWidget {
  final String unitName; // Ví dụ: "Unit 1"
  final String unitTitle; // Ví dụ: "Family Life"

  const UnitDetailScreen({
    super.key, 
    required this.unitName,
    required this.unitTitle,
  });

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu giả lập nội dung sách giáo khoa theo từng Unit (Demo 2 bài mẫu)
  final Map<String, Map<String, String>> _unitContent = {
    "Unit 1": {
      "topic": "Family Life",
      "dialogue_person_1": "Nam",
      "dialogue_text_1": "Hello, Minh. You look happy today. What's up?",
      "dialogue_person_2": "Minh",
      "dialogue_text_2": "Hi, Nam. Yes, I am. I got an A in English because I practiced every day.",
      "image_placeholder": "https://img.freepik.com/free-vector/happy-family-concept-illustration_114360-1845.jpg?w=740",
    },
    "Unit 2": {
      "topic": "Humans and the Environment",
      "dialogue_person_1": "Lan",
      "dialogue_text_1": "Look at the garbage here! People should protect the environment.",
      "dialogue_person_2": "Hoa",
      "dialogue_text_2": "I agree. We should adopt a greener lifestyle to reduce our carbon footprint.",
      "image_placeholder": "https://img.freepik.com/free-vector/people-taking-care-plants_23-2148508006.jpg?w=740",
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Lấy nội dung dựa trên unitName, nếu không có thì dùng nội dung mặc định
    final content = _unitContent[widget.unitName] ?? {
      "topic": widget.unitTitle,
      "dialogue_person_1": "Student A",
      "dialogue_text_1": "Welcome to ${widget.unitName}. Let's start learning new vocabulary.",
      "dialogue_person_2": "Student B",
      "dialogue_text_2": "Sure! I am ready to learn about ${widget.unitTitle}.",
      "image_placeholder": "https://img.freepik.com/free-vector/students-study-concept-illustration_114360-644.jpg?w=740",
    };

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.unitName, style: TextStyle(fontSize: 14, color: theme.colorScheme.onPrimary.withOpacity(0.8))),
            Text(widget.unitTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
          ],
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.6),
          indicatorColor: theme.colorScheme.secondary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.chrome_reader_mode), text: "Lý thuyết & SGK"),
            Tab(icon: Icon(Icons.play_lesson), text: "Video bài giảng"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Content Area (Book or Video)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookContent(theme, content),
                  _buildVideoContent(theme),
                ],
              ),
            ),
          ),
          
          Container(height: 8, color: Colors.grey[100]), // Spacer
          
          // Exercises Section
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(Icons.assignment_turned_in, color: theme.primaryColor),
                        SizedBox(width: 10),
                        Text(
                          "Bài tập thực hành",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor),
                        ),
                        Spacer(),
                        TextButton(onPressed: (){}, child: Text("Xem tất cả"))
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: 5,
                      separatorBuilder: (context, index) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text("${index + 1}", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                            ),
                            title: Text("Quiz ${index + 1}: ${widget.unitName}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text("Trắc nghiệm & Tự luận • 15 phút", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Đang mở bài tập ${index + 1} của ${widget.unitName}...")),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookContent(ThemeData theme, Map<String, String> content) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.blueGrey.shade50,
                  child: Image.network(
                    content["image_placeholder"]!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.image, size: 60, color: Colors.grey.shade300),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                  child: Text(
                    "Getting Started: ${content["topic"]}",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Reading Section
          Row(
            children: [
              Icon(Icons.headphones, size: 20, color: theme.primaryColor),
              SizedBox(width: 8),
              Text("Listen and read", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          SizedBox(height: 12),
          
          // Dialogue Box
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
                children: [
                  TextSpan(text: "${content["dialogue_person_1"]}: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800])),
                  TextSpan(text: "${content["dialogue_text_1"]}\n\n"),
                  TextSpan(text: "${content["dialogue_person_2"]}: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                  TextSpan(text: "${content["dialogue_text_2"]}"),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 20),
          // Vocabulary Hint
           Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[800], size: 20),
                SizedBox(width: 10),
                Expanded(child: Text("Tip: Chạm vào từ mới để xem nghĩa và cách phát âm.", style: TextStyle(fontSize: 13, color: Colors.brown[700]))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVideoContent(ThemeData theme) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.3,
            child: Container(color: Colors.grey[900]),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.play_arrow_rounded, size: 48, color: Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                "Video bài giảng ${widget.unitName}",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
