//HARD CODE
import 'package:flutter/material.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD-001',
      'customerName': 'Ahmad Ali',
      'date': '2023-11-22',
      'status': 'New',
      'total': 'RM 150.00',
      'items': [
        {'name': 'Fresh Tomatoes', 'quantity': '2kg', 'price': 'RM 30.00'},
        {'name': 'Lettuce', 'quantity': '1kg', 'price': 'RM 20.00'},
        {'name': 'Carrots', 'quantity': '2kg', 'price': 'RM 25.00'},
        {'name': 'Cucumber', 'quantity': '1.5kg', 'price': 'RM 15.00'},
        {'name': 'Red Onions', 'quantity': '3kg', 'price': 'RM 60.00'},
      ]
    },
    {
      'id': 'ORD-002',
      'customerName': 'Sarah Wong',
      'date': '2023-11-21',
      'status': 'New',
      'total': 'RM 95.50',
      'items': [
        {'name': 'Spinach', 'quantity': '1kg', 'price': 'RM 18.00'},
        {'name': 'Bell Peppers', 'quantity': '1.5kg', 'price': 'RM 45.00'},
        {'name': 'Chili', 'quantity': '0.5kg', 'price': 'RM 32.50'},
      ]
    },
    {
      'id': 'ORD-003',
      'customerName': 'Raj Kumar',
      'date': '2023-11-20',
      'status': 'New',
      'total': 'RM 210.00',
      'items': [
        {'name': 'Potatoes', 'quantity': '5kg', 'price': 'RM 50.00'},
        {'name': 'Eggplant', 'quantity': '2kg', 'price': 'RM 32.00'},
        {'name': 'Cabbage', 'quantity': '3kg', 'price': 'RM 45.00'},
        {'name': 'Ginger', 'quantity': '1kg', 'price': 'RM 38.00'},
        {'name': 'Garlic', 'quantity': '1kg', 'price': 'RM 45.00'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'New Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(orders[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No new orders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New orders will appear here',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          'Order #${order['id']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Customer: ${order['customerName']}'),
            Text('Date: ${order['date']}'),
            Row(
              children: [
                Text('Status: '),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BC34A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'],
                    style: const TextStyle(
                      color: Color(0xFF689F38),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text('Total: ${order['total']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  order['items'].length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(order['items'][index]['name']),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(order['items'][index]['quantity']),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            order['items'][index]['price'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC34A),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Implement accept order logic
                        _showActionDialog('Accept', order['id']);
                      },
                      child: const Text('Accept'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Implement reject order logic
                        _showActionDialog('Reject', order['id']);
                      },
                      child: const Text('Reject'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () {
                        // Implement contact customer logic
                        // This could open a chat or call function
                      },
                      child: const Text('Contact'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(String action, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$action Order'),
          content: Text(
            'Are you sure you want to $action order #$orderId?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Implement actual order status change logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Order #$orderId has been ${action.toLowerCase()}ed'),
                    backgroundColor: action == 'Accept'
                        ? const Color(0xFF8BC34A)
                        : Colors.red[400],
                  ),
                );

                // Update the order in the list
                setState(() {
                  for (var i = 0; i < orders.length; i++) {
                    if (orders[i]['id'] == orderId) {
                      orders[i]['status'] =
                          action == 'Accept' ? 'Accepted' : 'Rejected';
                      break;
                    }
                  }
                });
              },
              child: Text(action),
            ),
          ],
        );
      },
    );
  }
}
