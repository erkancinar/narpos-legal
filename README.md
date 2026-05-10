# narpos-legal

NarPOS Yazılım A.Ş. iç araçları için yasal belgeler — statik HTML site.

**Production:** https://legal.narpos.tr
**Hosting:** Cloudflare Pages

## Sayfalar

- `index.html` — Landing (3 sayfaya link)
- `privacy.html` — Gizlilik Politikası
- `terms.html` — Kullanım Koşulları
- `kvkk.html` — KVKK Aydınlatma Metni

## Lokal test

Bir static server ile aç:
```bash
cd narpos-legal
python -m http.server 8000
# http://localhost:8000
```

## Deploy (Cloudflare Pages)

GitHub repo'ya push → CF Pages otomatik deploy.

## Güncelleme

Her değişiklik commit + push → CF Pages otomatik build (~30 sn).

Sayfa altında "Son güncelleme" tarihini değiştirmeyi unutma.

## Notlar

- Tüm metinler Türkçe (NarPOS internal use, Türkiye)
- HTML inline CSS, dış bağımlılık yok
- Mobile-friendly (responsive)
- Avukat onayı sonrası finalleştirilir
