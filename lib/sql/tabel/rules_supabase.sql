-- RLS (Row Level Security) untuk tabel Supabase aplikasi admin_wifi.
-- Kebijakan di bawah ini bersifat permissive (dev) agar sinkronisasi dengan
-- anon/publishable key dapat berjalan. Tighten sesuai kebutuhan produksi.

-- Aktifkan RLS
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

-- Kebijakan permissive (dev): izinkan semua operasi untuk anon & authenticated
do $$
declare
  t text;
begin
  foreach t in array array[
    'dompet','kategori','sub_kategori','kritik_saran','paket','pelanggan',
    'pelanggan_aktif','pesan','transaksi','versi_apk_user','pengaturan'
  ] loop
    execute format(
      'create policy if not exists "allow_all_%s" on public.%I for all to anon, authenticated using (true) with check (true);',
      t, t
    );
  end loop;
end $$;
