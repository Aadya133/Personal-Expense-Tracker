import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const ExpenseProApp());

class ExpenseProApp extends StatelessWidget {
  const ExpenseProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RupeeTracker Pro',
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.tealAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- MODELS ---
enum Category { food, travel, leisure, work, bills, shopping }

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}

// --- SHARED BRANDED HEADER ---
class AppHeader extends StatelessWidget {
  final String title;
  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.tealAccent,
            radius: 20,
            child: Icon(Icons.account_balance_wallet, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("RupeeTracker Pro", 
                style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isObscured = true;

  void _login() {
    if (_email.text.trim() == "admin@test.com" && _pass.text == "123456") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) => const MainNavigationContainer()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Try admin@test.com / 123456")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(Icons.account_balance_wallet, size: 80, color: Colors.tealAccent),
              const SizedBox(height: 10),
              const Text("RupeeTracker Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              TextField(
                controller: _pass,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
                onPressed: _login,
                child: const Text("ACCESS DASHBOARD", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MAIN NAVIGATION ---
class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _currentIndex = 0;
  final List<Expense> _allExpenses = [];

  void _addExpense(String t, double a, DateTime d, Category c) {
    setState(() => _allExpenses.add(Expense(id: DateTime.now().toString(), title: t, amount: a, date: d, category: c)));
  }

  void _deleteExpense(String id) {
    setState(() => _allExpenses.removeWhere((e) => e.id == id));
  }

  void _updateExpense(Expense updatedExpense) {
    setState(() {
      final index = _allExpenses.indexWhere((e) => e.id == updatedExpense.id);
      if (index != -1) _allExpenses[index] = updatedExpense;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(expenses: _allExpenses, onAdd: _addExpense),
      HistoryScreen(expenses: _allExpenses, onDelete: _deleteExpense, onUpdate: _updateExpense),
      StatsScreen(expenses: _allExpenses),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Logs'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Stats'),
        ],
      ),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatelessWidget {
  final List<Expense> expenses;
  final Function(String, double, DateTime, Category) onAdd;
  const HomeScreen({super.key, required this.expenses, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    double total = expenses.fold(0, (s, i) => s + i.amount);

    return Column(
      children: [
        const AppHeader(title: "Overview"),
        _buildBalanceCard(total),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Align(alignment: Alignment.centerLeft, child: Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
        Expanded(
          child: expenses.isEmpty 
            ? const Center(child: Text("No records yet.", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: expenses.length > 5 ? 5 : expenses.length,
                itemBuilder: (ctx, i) {
                  final e = expenses.reversed.toList()[i];
                  return ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.arrow_downward, color: Colors.redAccent, size: 16)),
                    title: Text(e.title),
                    subtitle: Text(DateFormat.yMMMd().format(e.date)),
                    trailing: Text("₹${e.amount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
            onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => ExpenseForm(onAdd: onAdd)),
            icon: const Icon(Icons.add),
            label: const Text("NEW EXPENSE"),
          ),
        )
      ],
    );
  }

  Widget _buildBalanceCard(double total) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("TOTAL EXPENSES", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
          Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

// --- LOGS SCREEN WITH FILTER ---
class HistoryScreen extends StatefulWidget {
  final List<Expense> expenses;
  final Function(String) onDelete;
  final Function(Expense) onUpdate;
  const HistoryScreen({super.key, required this.expenses, required this.onDelete, required this.onUpdate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Category? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedCategory == null 
        ? widget.expenses 
        : widget.expenses.where((e) => e.category == _selectedCategory).toList();

    return Column(
      children: [
        const AppHeader(title: "Logs"),
        
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text("All"),
                selected: _selectedCategory == null,
                onSelected: (s) => setState(() => _selectedCategory = null),
              ),
              ...Category.values.map((cat) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: ChoiceChip(
                  label: Text(cat.name.toUpperCase()),
                  selected: _selectedCategory == cat,
                  onSelected: (s) => setState(() => _selectedCategory = s ? cat : null),
                ),
              )),
            ],
          ),
        ),

        Expanded(
          child: filteredList.isEmpty 
              ? const Center(child: Text("No transactions found", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (ctx, i) {
                    final e = filteredList[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: ListTile(
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => ExpenseForm(
                            onAdd: (t, a, d, c) => widget.onUpdate(Expense(id: e.id, title: t, amount: a, date: d, category: c)),
                            existingExpense: e,
                          ),
                        ),
                        title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat.yMMMd().format(e.date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("₹${e.amount}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => widget.onDelete(e.id)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// --- STATS SCREEN WITH PIE CHART ---
class StatsScreen extends StatelessWidget {
  final List<Expense> expenses;
  const StatsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    Map<Category, double> data = {};
    for (var e in expenses) { data[e.category] = (data[e.category] ?? 0) + e.amount; }
    double total = expenses.fold(0, (s, i) => s + i.amount);

    return Column(
      children: [
        const AppHeader(title: "Analysis"),
        if (expenses.isEmpty) 
          const Expanded(child: Center(child: Text("Add data to see analysis")))
        else 
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: data.entries.map((e) {
                        return PieChartSectionData(
                          color: _getColor(e.key),
                          value: e.value,
                          title: '${((e.value / total) * 100).toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                ...data.entries.map((e) => _buildStatTile(e.key, e.value, total)),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildStatTile(Category cat, double value, double total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: _getColor(cat))),
              const SizedBox(width: 10),
              Text(cat.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Text("₹${value.toStringAsFixed(0)}", style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getColor(Category cat) {
    switch (cat) {
      case Category.food: return Colors.orangeAccent;
      case Category.travel: return Colors.blueAccent;
      case Category.leisure: return Colors.purpleAccent;
      case Category.work: return Colors.greenAccent;
      case Category.bills: return Colors.redAccent;
      case Category.shopping: return Colors.tealAccent;
    }
  }
}

// --- FORM ---
class ExpenseForm extends StatefulWidget {
  final Function(String, double, DateTime, Category) onAdd;
  final Expense? existingExpense;
  const ExpenseForm({super.key, required this.onAdd, this.existingExpense});
  @override State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _t = TextEditingController();
  final _a = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category _cat = Category.food;

  @override
  void initState() {
    super.initState();
    if (widget.existingExpense != null) {
      _t.text = widget.existingExpense!.title;
      _a.text = widget.existingExpense!.amount.toString();
      _selectedDate = widget.existingExpense!.date;
      _cat = widget.existingExpense!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.existingExpense == null ? "Record Expense" : "Edit Expense", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _t, decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _a, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Amount", prefixText: "₹ ", border: OutlineInputBorder())),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: Text("Date: ${DateFormat.yMd().format(_selectedDate)}")),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today, size: 18),
                label: const Text("Select Date"),
              ),
            ],
          ),
          DropdownButtonFormField<Category>(
            value: _cat,
            items: Category.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
            onChanged: (v) => setState(() => _cat = v!),
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Category"),
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55), backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
            onPressed: () {
              if (_t.text.isNotEmpty && _a.text.isNotEmpty) {
                widget.onAdd(_t.text, double.parse(_a.text), _selectedDate, _cat);
                Navigator.pop(context);
              }
            },
            child: const Text("SAVE TRANSACTION", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}