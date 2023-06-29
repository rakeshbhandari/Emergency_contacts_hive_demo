import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('contact_box');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Demo",
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

//everything is stored here => _items and this list will get data from _contactBox
  List<Map<String, dynamic>> _items = [];

  //creating a ref of hive box for the above
  final _contactBox = Hive.box('contact_box');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    final data = _contactBox.keys.map((key) {
      final item = _contactBox.get(key);
      return {
        "key": key,
        "name": item["name"],
        "number": item["number"],
        "email": item["email"]
      };
    }).toList();

    setState(() {
      _items = data.reversed.toList();
      print(_items.length);
    });
  }

  //create new item
  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _contactBox.add(newItem); //0,1,2,3
    _refreshItems();
  }

//update the items
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _contactBox.put(itemKey, item);
    _refreshItems();
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contact Updated Successfully")));
  }

//deleting the list
  Future<void> _deleteItem(int itemKey) async {
    await _contactBox.delete(itemKey);
    _refreshItems();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Contact Deleted Successfully"),
      elevation: BorderSide.strokeAlignOutside,
      // width: 280.0, // Width of the SnackBar.
      // padding: EdgeInsets.symmetric(
      //   horizontal: 14.0, // Inner padding for SnackBar content.
      // ),
      // behavior: SnackBarBehavior.floating,
    ));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _numberController.text = existingItem['number'];
      // _emailController.text = existingItem['email'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 8,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Full Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Phone Number'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (itemKey == null) {
                        _createItem({
                          "name": _nameController.text,
                          "number": _numberController.text,
                          // "email": _emailController.text,
                        });
                      }

                      if (itemKey != null) {
                        _updateItem(itemKey, {
                          'name': _nameController.text.trim(),
                          'number': _numberController.text.trim(),
                        });
                      }

                      _nameController.text = '';
                      _numberController.text = '';
                      // _emailController.text = '';

                      Navigator.of(context).pop();
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update'),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Emergency Contacts '),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, index) {
              final currentItem = _items[index];
              return Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.all(11),
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(currentItem['name']),
                  subtitle: Text(currentItem['number']),
                  // user: Text(currentItem['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_sharp),
                        onPressed: () => _showForm(context, currentItem['key']),
                      ),
                      IconButton(
                          onPressed: () => _deleteItem(currentItem['key']),
                          icon: const Icon(Icons.delete_outline_rounded))
                    ],
                  ),
                ),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(context, null),
          child: const Icon(Icons.add_circle_sharp),
        ));
  }
}
