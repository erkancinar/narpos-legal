# narpos-legal

NarPOS Yazılım A.Ş. iç araçları için yasal belgeler — statik HTML site.

**Production:** https://legal.narpos.tr
**Hosting:** Cloudflare Pages

## Sayfalar

- `index.html` — Landing (5 sayfaya link)
- `privacy.html` — Gizlilik Politikası
- `privacy-narcrm.html` — NarCRM Gizlilik Politikası
- `terms.html` — Kullanım Koşulları
- `terms-narcrm.html` — NarCRM Kullanım Sözleşmesi
- `kvkk.html` — KVKK Aydınlatma Metni

## Lokal test

Bir static server ile aç:
```bash
cd narpos-legal
python -m http.server 8000
# http://localhost:8000
```

## Deploy (Cloudflare Pages)

Bu proje Cloudflare Pages üzerinde `narpos-legal` project olarak çalışır; mevcut production deploy geçmişi `ad_hoc` tipindedir. Yani sadece GitHub'a push etmek production yayınına almak için yeterli değildir.

Otomatik deploy için Contabo üzerindeki self-host Drone CI kullanılır. Mevcut Drone kurulumu Bitbucket Cloud provider ile çalıştığı için bu repo GitHub yanında Bitbucket mirror olarak da push edilir:

```text
GitHub:    https://github.com/erkancinar/narpos-legal
Bitbucket: git@bitbucket.org:erkancinar/narpos-legal.git
Drone:     https://ci.narpos.tr
```

`main` branch'e Bitbucket push geldiğinde `.drone.yml` pipeline'ı çalışır:

1. Statik yayın dosyalarını `dist/` içine paketler.
2. `wrangler pages deploy` ile Cloudflare Pages direct upload yapar.
3. `https://legal.narpos.tr/privacy-narcrm` ve `https://legal.narpos.tr/terms-narcrm` smoke test kontrollerini çalıştırır.

Key bilgileri local key depoda tutulur:

```text
C:\Projects\ai-workspace\private-keystore\services\cloudflare-narpos.env
C:\Projects\ai-workspace\private-keystore\services\narpos-legal-pages.env
```

Production deploy için:

```powershell
cd C:\Projects\narpos-legal
powershell -ExecutionPolicy Bypass -File .\scripts\deploy-cloudflare-pages.ps1
```

Script temiz bir geçici klasöre sadece yayın dosyalarını (`*.html`, `favicon.ico`, `assets/*`) kopyalar ve `wrangler pages deploy` ile Cloudflare Pages'e gönderir. `.git`, `.wrangler`, README veya çalışma dosyaları upload edilmez.

Deploy sonrası kontrol:

```powershell
Invoke-WebRequest https://legal.narpos.tr/privacy-narcrm -UseBasicParsing
Invoke-WebRequest https://legal.narpos.tr/terms-narcrm -UseBasicParsing
```

## Güncelleme

Her değişiklik için sıra:

1. Dosyayı güncelle.
2. Sayfa altında "Son güncelleme" tarihini değiştir.
3. `git commit` + `git push`.
4. `scripts\deploy-cloudflare-pages.ps1` ile Cloudflare Pages production deploy.
5. Canlı URL'yi kontrol et.

## Notlar

- Tüm metinler Türkçe (NarPOS internal use, Türkiye)
- HTML inline CSS, dış bağımlılık yok
- Mobile-friendly (responsive)
- Avukat onayı sonrası finalleştirilir
