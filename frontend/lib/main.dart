import 'package:flutter/material.dart';

void main() {
  runApp(const MoodApp());
}

enum Mood{
  happy,
  relaxed,
  neutral,
  sad,
  angry,
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'MoodApp Home Page'),
    );
  }
}

 Color get color {
    switch (this) {
      case Mood.happy:
        return Colors.yellow.shade100;
      case Mood.relaxed:
        return Colors.lightGreen.shade100;
      case Mood.neutral:
        return Colors.blueGrey.shade50;
      case Mood.sad:
        return Colors.blue.shade100;
      case Mood.angry:
        return Colors.red.shade100;
    }
  }

class MoodEntry {
  final String id; // Unique ID for each entry
  Mood mood;
  String notes;
  double energyLevel; 
  DateTime date;
}

MoodEntry({
    required this.mood,
    required this.notes,
    required this.energyLevel,
    required this.date,
    String? id, // Optional ID for existing entries
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(); // Generate unique ID using timestamp


  MoodEntry copyWith({
    Mood? mood,
    String? notes,
    double? energyLevel,
    DateTime? date,
  })

  void addEntry(MoodEntry entry) {
    _entries.add(entry);
    _entries.sort((a, b) => b.date.compareTo(a.date)); // Keep sorted
    notifyListeners();
  }

  void updateEntry(MoodEntry updatedEntry) {
    final int index = _entries.indexWhere((MoodEntry entry) => entry.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

class MoodApp extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  Widget build(Build Context context){
    title : MoodApp
  }

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MoodEntryCard extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {

      _counter++;
    });
  }


  @override
  Widget build(BuildContext context) {
    final String formattedDate = "${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2,'0')}/${entry.date.year}";

    final String shortNote = entry.notes.length > 100
        ? '${entry.notes.substring(0,100)}...'
        : entry.notes;


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      color: entry.mood.color, // Card color based on mood
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  entry.mood.icon,
                  size: 28,
                  color: Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.mood.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              shortNote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
              maxLines: 3, // Limit notes display to 3 lines
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "Energy: ${entry.energyLevel.toStringAsFixed(1)}/10",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


       
  
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
