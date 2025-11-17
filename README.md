# xcore-mobile
Aplikasi Mobile Untuk xcore

# XCORE

## Deskripsi
Xcore adalah sebuah website berbasis django yang menyediakan layanan pendataan skor pertandingan sepakbola piala dunia secara akurat. Website bertujuan agar para penonton sepakbola untuk melihat hasil pertandingan, statistik pemain, polling pertandingan yang akan datang, serta terlibat aktif dalam diskusi seputar pertandingan.

## Anggota Kelompok
1. 2406496063 - Khansa Dinda Arya Putri
2. 2406400070 - Alvin Christian Halim
3. 2406404913 - Zita Nayra Ardini
4. 2406437615 - Garuga Dewangga Putra Handikto
5. 2406439192 - Anak Agung Ngurah Abhivadya Nandana

## Fitur / Modul
1. Scoreboard</br>
Scoreboard adalah tempat dimana kita bisa lihat hasil dari pertandingan yang sudah terjadi

2. Statistik</br>
Statistik adalah tempat untuk menunjukkan statistik dari suatu pertandingan seperti jumblah tendangan yang tidak masuk dan masuk, jumblah kartu merah/kuning, dll

3. Forum</br>
Forum adalah tempat dimana pengguna dapat berbincang dan berbagi pendapat tentang pertandingan

4. Highlight</br>
Highlight adalah tempat dimana pengguna dapat menonton highlights dari sebuah pertandingan

5. Prediction</br>
Prediction adalah tempat dimana pengguna dapat memberika prediksi siapa yang akan menang dan berapa skornya untuk pertandingan yang akan data

## Peran atau aktor pengguna aplikasi

`Guest` : Seorang guest dapat mengakses semua fitur kecuali Forum dan guest tidak perlu melakukan sign in/log in </br>

`User`  : Seorang user dapat mengakses semua fitur tetapi harus melakukan sign in /log in terlebih dahulu </br>

`Admin` : Admin adalah role yang menentukan data yang akan ditampilkan di website. </br>

## Pembagian Job Desk
`Scoreboard` : Anak Agung Ngurah Abhivadya Nandana </br>
`Statistik`  : Garuga Dewangga Putra Handikto</br>
`Forum`      : Zita Nayra Ardini</br>
`Highlight`  : Alvin Christian Halim</br>
`Prediction` : Khansa Dinda Arya Putri</br>

## Alur
Alur pengintegrasian dengan web service untuk terhubung dengan aplikasi web yang sudah dibuat saat Proyek Tengah Semester
1. Mobile mengirim request ke API
2. Django menerima & memproses data
3. Django mengirim response JSON
4. Mobile menampilkan hasil pada user
5. Sistem authentikasi (guest, user, admin) membatasi akses fitur
6. Semua data ditarik secara dinamis dari server

## Design
https://www.figma.com/design/sTyMbtyzsur2K5reeIWjxo/Untitled?node-id=0-1&t=gH3GWdAi5VQOSjXW-1

## PLAN PER WEEK:
-17-23 November:
Alvin : Buat library untuk register

-24-30 November:
Alvin : Membuat API Fitur Highlights

-01-07 Desember:
Alvin : Membuat API Fitur Teams & Players (bagian dari lineup)

-08-14 Desember:
Alvin : Menggabungkan rounting antar fitur

-15-21 Desember:
Alvin : Recheck kode



