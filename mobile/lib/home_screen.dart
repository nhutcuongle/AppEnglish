import 'package:flutter/material.dart';
import 'unit_detail_screen.dart';
import 'translate_screen.dart';
import 'profile_screen.dart';
import 'models/unit_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Hàm chuyển tab
  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color is handled by theme
      body: SafeArea(
        child: Column(
          children: [
            // Chỉ hiển thị Header chung khi KHÔNG phải là trang Dashboard (0) và KHÔNG phải trang Cá nhân (3)
            if (_selectedIndex != 0 && _selectedIndex != 3) _buildCommonHeader(),

            Expanded(
              child: _buildBodyContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Bài học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate_outlined),
            activeIcon: Icon(Icons.translate),
            label: 'Dịch thuật',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard(); 
      case 1:
        return _buildUnitList(); 
      case 2:
        return const TranslateScreen(); 
      case 3:
        return const ProfileScreen(); 
      default:
        return _buildDashboard();
    }
  }

  // --- DASHBOARD ---
  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDashboardHeader(),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBanner(),
                
                SizedBox(height: 24),
                
                // Big Feature Cards
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                           // Logic: Tiếp tục học -> Chuyển sang Unit 2
                           Navigator.push(context, MaterialPageRoute(builder: (context) => const UnitDetailScreen(unitName: "Unit 2", unitTitle: "Humans and the Environment")));
                        },
                        child: _buildBigFeatureCard(
                          title: "Tiếp tục học",
                          subtitle: "Unit 2: Environment",
                          icon: Icons.play_circle_fill,
                          color: Colors.blue,
                          bgColor: Colors.blue.shade50,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng Ôn tập đang được phát triển!")));
                        },
                        child: _buildBigFeatureCard(
                          title: "Ôn tập nhanh",
                          subtitle: "Quiz & Flashcard",
                          icon: Icons.quiz,
                          color: Colors.orange,
                          bgColor: Colors.orange.shade50,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Skills Grid
                Text(
                  "Rèn luyện kỹ năng",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                  children: [
                    _buildCircleIconBtn(Icons.headset, "Nghe", Colors.orange),
                    _buildCircleIconBtn(Icons.mic, "Nói", Colors.purple),
                    _buildCircleIconBtn(Icons.menu_book, "Đọc", Colors.green),
                    _buildCircleIconBtn(Icons.edit, "Viết", Colors.teal),
                    _buildCircleIconBtn(Icons.book, "Từ vựng", Colors.blue),
                    _buildCircleIconBtn(Icons.rule, "Ngữ pháp", Colors.red),
                    _buildCircleIconBtn(Icons.videocam, "Video", Colors.pink),
                    // Nút "Tất cả" -> Chuyển sang tab Bài học
                    GestureDetector(
                      onTap: () => _navigateToTab(1),
                      child: _buildCircleIconBtn(Icons.grid_view, "Tất cả", Colors.indigo)
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Recent Activity Card
                 Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.history, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lần học gần nhất", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text("Unit 1: Family Life", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Spacer(),
                      CircularProgressIndicator(
                        value: 0.8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade50,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=33"), // Placeholder
            onBackgroundImageError: (_, __) => {}, 
            child: Icon(Icons.person, color: Colors.blue),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Xin chào,", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                Text("Học sinh Lớp 10", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          IconButton(
            onPressed: (){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bạn không có thông báo mới.")));
            }, 
            icon: Icon(Icons.notifications_outlined, color: Colors.grey[800], size: 28)
          )
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -30, child: Icon(Icons.school, size: 180, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      SizedBox(width: 4),
                      Text("WORD OF THE DAY", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Spacer(),
                Text("Perseverance", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                SizedBox(height: 6),
                Text("/ˌpɜː.sɪˈvɪə.rəns/ • (n) Sự kiên trì", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigFeatureCard({required String title, required String subtitle, required IconData icon, required Color color, required Color bgColor}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCircleIconBtn(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w500), textAlign: TextAlign.center, maxLines: 1),
      ],
    );
  }

  Widget _buildCommonHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Tiếng Anh 10", 
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
            )
          ),
          CircleAvatar(
             radius: 18,
             backgroundColor: Colors.white.withOpacity(0.2), 
             child: Icon(Icons.person, color: Colors.white, size: 20),
          )
        ],
      ),
    );
  }

  Widget _buildUnitList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: mockUnits.length,
      itemBuilder: (context, index) {
        final unit = mockUnits[index];
        int progressPercent = (unit.progress * 100).toInt();

        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UnitDetailScreen(unitName: unit.name, unitTitle: unit.title)));
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: Text("${index + 1}", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 24))),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(unit.name, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600], fontSize: 13)),
                            SizedBox(height: 4),
                            Text(unit.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400]),
                    ],
                  ),
                  // ĐÃ SỬA: Luôn hiển thị thanh tiến độ
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tiến độ", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          Text("$progressPercent%", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: unit.progress > 0 ? Theme.of(context).primaryColor : Colors.grey)),
                        ],
                      ),
                      SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: unit.progress, 
                          backgroundColor: Colors.grey[200], 
                          valueColor: AlwaysStoppedAnimation<Color>(unit.progress == 1.0 ? Colors.green : Theme.of(context).primaryColor), 
                          minHeight: 6
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
