import '../create_habit/create_habit_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../data/models/journal.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<JournalProvider>().fetchJournals();
    });
  }

  void _showJournalEditor({Journal? journal}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final titleController = TextEditingController(text: journal?.title);
    final contentController = TextEditingController(text: journal?.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  journal == null ? "New Entry" : "Edit Entry",
                  style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    if (contentController.text.isNotEmpty) {
                      if (journal == null) {
                        context.read<JournalProvider>().addJournal(
                          contentController.text,
                          title: titleController.text.isEmpty ? null : titleController.text,
                        );
                      } else {
                        context.read<JournalProvider>().updateJournal(
                          journal.copyWith(
                            title: titleController.text,
                            content: contentController.text,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Title (Optional)",
                border: InputBorder.none,
                hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "How's your day going? Write your thoughts...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 16),
                ),
                style: TextStyle(color: textColor, fontSize: 16, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87, size: 20),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          "Personal Journal",
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<JournalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.journals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("✍️", style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 16),
                  Text(
                    "Start your first journal entry",
                    style: TextStyle(color: isDark ? Colors.white38 : Colors.black26, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _showJournalEditor(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Create Entry", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.journals.length,
            itemBuilder: (context, index) {
              final journal = provider.journals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Theme.of(context).cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                ),
                child: InkWell(
                  onTap: () => _showJournalEditor(journal: journal),
                  onLongPress: () => _showDeleteDialog(journal.id!),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM d, yyyy • h:mm a').format(journal.createdAt),
                              style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (journal.title != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            journal.title!,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          journal.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateHabitScreen())),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  void _showDeleteDialog(int id) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         backgroundColor: Theme.of(context).cardColor,
         title: const Text("Delete Entry?", style: TextStyle(color: Colors.redAccent)),
         content: const Text("Are you sure you want to permanently delete this memory?", style: TextStyle(color: Colors.grey)),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
           TextButton(
             onPressed: () {
               context.read<JournalProvider>().deleteJournal(id);
               Navigator.pop(context);
             }, 
             child: const Text("Delete", style: TextStyle(color: Colors.redAccent))
           ),
         ],
       ),
     );
  }
}
