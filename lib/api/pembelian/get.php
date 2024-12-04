<?php
include('../config/config.php');

// Set header untuk respons API
header('Content-Type: application/json');

// Menangani kesalahan umum dengan try-catch
try {
    // Metode HTTP harus GET
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        // Metode tidak diizinkan
        http_response_code(405); // 405 Method Not Allowed
        echo json_encode([
            'status' => 'error',
            'message' => 'Metode tidak diizinkan!'
        ]);
        exit;
    }

    // Query untuk mengambil data dengan join
    $query = "
        SELECT 
            barang.namabr AS namabr, 
            supplier.nama_supplier AS nama_supplier, 
            pembelian.qty AS qty
        FROM 
            pembelian
        INNER JOIN 
            barang ON pembelian.barang_id = barang.br_id
        INNER JOIN 
            supplier ON pembelian.supplier_id = supplier.sup_id
    ";

    // Eksekusi query
    $result = mysqli_query($koneksi, $query);

    if (!$result) {
        // Jika query gagal dijalankan
        http_response_code(500); // 500 Internal Server Error
        echo json_encode([
            'status' => 'error',
            'message' => 'Terjadi kesalahan pada server: ' . mysqli_error($koneksi)
        ]);
        exit;
    }

    // Periksa apakah ada data yang ditemukan
    $data = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $data[] = [
            'namabr' => $row['namabr'],
            'nama_supplier' => $row['nama_supplier'],
            'qty' => $row['qty']
        ];
    }

    // Jika ada data, kirim respons success
    http_response_code(200); // 200 OK
    echo json_encode([
        'status' => 'success',
        'data' => $data
    ]);

} catch (Exception $e) {
    // Tangani jika terjadi exception
    http_response_code(500); // 500 Internal Server Error
    echo json_encode([
        'status' => 'error',
        'message' => 'Terjadi kesalahan pada server: ' . $e->getMessage()
    ]);
} finally {
    // Tutup koneksi setelah eksekusi selesai
    mysqli_close($koneksi);
}
?>
