import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    // Simulate API call
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _events = [
          Event(
            id: '1',
            name: 'Campus Orientation',
            type: 'Academic',
            description: 'Welcome event for new students',
            location: 'Main Auditorium',
            startTime: DateTime.now().add(Duration(days: 1)),
            endTime: DateTime.now().add(Duration(days: 1, hours: 3)),
          ),
          Event(
            id: '2',
            name: 'Tech Conference 2024',
            type: 'Workshop',
            description: 'Annual technology and innovation conference',
            location: 'Tech Building',
            startTime: DateTime.now().add(Duration(days: 3)),
            endTime: DateTime.now().add(Duration(days: 3, hours: 6)),
          ),
          Event(
            id: '3',
            name: 'Sports Festival',
            type: 'Sports',
            description: 'Inter-department sports competition',
            location: 'University Stadium',
            startTime: DateTime.now().add(Duration(days: 5)),
            endTime: DateTime.now().add(Duration(days: 7)),
          ),
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Events Available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check back later for upcoming events',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return _buildEventCard(_events[index]);
                  },
                ),
      floatingActionButton: (user?.role == 'admin' || user?.role == 'superadmin')
          ? FloatingActionButton(
              onPressed: () {
                _showCreateEventDialog(context);
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEventTypeColor(event.type),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.type,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                Spacer(),
                Icon(Icons.event, color: Colors.grey),
              ],
            ),
            SizedBox(height: 12),
            Text(
              event.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              event.description,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(event.location, style: TextStyle(fontSize: 14)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${_formatDate(event.startTime)} - ${_formatTime(event.startTime)}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showEventDetails(event);
                    },
                    child: Text('View Details'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _registerForEvent(event);
                    },
                    child: Text('Register'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'workshop':
        return Colors.green;
      case 'sports':
        return Colors.orange;
      case 'social':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(event.description),
              SizedBox(height: 16),
              Text('Type: ${event.type}'),
              Text('Location: ${event.location}'),
              Text('Date: ${_formatDate(event.startTime)}'),
              Text('Time: ${_formatTime(event.startTime)}'),
              Text('Duration: ${event.endTime.difference(event.startTime).inHours} hours'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _registerForEvent(event);
            },
            child: Text('Register'),
          ),
        ],
      ),
    );
  }

  void _registerForEvent(Event event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registered for ${event.name}')),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Event'),
        content: Text('Event creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String id;
  final String name;
  final String type;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
  });
}