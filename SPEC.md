# Estetix AI — "Hayatı Güzelleştir" Ürün Şartnamesi

## 1. Vizyon

Yapay zekâ ile "nasıl tasarlasam, nasıl dekore etsem, ne giysem, nasıl diyet yapsam" sorularına
cevap veren, 7'den 70'e herkesin kullanabileceği, profesyonel ve şık bir mobil uygulama.
Her işlemde AI **2 seçenek** sunar; kullanıcı 1'ini seçer (ya da yeniden üretmesini ister).

## 2. Paneller (6 adet)

### Bahçe & Dış Mekan
1. Foto çek / yükle → tasarlanacak alan.
2. "Yeni tasarım" veya "var olan eşyalarla" seçimi.
3. Stil soruları (modern, klasik, vb. — artırılabilir).
4. AI 2 tasarım sunar.
5. Yeni tasarım seçildiyse: ürünler e-ticaretten taranır → kalem kalem fiyat + affiliate link + **toplam maliyet**.
6. Proje olarak arşive: ürün listesi + uygulama rehberi + eski/yeni görseller.

### İç Mekan & Ev Dekorasyonu
Bahçe paneli ile aynı akış (foto → 2 seçenek → ürün + affiliate + maliyet → arşiv).

### Moda & Makyaj — "Bugün Ne Giysem"
1. İlk kurulum: gardırop fotoğrafları (tüm kıyafetler) + kullanıcının kendi foto seti
   (yüz yakın plan, boydan, bel üstü/altı, ön/arka/yan profil).
2. "Bugün ne giysem?" → AI "gardroptan mı, yeni ürün mü?" diye sorar.
   - **Gardroptan**: AI modu anlamak için sorular sorar → 2 kombin → giydirir (+ kadınsa makyaj) → gösterir.
   - **Yeni ürün**: AI modu/psikolojik durumu anlar → 2 tasarım → kullanıcı 1 seçer ya da yeniden ister.
3. Beğenilen ürünler e-ticarette bulunur (veya benzeri) → fiyat + foto + affiliate link → listeye eklenir
   (aksesuar, makyaj, giysi).
4. Arşive uygun kategoriye klasör.

### Diyet & Yemek
1. Buzdolabı/tezgah fotoğrafı çek ya da yükle.
2. "Diyet" veya "normal yemek" seçimi.
3. Sağlık bilgileri (şeker, tansiyon vb.) + ek sorular.
4. AI 2 tarif sunar → 1 seçilir → malzeme + adımlar gösterilir.
5. Arşive kategoriye uygun klasör.

### Arşiv (Estetix Drive)
- Kategoriye göre klasör yapısı; seçilen tasarımların görselleri + PDF + ürün listesi saklanır.

### Profil
- İsteğe bağlı profil (yaş/boy/kilo/sağlık bilgileri).
- Token bakiyesi + depo kullanımı + dil seçimi + çıkış.
- Token bitince → ödüllü video veya premium yönlendirme.

## 3. AI Orkestrasyonu (tek Edge Function: transform-engine)
- **Gemini** → görüntü analizi (mekân, malzeme, kıyafet).
- **FLUX.1 Dev / OpenAI gpt-image-1** → görsel üretim (render).
- **DeepSeek-V3** → tarif, diyet programı, kombin önerisi, ürün + fiyat + affiliate link.
- Affiliate: URL'lere `?subid=estetix_app` eklenir.

## 4. Monetizasyon
- **Token usulü kullanım** (standart 1, premium 3-5 token).
- **Ödüllü video** → +2 token.
- **1 defalık mağaza yorumu + yıldız** → +5 token.
- **Tüm sayfalarda banner reklam**.
- **Token satışı** (RevenueCat IAP) + **arşiv hafıza artırma** (token ile).
- Başlangıç hafızası sınırlı (50 MB).
- SMS OTP kayıt.

## 5. Önerilen geliştirmeler
1. Hava durumu + etkinlik entegrasyonu → "Bugün ne giysem" AI'ı hava/davete göre önersin.
2. Konuşmalı (chat) AI akışı → form yerine AI soru-cevapla modu anlasın.
3. Kaydedilen görünümler (saved looks) → beğenilen kombinler tekrar kullanılabilsin.
4. Diyet ilerleme takibi → kilo grafiği.
5. Before/After paylaşımı → sosyal medya.
6. Proje klasörünü tek PDF olarak dışa aktarma.

## 6. Teknik Mimari
- Flutter (iOS + Android + Web önizleme).
- Supabase (Auth OTP, PostgreSQL, Storage, Edge Functions).
- RevenueCat (IAP) + Google AdMob (banner + ödüllü).
- Clean Architecture / Feature-first.

## 7. Yol Haritası
1. Sonuç ekranı: affiliate link + kalem kalem fiyat + toplam maliyet (ortak temel).
2. Moda: gardırop + "Bugün Ne Giysem" (2 mod).
3. Diyet: sağlık profili + malzeme→tarif (2 mod).
4. Rate-app + video token ödülleri.
5. Önerilen geliştirmeler (öncelik sırasına göre).
