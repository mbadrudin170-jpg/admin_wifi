-- RLS (Row Level Security) untuk tabel Supabase aplikasi admin_wifi.
-- Kebijakan permissive (dev). `CREATE POLICY` tidak mendukung IF NOT EXISTS,
-- sehingga policy lama di-drop terlebih dahulu.

alter table public.dompet enable row level security;
alter table public.kategori enable row level security;
alter table public.sub_kategori enable row level security;
alter table public.kritik_saran enable row level security;
alter table public.paket enable row level security;
alter table public.pelanggan enable row level security;
alter table public.pelanggan_aktif enable row level security;
alter table public.pesan enable row level security;
alter table public.transaksi enable row level security;
alter table public.versi_apk_user enable row level security;
alter table public.pengaturan enable row level security;

drop policy if exists "allow_all_dompet" on public.dompet;
create policy "allow_all_dompet" on public.dompet
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_kategori" on public.kategori;
create policy "allow_all_kategori" on public.kategori
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_sub_kategori" on public.sub_kategori;
create policy "allow_all_sub_kategori" on public.sub_kategori
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_kritik_saran" on public.kritik_saran;
create policy "allow_all_kritik_saran" on public.kritik_saran
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_paket" on public.paket;
create policy "allow_all_paket" on public.paket
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_pelanggan" on public.pelanggan;
create policy "allow_all_pelanggan" on public.pelanggan
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_pelanggan_aktif" on public.pelanggan_aktif;
create policy "allow_all_pelanggan_aktif" on public.pelanggan_aktif
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_pesan" on public.pesan;
create policy "allow_all_pesan" on public.pesan
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_transaksi" on public.transaksi;
create policy "allow_all_transaksi" on public.transaksi
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_versi_apk_user" on public.versi_apk_user;
create policy "allow_all_versi_apk_user" on public.versi_apk_user
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "allow_all_pengaturan" on public.pengaturan;
create policy "allow_all_pengaturan" on public.pengaturan
  for all to anon, authenticated using (true) with check (true);
