import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PembelianScreen extends StatefulWidget {
  @override
  _PembelianScreenState createState() => _PembelianScreenState();
}

class _PembelianScreenState extends State<PembelianScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _qtyController = TextEditingController();
  String? _selectedSupplier;
  String? _selectedBarang;
  List<dynamic> _supplierList = [];
  List<dynamic> _barangList = [];
  List<dynamic> _pembelianList = [];

  // Fungsi untuk mengambil data pembelian
  Future<void> fetchPembelianData() async {
    final response =
        await http.get(Uri.parse('http://localhost/api/pembelian/get.php'));
    if (response.statusCode == 200) {
      setState(() {
        _pembelianList = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load pembelian data');
    }
  }

  // Fungsi untuk mengambil daftar barang
  Future<void> fetchBarangData() async {
    final response =
        await http.get(Uri.parse('http://localhost/api/barang/get.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Barang Data: ${data['data']}"); // Debugging output API barang
      setState(() {
        _barangList = data['data'];
      });
    } else {
      throw Exception('Failed to load barang data');
    }
  }

  // Fungsi untuk mengambil daftar supplier
  Future<void> fetchSupplierData() async {
    final response =
        await http.get(Uri.parse('http://localhost/api/supplier/get.php'));

    if (response.statusCode == 200) {
      setState(() {
        _supplierList = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load supplier data');
    }
  }

  // Fungsi untuk menambahkan pembelian
  Future<void> addPembelian() async {
    // Periksa apakah ada supplier dan barang yang dipilih
    if (_selectedSupplier == null || _selectedSupplier!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Supplier harus dipilih')),
      );
      return;
    }
    if (_selectedBarang == null || _selectedBarang!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barang harus dipilih')),
      );
      return;
    }

    // Periksa apakah qty valid (harus angka dan tidak kosong)
    int qty = 0;
    if (_qtyController.text.isNotEmpty) {
      try {
        qty = int.parse(_qtyController.text); // Hanya lanjutkan jika valid
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Qty harus berupa angka')),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Qty tidak boleh kosong')),
      );
      return;
    }

    // Jika semua valid, lanjutkan untuk menambah pembelian
    final requestBody = {
      'supplier_id': int.parse(_selectedSupplier!),
      'barang_id': int.parse(_selectedBarang!),
      'qty': qty,
    };

    print(
        "Request Body: $requestBody"); // Debugging print untuk melihat nilai request body

    final response = await http.post(
      Uri.parse('http://localhost/api/pembelian/pembelian.php'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      fetchPembelianData(); // Update data setelah pembelian ditambahkan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembelian berhasil ditambahkan!')),
      );
    } else {
      throw Exception('Failed to add pembelian');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPembelianData();
    fetchBarangData();
    fetchSupplierData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pembelian"),
        backgroundColor: Colors.blue[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form input untuk pembelian
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Dropdown untuk memilih barang
                  // DropdownButtonFormField<String>(
                  //   value:
                  //       _selectedBarang, // Pastikan nilai ini di-update dengan benar
                  //   hint: const Text('Pilih Barang'),
                  //   items: _barangList.map((barang) {
                  //     return DropdownMenuItem<String>(
                  //       value: barang['barang_id'].toString(),
                  //       child: Text(barang['namabr']),
                  //     );
                  //   }).toList(),
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       _selectedBarang =
                  //           newValue; // Set nilai yang dipilih ke selectedBarang
                  //     });
                  //   },
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Barang harus dipilih';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  DropdownButtonFormField<String>(
                    value: _selectedBarang,
                    hint: const Text('Pilih Barang'),
                    items: _barangList.map((barang) {
                      return DropdownMenuItem<String>(
                        value: barang['br_id'].toString(),
                        child: Text(barang['namabr']), // Nama barang
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      print("Selected Barang: $newValue"); // Debugging print
                      setState(() {
                        _selectedBarang = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Barang harus dipilih';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),
                  // Dropdown untuk memilih supplier
                  DropdownButtonFormField<String>(
                    value: _selectedSupplier,
                    hint: const Text('Pilih Supplier'),
                    items: _supplierList.map((supplier) {
                      return DropdownMenuItem<String>(
                        value: supplier['sup_id'].toString(),
                        child: Text(supplier['nama_supplier']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSupplier = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Supplier harus dipilih';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Qty tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        addPembelian(); // Menambahkan pembelian jika validasi berhasil
                      }
                    },
                    child: const Text('Tambah Pembelian'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Tabel data pembelian
            Expanded(
              child: ListView.builder(
                itemCount: _pembelianList.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(_pembelianList[index]['namabr']),
                      subtitle: Text(_pembelianList[index]['nama_supplier']),
                      trailing: Text('Qty: ${_pembelianList[index]['qty']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
