-- Hapus (drop) tabel Supabase aplikasi admin_wifi.
-- PERINGATAN: perintah ini menghapus data. Gunakan hanya untuk reset/dev.

drop table if exists public.pengaturan cascade;
drop table if exists public.versi_apk_user cascade;
drop table if exists public.transaksi cascade;
drop table if exists public.pesan cascade;
drop table if exists public.pelanggan_aktif cascade;
drop table if exists public.pelanggan cascade;
drop table if exists public.paket cascade;
drop table if exists public.kritik_saran cascade;
drop table if exists public.sub_kategori cascade;
drop table if exists public.kategori cascade;
drop table if exists public.dompet cascade;