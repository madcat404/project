
import 'package:flutter/material.dart';

class CashManagementScreen extends StatefulWidget {
  const CashManagementScreen({super.key});

  @override
  State<CashManagementScreen> createState() => _CashManagementScreenState();
}

class _CashManagementScreenState extends State<CashManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('캐시 관리'),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 24),
            _buildConnectedAccounts(),
            const SizedBox(height: 24),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('브라더 머니', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('1,234,567원', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('충전', style: TextStyle(color: Colors.white)))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black54, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('인출'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedAccounts() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('연결된 계좌', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildAccountTile('KB국민은행', '••••1234'),
            const Divider(height: 24),
            _buildAccountTile('신한은행', '••••5678'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountTile(String bankName, String accountNumber) {
    return Row(
      children: [
        Icon(Icons.account_balance, color: Colors.grey[400], size: 36),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bankName, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(accountNumber, style: const TextStyle(color: Colors.grey)),
          ],
        )
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('이용 내역', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black54,
      indicator: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: '전체'),
        Tab(text: '입금'),
        Tab(text: '출금'),
      ],
    );
  }

  Widget _buildTransactionList() {
    // Dummy data
    final transactions = [
      {'title': '월세 입금 - 301호 홍길동', 'date': '4월 15일', 'amount': '+550,000원', 'is_deposit': true},
      {'title': '관리비 출금', 'date': '4월 10일', 'amount': '-120,000원', 'is_deposit': false},
      {'title': '계좌 충전', 'date': '4월 1일', 'amount': '+1,000,000원', 'is_deposit': true},
      {'title': '월세 입금 - 202호 이영희', 'date': '3월 31일', 'amount': '+450,000원', 'is_deposit': true},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(tx['date'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Text(
                tx['amount'] as String,
                style: TextStyle(
                  color: tx['is_deposit'] as bool ? Colors.blue : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
