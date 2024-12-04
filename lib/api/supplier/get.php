<?php
include('../config/config.php');

// Set header untuk respons API
header('Content-Type: application/json');

try {
    // Pastikan metode HTTP adalah GET
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        http_response_code(405); // Metode tidak diizinkan
        echo json_encode([
            'status' => 'error',
            'message' => 'Metode tidak diizinkan!'
        ]);
        exit;
    }

    // Query untuk mengambil data supplier
    $query = "SELECT sup_id, nama_supplier, no_telp, perusahaan FROM supplier";
    $result = mysqli_query($koneksi, $query);

    if (!$result) {
        // Jika query gagal
        http_response_code(500); // Kesalahan server internal
        echo json_encode([
            'status' => 'error',
            'message' => 'Terjadi kesalahan pada server: ' . mysqli_error($koneksi)
        ]);
        exit;
    }

    // Cek apakah data ditemukan
    $suppliers = [];
    while ($row = mysqli_fetch_assoc($result)) {
        $suppliers[] = $row;
    }

    // Jika data ditemukan atau kosong, kembalikan respons sukses
    http_response_code(200); // OK
    echo json_encode([
        'status' => 'success',
        'data' => $suppliers
    ]);
} catch (Exception $e) {
    // Tangani exception
    http_response_code(500); // Kesalahan server internal
    echo json_encode([
        'status' => 'error',
        'message' => 'Terjadi kesalahan pada server: ' . $e->getMessage()
    ]);
} finally {
    // Tutup koneksi
    mysqli_close($koneksi);
}
?>
