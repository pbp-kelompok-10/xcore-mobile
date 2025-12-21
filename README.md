# xcore-mobile
[![Build Status](https://app.bitrise.io/app/7569861b-30b9-4d46-aa2b-1a4841568706/status.svg?token=7ImBm8XQ8wAnGcPuOYcmYg&branch=main)](https://app.bitrise.io/app/7569861b-30b9-4d46-aa2b-1a4841568706)

Aplikasi Mobile Untuk xcore

## Deskripsi
Xcore adalah sebuah website berbasis django yang menyediakan layanan pendataan skor pertandingan sepakbola piala dunia secara akurat. Website bertujuan agar para penonton sepakbola untuk melihat hasil pertandingan, statistik pemain, polling pertandingan yang akan datang, serta terlibat aktif dalam diskusi seputar pertandingan. Aplikasi ini merupakan aplikasi versi mobile untuk xcore.

## Video 
https://drive.google.com/drive/folders/152NsdMO7sbMyKAWdDd-tibXMs1AWqg__?usp=sharing

## Download
Download aplikasi versi terbaru: [Download Apk](https://app.bitrise.io/app/7569861b-30b9-4d46-aa2b-1a4841568706/installable-artifacts/a342abdd5cdf9848/public-install-page/bcd6d515c46a91e8c3284ce7b8845c40)

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

# PLAN PER WEEK

## 17-23 November:
- **Alvin**: Buat library untuk register
- **Abhi**: Membuat API Fitur Scoreboard  
- **Zita**: Membuat API Fitur Forum dan UI nya
- **Kasa**: Membuat design aplikasi di Figma
- **Garuga**: Membuat API Fitur Statistik

## 24-30 November:
- **Alvin**: Membuat API Fitur Highlights
- **Abhi**: UI scoreboard
- **Zita**: Membuat API Fitur Lineup dan UI nya
- **Kasa**: Membuat fitur API Prediction
- **Garuga**: UI statistik

## 01-07 Desember:
- **Alvin**: Membuat API Fitur Teams & Players (bagian dari lineup)
- **Abhi**: Integrasi API
- **Zita**: Styling dan merapihkan kode
- **Kasa**: Integrasi API
- **Garuga**: Integrasi API

## 08-14 Desember:
- **Alvin**: Menggabungkan rounting antar fitur
- **Abhi**: Finalisasi
- **Zita**: Finishing
- **Kasa**: Styling dan merapikan kode
- **Garuga**: Finalisasi

## 15-21 Desember:
- **Alvin**: Recheck kode
- **Abhi**: Bikin video
- **Zita**: Recheck kode & bikin video
- **Kasa**: Finishing
- **Garuga**: Bikin video
<<<<<<< HEAD
=======

## 01-07 Desember:
- **Alvin**: Membuat API Fitur Teams & Players (bagian dari lineup)
- **Abhi**: Integrasi API
- **Zita**: Styling dan merapihkan kode
- **Kasa**: Integrasi API
- **Garuga**: Integrasi API

## 08-14 Desember:
- **Alvin**: Menggabungkan rounting antar fitur
- **Abhi**: Finalisasi
- **Zita**: Finishing
- **Kasa**: Styling dan merapikan kode
- **Garuga**: Finalisasi

## 15-21 Desember:
- **Alvin**: Recheck kode
- **Abhi**: Bikin video
- **Zita**: Recheck kode & bikin video
- **Kasa**: Finishing
- **Garuga**: Bikin video
>>>>>>> origin/prod
