
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F4_DanhBa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0468D7),
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ContactListPage(),
      routes: {
        AboutPage.routeName: (context) => const AboutPage(),
      },
    );
  }
}

// MODEL LIEN HE
class Contact {
  final String hoTen;
  final String dienThoai;
  final String email;

  const Contact({
    required this.hoTen,
    required this.dienThoai,
    this.email = '',
  });

  Contact copyWith({
    String? hoTen,
    String? dienThoai,
    String? email,
  }) {
    return Contact(
      hoTen: hoTen ?? this.hoTen,
      dienThoai: dienThoai ?? this.dienThoai,
      email: email ?? this.email,
    );
  }
}

enum DetailAction { updated, deleted }

class DetailResult {
  final DetailAction action;
  final Contact? contact;

  const DetailResult(this.action, [this.contact]);
}

// MAN HINH 1: DANH BA
class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  final List<Contact> _danhBa = [
    const Contact(
      hoTen: 'Nguyen Van A',
      dienThoai: '0901234567',
      email: 'a@vhu.edu.vn',
    ),
    const Contact(
      hoTen: 'Tran Thi B',
      dienThoai: '0912345678',
      email: 'b@vhu.edu.vn',
    ),
    const Contact(
      hoTen: 'Le Van C',
      dienThoai: '0987654321',
      email: 'c@vhu.edu.vn',
    ),
  ];

  Future<void> _moChiTiet(int viTri) async {
    final result = await Navigator.push<DetailResult>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ContactDetailPage(contact: _danhBa[viTri]),
      ),
    );

    if (result == null) return;
    if (!mounted) return;

    setState(() {
      if (result.action == DetailAction.deleted) {
        _danhBa.removeAt(viTri);
      } else if (result.contact != null) {
        _danhBa[viTri] = result.contact!;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.action == DetailAction.deleted
              ? 'Da xoa lien he'
              : 'Da cap nhat lien he',
        ),
      ),
    );
  }

  Future<void> _themMoi() async {
    final moi = await Navigator.push<Contact>(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactEditPage(),
      ),
    );

    if (moi == null || !mounted) return;

    setState(() {
      _danhBa.add(moi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh ba mini'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.pushNamed(context, AboutPage.routeName);
            },
          ),
        ],
      ),
      body: _danhBa.isEmpty
          ? const Center(child: Text('Danh ba trong'))
          : ListView(
        children: [
          for (int i = 0; i < _danhBa.length; i++)
            ListTile(
              leading: CircleAvatar(
                child: Text(_danhBa[i].hoTen[0]),
              ),
              title: Text(_danhBa[i].hoTen),
              subtitle: Text(_danhBa[i].dienThoai),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _moChiTiet(i),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _themMoi,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// MAN HINH 2: CHI TIET LIEN HE
class ContactDetailPage extends StatelessWidget {
  final Contact contact;

  const ContactDetailPage({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.hoTen)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dong(Icons.person, 'Ho ten', contact.hoTen),
            _dong(Icons.phone, 'Dien thoai', contact.dienThoai),
            _dong(
              Icons.email,
              'Email',
              contact.email.isEmpty ? '(chua co)' : contact.email,
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Sua'),
              onPressed: () async {
                final sua = await Navigator.push<Contact>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ContactEditPage(banDau: contact),
                  ),
                );

                if (sua == null || !context.mounted) return;

                Navigator.pop(
                  context,
                  DetailResult(DetailAction.updated, sua),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xoa'),
              onPressed: () {
                Navigator.pop(
                  context,
                  const DetailResult(DetailAction.deleted),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dong(IconData icon, String nhan, String giaTri) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(nhan),
      subtitle: Text(
        giaTri,
        style: const TextStyle(fontSize: 17),
      ),
    );
  }
}

// MAN HINH 3: THEM VA SUA LIEN HE
class ContactEditPage extends StatefulWidget {
  final Contact? banDau;

  const ContactEditPage({super.key, this.banDau});

  @override
  State<ContactEditPage> createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _ten;
  late final TextEditingController _sdt;
  late final TextEditingController _email;

  bool _daSua = false;

  @override
  void initState() {
    super.initState();
    _ten = TextEditingController(
      text: widget.banDau?.hoTen ?? '',
    );
    _sdt = TextEditingController(
      text: widget.banDau?.dienThoai ?? '',
    );
    _email = TextEditingController(
      text: widget.banDau?.email ?? '',
    );
  }

  @override
  void dispose() {
    _ten.dispose();
    _sdt.dispose();
    _email.dispose();
    super.dispose();
  }

  void _luu() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Contact(
        hoTen: _ten.text.trim(),
        dienThoai: _sdt.text.trim(),
        email: _email.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_daSua,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final thoat = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Bo thay doi?'),
            content: const Text(
              'Du lieu ban vua nhap se khong duoc luu.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('O lai'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Thoat'),
              ),
            ],
          ),
        );

        if (thoat == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.banDau == null ? 'Them lien he' : 'Sua lien he',
          ),
        ),
        body: Form(
          key: _formKey,
          onChanged: () {
            setState(() => _daSua = true);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _ten,
                decoration: const InputDecoration(
                  labelText: 'Ho va ten',
                ),
                validator: (v) =>
                v == null || v.trim().isEmpty
                    ? 'Khong duoc de trong'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sdt,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'So dien thoai',
                ),
                validator: (v) =>
                v == null || v.trim().length < 9
                    ? 'So dien thoai khong hop le'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (khong bat buoc)',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _luu,
                child: const Text('Luu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MAN HINH GIOI THIEU: NAMED ROUTE
class AboutPage extends StatelessWidget {
  static const routeName = '/about';

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gioi thieu')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Lab F4 - Dieu huong da man hinh\n'
                'Ho ten: NHAP HO TEN CUA BAN\n'
                'MSSV: NHAP MSSV CUA BAN',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
