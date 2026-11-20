-- SQL DDL untuk tabel Supabase yang digunakan oleh aplikasi admin_wifi.
-- Kolom memakai snake_case sesuai aturan penamaan proyek.

-- dompet
create table if not exists public.dompet (
  id text primary key,
  nama_dompet text not null,
  saldo numeric not null default 0,
  diperbarui text,
  is_deleted boolean not null default false,
  diarsipkan text
);

-- kategori
create table if not exists public.kategori (
  id text primary key,
  nama text not null,
  tipe text,
  id_sub_kategori jsonb,
  diperbarui text,
  is_deleted boolean not null default false,
  diarsipkan text
);

-- sub_kategori
create table if not exists public.sub_kategori (
  id text primary key,
  nama text not null,
  id_kategori text not null,
  diperbarui text,
  is_deleted boolean not null default false,
  diarsipkan text
);

-- kritik_saran
create table if not exists public.kritik_saran (
  id text primary key,
  isi text,
  tanggal text,
  user_id text,
  diperbarui text
);

-- paket
create table if not exists public.paket (
  id text primary key,
  nama text not null,
  harga numeric not null default 0,
  durasi integer not null default 0,
  tipe text,
  jumlah_poin integer not null default 0,
  poin_hadiah integer not null default 0,
  poin_penukaran integer not null default 0,
  is_public boolean not null default true,
  is_deleted boolean not null default false,
  diperbarui text,
  diarsipkan text
);

-- pelanggan
create table if not exists public.pelanggan (
  id text primary key,
  nama text not null,
  telepon text,
  alamat text,
  password text,
  mac_address text,
  status text not null default 'aktif',
  is_deleted boolean not null default false,
  diperbarui text,
  diarsipkan text
);

-- pelanggan_aktif
create table if not exists public.pelanggan_aktif (
  id text primary key,
  id_pelanggan text,
  id_paket text,
  id_transaksi text,
  tanggal_mulai text,
  tanggal_berakhir text,
  status text,
  is_deleted boolean not null default false,
  diperbarui text,
  diarsipkan text
);

-- pesanan (kode mengirim ke tabel "pesan")
create table if not exists public.pesan (
  id text primary key,
  id_pelanggan text,
  id_paket text,
  tanggal text,
  status text,
  diperbarui text,
  is_deleted boolean not null default false,
  diarsipkan text
);

-- transaksi
create table if not exists public.transaksi (
  id text primary key,
  tanggal text not null,
  keterangan text,
  jumlah numeric not null default 0,
  tipe text,
  id_dompet text,
  id_kategori text,
  id_dompet_tujuan text,
  id_pelanggan text,
  id_paket text,
  id_sub_kategori text,
  status_pembayaran text,
  poin_yang_dihasilkan integer not null default 0,
  poin_yang_digunakan integer not null default 0,
  diperbarui text,
  diarsipkan text,
  is_deleted boolean not null default false,
  durasi_paket integer,
  tipe_durasi_paket text,
  tanggal_mulai text,
  tanggal_berakhir text,
  aktivasi_paket boolean not null default false
);

-- versi_apk_user
create table if not exists public.versi_apk_user (
  id text primary key,
  catatan_rilis text,
  versi_terbaru text,
  youtube_tutorial text,
  diperbarui text,
  nomor_build_terbaru jsonb,
  tautan_unduhan jsonb,
  wajib_update boolean not null default false,
  is_deleted boolean not null default false,
  diarsipkan text
);

-- pengaturan
create table if not exists public.pengaturan (
  id text primary key default 'pengaturan',
  interval_sinkronisasi_otomatis integer not null default 24,
  hapus_otomatis_data_arsip integer not null default 30,
  mode_pemeliharaan boolean not null default false,
  info_pemeliharaan text,
  diperbarui text
);
