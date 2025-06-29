import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  bool isWeeklyPlan = false;
  DateTime focusedDay = DateTime.now();
  DateTime? startOfWeek;
  int currentDayIndex = 0;

  String? selectedMealType;
  final Map<String, List<String>> mealOptions = {
    'Breakfast': ['Poha', 'Dosa', 'Idli'],
    'Mid-day Meal': ['Dal Rice', 'Chapati Sabzi', 'Paneer Wrap'],
    'Snacks': ['Fruits', 'Chana Chaat', 'Peanut Bar'],
    'Dinner': ['Veg Khichdi', 'Roti Curry', 'Soup & Salad'],
  };

  void pickWeekStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: focusedDay,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        startOfWeek = picked;
        currentDayIndex = 0;
        selectedMealType = null;
      });
    }
  }

  String getCurrentWeekdayLabel() {
    if (startOfWeek == null) return '';
    DateTime current = startOfWeek!.add(Duration(days: currentDayIndex));
    return '${current.weekday == 7 ? "Sunday" : "${["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"][current.weekday - 1]}"} (${current.day}/${current.month})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meal Planner',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2035),
              focusedDay: focusedDay,
              calendarFormat: CalendarFormat.week,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  this.focusedDay = focusedDay;
                });
              },
              selectedDayPredicate: (day) {
                return isSameDay(day, focusedDay);
              },
            ),
            const SizedBox(height: 20),

            // Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ChoiceChip(
                  label: const Text("Day Plan"),
                  selected: !isWeeklyPlan,
                  onSelected: (_) => setState(() => isWeeklyPlan = false),
                ),
                ChoiceChip(
                  label: const Text("Weekly Plan"),
                  selected: isWeeklyPlan,
                  onSelected: (_) => setState(() {
                    isWeeklyPlan = true;
                    pickWeekStartDate();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Planner view
            Expanded(
              child: isWeeklyPlan && startOfWeek != null
                  ? buildWeeklyPlanner()
                  : buildDayPlanner(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWeeklyPlanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planning: ${getCurrentWeekdayLabel()}',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: ['Breakfast', 'Mid-day Meal', 'Snacks', 'Dinner']
              .map((meal) => ChoiceChip(
                    label: Text(meal),
                    selected: selectedMealType == meal,
                    onSelected: (_) => setState(() => selectedMealType = meal),
                  ))
              .toList(),
        ),
        const SizedBox(height: 20),
        if (selectedMealType != null)
          ...mealOptions[selectedMealType]!.map(
            (food) => ListTile(
              title: Text(food),
              leading: const Icon(Icons.restaurant_menu),
            ),
          ),

        const Spacer(),
        ElevatedButton(
          onPressed: () {
            if (currentDayIndex < 6) {
              setState(() {
                currentDayIndex += 1;
                selectedMealType = null;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Week planning complete!")),
              );
            }
          },
          child: Text(currentDayIndex < 6 ? 'Next Day' : 'Finish'),
        )
      ],
    );
  }

  Widget buildDayPlanner() {
    return Column(
      children: [
        const Icon(Icons.fastfood, size: 80, color: Colors.grey),
        const SizedBox(height: 10),
        Text(
          'Today: ${focusedDay.day}/${focusedDay.month}/${focusedDay.year}',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: ['Breakfast', 'Mid-day Meal', 'Snacks', 'Dinner']
              .map((meal) => ChoiceChip(
                    label: Text(meal),
                    selected: selectedMealType == meal,
                    onSelected: (_) => setState(() => selectedMealType = meal),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        if (selectedMealType != null)
          ...mealOptions[selectedMealType]!.map(
            (food) => ListTile(
              title: Text(food),
              leading: const Icon(Icons.restaurant_menu),
            ),
          ),
      ],
    );
  }
}
