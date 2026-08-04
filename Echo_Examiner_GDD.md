# ECHO EXAMINER
## Game Design Document (GDD)
**Versi:** 1.0 — Draft Blueprint Implementasi
**Genre:** First-Person Psychological Deduction / Simulation
**Durasi Pengembangan Target:** ±2 minggu (MVP)

---

## DAFTAR ISI

1. High Concept
2. Vision
3. Core Pillars
4. Target Audience
5. Gameplay Overview
6. Narrative
7. Lore Dunia
8. Karakter Player
9. Echo
10. NPC Design
11. Emotion Design
12. Decision System
13. Dialogue System
14. Investigation System
15. Echo Reaction Rules
16. Internal Hidden Variables
17. Progression
18. Daily Loop
19. Game Flow
20. UI Flow
21. UX Flow
22. Scene Structure
23. Asset List
24. Animation List
25. Audio List
26. Technical Requirement
27. Randomization System
28. Data Structure NPC
29. Data Structure Echo
30. Balancing
31. Replayability
32. MVP Scope
33. Future Expansion
34. Flowchart Gameplay
35. State Machine Gameplay
36. Pseudocode Decision System
37. Diagram Hubungan Antar Sistem
38. Tabel Ruleset Master

---

## 1. HIGH CONCEPT

**Echo Examiner** adalah game deduksi psikologis first-person di mana player berperan sebagai petugas pemeriksa khusus yang mampu melihat **Echo** — manifestasi fisik dari kondisi emosional manusia. Setiap hari, player memeriksa pasien di sebuah ruang observasi, mengajukan pertanyaan terbatas untuk memancing reaksi Echo, lalu menyimpulkan emosi dominan pasien dan menentukan jadwal kontrol berikutnya. Keputusan yang salah dapat membuat pasien kehilangan kendali emosinya (**Echo Burst**) sebelum sempat diperiksa kembali, yang berarti Game Over.

Game ini tidak memiliki combat, eksplorasi, maupun inventory — seluruh pengalaman terkonsentrasi pada observasi, empati terapan, dan pengambilan keputusan berbasis bukti tidak langsung, mirip *Papers, Please* dari sisi tekanan birokratis-moral dan *That's Not My Neighbor* dari sisi observasi visual dalam satu ruangan tetap.

---

## 2. VISION

Menciptakan pengalaman singkat namun berkesan yang membuat player **berlatih membaca emosi manusia** melalui bahasa visual (Echo) dan bahasa verbal (dialog), bukan melalui angka atau statistik yang eksplisit. Kesuksesan datang dari kepekaan observasi, bukan dari menghafal rumus. Game harus terasa tenang, sedikit mencekam secara psikologis (bukan horor jumpscare), dan reflektif terhadap tema kesehatan mental tanpa menstigmakan kondisi emosional apa pun.

---

## 3. CORE PILLARS

| Pillar | Deskripsi | Implikasi Desain |
|---|---|---|
| **Observasi, bukan Aksi** | Tidak ada mekanik reflek/aksi cepat | Semua interaksi berbasis klik/pilih, tanpa timer tekanan gerak |
| **Petunjuk Tidak Langsung** | Jawaban benar tidak pernah diberi label eksplisit | Sistem petunjuk hanya lewat visual Echo & dialog NPC |
| **Konsekuensi Tertunda** | Kesalahan tidak langsung terlihat | Echo Burst terjadi di hari-hari setelah diagnosis, sesuai jadwal kontrol |
| **Ruang Tunggal, Kedalaman Sistemik** | Satu ruangan, sistem data kaya di baliknya | Variasi datang dari data NPC/Echo tersembunyi, bukan dari lokasi baru |
| **Empati Tanpa Menghakimi** | Tidak ada emosi yang "jahat" | Semua 6 emosi ditulis netral, manusiawi, dapat dikenali siapa saja |

---

## 4. TARGET AUDIENCE

- Penggemar game naratif-deduktif kasual (*Papers, Please*, *That's Not My Neighbor*, *Return of the Obra Dinn* fans versi ringan).
- Pemain yang tertarik pada tema kesehatan mental/EQ namun menginginkan bungkus gameplay yang jelas dan sistemik, bukan visual novel murni.
- Sesi bermain singkat (15–40 menit total untuk 7 hari), cocok untuk platform PC casual maupun web/itch.io untuk kompetisi.
- Usia disarankan 13+ mengingat tema psikologis (trauma, penyesalan) disampaikan secara implisit dan tidak grafis.

---

## 5. GAMEPLAY OVERVIEW

Player menghabiskan 7 hari kerja sebagai Echo Examiner. Setiap hari terdiri dari 5 sesi pemeriksaan pasien berturut-turut di ruang pemeriksaan yang sama. Setiap sesi terdiri dari:

1. Membaca info singkat pasien.
2. Mengamati Echo berupa kabut hitam tanpa bentuk jelas.
3. Memilih 3 dari 6 topik pertanyaan yang tersedia.
4. Mengamati reaksi Echo dan bahasa tubuh NPC setelah tiap pertanyaan.
5. Menetapkan **Emosi Dominan** dan **Jadwal Kontrol**.

Tidak ada mekanik gerak, tidak ada game over instan di tengah sesi — tekanan muncul secara kumulatif melalui akibat dari keputusan-keputusan sebelumnya yang baru terlihat pada hari-hari berikutnya.

---

## 6. NARRATIVE

Narasi disampaikan secara minimal dan implisit, melalui:

- Catatan singkat pasien (nama, usia, profesi, alasan rujukan).
- Dialog NPC yang berubah nada tergantung topik yang disentuh.
- Log internal fasilitas (opsional, flavour text) yang muncul di sela hari, memberi rasa dunia tanpa cutscene besar.

Tidak ada antagonis tunggal. Ketegangan utama adalah antara **keterbatasan waktu/pertanyaan** dan **tanggung jawab moral** atas kesejahteraan pasien. Player secara halus didorong merefleksikan bahwa diagnosis cepat dan pasti itu mustahil — sebagaimana dalam kehidupan nyata membaca emosi orang lain.

---

## 7. LORE DUNIA

- **Echo** adalah fenomena yang muncul pada seluruh manusia sebagai representasi visual kondisi emosionalnya. Echo bukan makhluk, bukan roh — ia adalah "bayangan emosi".
- Hanya sebagian kecil manusia (disebut **Examiner**, termasuk player) dapat melihat Echo secara jelas.
- Ketika emosi seseorang ditekan, tidak diproses, atau mengalami trauma berkepanjangan, Echo menjadi tidak stabil.
- Ketidakstabilan yang mencapai titik kritis memicu **Echo Burst**: hilangnya kendali emosional yang berpotensi mencelakai diri sendiri atau orang lain. Ini bukan ledakan fisik/supernatural, melainkan krisis emosional akut (mis. kekerasan impulsif, kehancuran total, tindakan berbahaya).
- Orang dengan Echo tidak stabil dikirim ke **Fasilitas Observasi Echo**, tempat player bekerja sebagai salah satu Examiner yang bertugas memantau dan menjadwalkan kontrol lanjutan — bukan menyembuhkan.
- Fasilitas ini bersifat birokratis-klinis: netral secara nada, tidak digambarkan sebagai jahat maupun heroik, mencerminkan sistem institusional dunia nyata yang dijalankan manusia dengan keterbatasan.

---

## 8. KARAKTER PLAYER

**Nama Peran:** Echo Examiner (tanpa nama personal, untuk imersi first-person).

**Kemampuan:**
- Melihat Echo yang tidak terlihat oleh manusia biasa.
- Mengajukan pertanyaan kepada pasien (dibatasi 3 dari 6 per sesi).
- Mencatat kesimpulan (emosi dominan) dan menentukan jadwal kontrol.

**Batasan:**
- Tidak dapat menyembuhkan atau mengubah kondisi pasien secara langsung.
- Tidak dapat membatalkan keputusan setelah pasien keluar ruangan.
- Tidak memiliki akses ke data numerik internal pasien (stabilitas, emosi asli) — hanya observasi.

**Sudut Pandang:** First-person statis di dalam ruang pemeriksaan; kamera tidak berpindah tempat, hanya menghadap pasien dan sedikit look-around opsional pada ruangan.

---

## 9. ECHO

Echo adalah wujud visual emosi yang mengambang di dekat/di atas tubuh pasien.

**Wujud Dasar (State 0 — belum terinvestigasi):** kabut hitam pekat, bentuk tidak beraturan, tidak menunjukkan ciri emosi apa pun, gerakan lambat berdenyut pelan (seperti bernapas).

**Prinsip Perkembangan Visual:**
- Echo *tidak pernah* berubah menjadi bentuk final di awal.
- Setiap pertanyaan yang relevan dengan emosi asli pasien akan mengikis kabut dan memunculkan **satu elemen visual ciri emosi**.
- Pertanyaan yang tidak relevan membuat Echo tetap kabur atau hanya bergetar ringan (tanpa elemen baru).
- Setelah 3 pertanyaan (maksimum), Echo mencapai **State Akhir Investigasi** — kombinasi 1–3 elemen visual yang terkumpul, yang menjadi dasar deduksi player. Echo *tidak pernah* mencapai bentuk 100% sempurna dalam MVP — selalu menyisakan ambiguitas, sesuai realita bahwa membaca emosi tidak pernah pasti mutlak.

**Enam Jenis Echo (selaras 1:1 dengan 6 emosi):**

| Echo | Emosi | Motif Visual Inti |
|---|---|---|
| Echo Retak (Cracked) | Fear | Retakan menjalar, echo mengecil & bergetar |
| Echo Api (Ember) | Anger | Api kecil membara di tepi kabut, warna memerah |
| Echo Akar (Rooted/Sinking) | Sadness | Akar/rantai menjuntai ke bawah, echo menjadi berat & turun |
| Echo Mata (Watchful) | Guilt | Mata-mata kecil muncul di permukaan kabut, mengarah ke pasien sendiri |
| Echo Lipat (Folding) | Shame | Echo melipat/mengerut ke dalam, menjauh dan menyembunyikan diri di balik tubuh pasien |
| Echo Bayangan Kembar (Mirror) | Envy | Echo membelah membentuk siluet kedua yang meniru sosok lain, condong ke arah orang yang disebut dalam dialog |

Detail penuh masing-masing Echo ada di **Section 11 (Emotion Design)** dan ruleset transisi visual ada di **Section 15 (Echo Reaction Rules)**.

---

## 10. NPC DESIGN

**Prinsip MVP:** 6 Base NPC (rig visual, model dasar) yang dipakai ulang sepanjang 7 hari dengan variasi shallow (nama, profesi, usia tampilan, warna pakaian, potongan rambut/aksesori sederhana) dan variasi dalam (kasus/skenario, dialog, data emosi tersembunyi).

**Struktur Base NPC:**

| Base NPC | Arketipe Visual | Contoh Variasi Pemakaian |
|---|---|---|
| NPC-A | Dewasa muda, pakaian kasual kerja | Karyawan magang, mahasiswa, kurir |
| NPC-B | Paruh baya, pakaian formal/kantor | Manajer, guru, birokrat |
| NPC-C | Dewasa, pakaian pekerja lapangan | Buruh, sopir, teknisi |
| NPC-D | Lansia, pakaian sederhana/rumahan | Pensiunan, orang tua tunggal |
| NPC-E | Dewasa muda, pakaian rapi-santai | Freelancer, seniman, perawat |
| NPC-F | Dewasa, pakaian formal berat/seragam | Petugas, atasan, tokoh otoritas |

**Non-visual per instance NPC (di-generate/ditulis per pasien):**
- Nama
- Usia
- Profesi/latar
- Alasan rujukan singkat (flavour, tidak membocorkan emosi asli)
- Data tersembunyi (lihat Section 16 & 28)

**Ekspresi & Bahasa Tubuh:** setiap Base NPC memiliki set animasi wajah/tubuh yang dipetakan ke *state emosi yang sedang terungkap* (bukan ke identitas NPC), sehingga assetnya reusable lintas NPC. Lihat Section 24.

---

## 11. EMOTION DESIGN

Enam emosi MVP: **Fear, Anger, Sadness, Guilt, Shame, Envy.** Setiap emosi dijabarkan lengkap agar dapat dibedakan satu sama lain baik oleh player maupun oleh sistem (writer/artist).

### 11.1 FEAR (Echo Retak)

- **Filosofi Visual:** Ketidakstabilan yang rapuh — sesuatu yang bisa "pecah" kapan saja. Bukan agresif, tapi defensif.
- **Perilaku Echo:** bergetar cepat namun kecil, retakan tipis menjalar dari tepi ke tengah, echo cenderung menjauh (mundur) dari pasien saat topik sensitif disentuh.
- **Bahasa Tubuh NPC:** tangan menggenggam sesuatu (ujung baju, meja), mata sering melihat ke pintu/keluar ruangan, bahu naik defensif.
- **Ekspresi:** mata melebar sesaat, bibir tertahan, nafas terlihat lebih cepat (animasi dada).
- **Pola Dialog:** kalimat terpotong, banyak "saya tidak tahu", "mungkin sebaiknya kita bicarakan yang lain", nada suara naik di akhir kalimat (seperti bertanya).
- **Petunjuk Visual Kunci:** retakan + gerakan mundur echo adalah kombinasi diagnostik Fear yang paling kuat.
- **Contoh Kasus:** NPC baru saja mengalami kecelakaan kerja dan takut kembali bekerja, tapi menyangkal takut demi menjaga citra "baik-baik saja".
- **Perbedaan dengan emosi lain:** Fear vs Guilt — Fear menjauh dari **topik**, Guilt menjauh dari **pandangan mata player** sambil tetap membahas topik. Fear vs Shame — Fear reaktif terhadap ancaman eksternal, Shame reaktif terhadap penilaian diri sendiri (echo melipat ke dalam, bukan menjauh keluar).

### 11.2 ANGER (Echo Api)

- **Filosofi Visual:** Energi yang membara dan bisa meluap; tekanan yang mencari jalan keluar.
- **Perilaku Echo:** percikan api kecil muncul di tepi kabut, warnanya memerah dari dalam, echo sedikit membesar dan "mendekat" ke arah player (bukan menyerang, tapi menekan).
- **Bahasa Tubuh NPC:** rahang mengeras, tangan mengepal di meja, condong ke depan.
- **Ekspresi:** alis menurun tajam, tatapan tajam langsung ke player.
- **Pola Dialog:** kalimat pendek dan tegas, nada meninggi, sesekali menyalahkan pihak lain ("itu bukan salah saya", "mereka yang harusnya diperiksa").
- **Petunjuk Visual Kunci:** api + pembesaran echo yang mendekat ke player (bukan ke arah lain).
- **Contoh Kasus:** NPC dipecat secara tidak adil dan merasa harus terus membela diri di setiap kesempatan.
- **Perbedaan dengan emosi lain:** Anger vs Envy — Anger arahnya ke player/situasi saat ini secara langsung; Envy arahnya ke pihak ketiga yang disebut (mantan rekan, saudara). Anger vs Fear — Anger mendekat & membesar, Fear menjauh & mengecil.

### 11.3 SADNESS (Echo Akar)

- **Filosofi Visual:** Beban yang menarik ke bawah, keterikatan pada masa lalu yang tak terselesaikan.
- **Perilaku Echo:** akar/rantai tipis menjuntai dari bawah kabut ke lantai, echo terlihat lebih berat, turun mendekati lantai, gerakannya melambat drastis.
- **Bahasa Tubuh NPC:** bahu turun, kepala menunduk, gerakan tangan lamban.
- **Ekspresi:** mata sayu, jeda lama sebelum menjawab, sesekali menghela napas panjang (animasi).
- **Pola Dialog:** kalimat panjang mengambang tanpa kesimpulan, sering mengulang nama orang/tempat dari masa lalu, nada datar dan pelan.
- **Petunjuk Visual Kunci:** akar menjuntai + echo turun adalah penanda kuat Sadness, berbeda dari Guilt yang tetap "mengambang" namun berpaling.
- **Contoh Kasus:** NPC kehilangan orang terdekat dan belum bisa melanjutkan rutinitas normal.
- **Perbedaan dengan emosi lain:** Sadness vs Shame — Sadness berat & turun ke lantai (fokus ke kehilangan eksternal), Shame melipat & mengecil ke dalam (fokus ke diri sendiri).

### 11.4 GUILT (Echo Mata)

- **Filosofi Visual:** Pengawasan diri sendiri yang tak henti — merasa terus "diawasi" oleh perbuatan sendiri.
- **Perilaku Echo:** mata-mata kecil muncul di permukaan kabut, seluruhnya menghadap ke arah pasien sendiri (bukan ke player), echo diam di tempat, hampir tidak bergerak.
- **Bahasa Tubuh NPC:** menghindari kontak mata dengan player, tangan meremas-remas, sesekali menoleh ke arah sendiri (seolah memeriksa diri).
- **Ekspresi:** wajah tegang tertahan, bibir rapat, kadang tersenyum canggung yang tidak sinkron dengan topik.
- **Pola Dialog:** permintaan maaf berulang tanpa diminta, kalimat mengarah pada penyesalan atas tindakan spesifik yang disebut samar-samar ("andai saja saya tidak...").
- **Petunjuk Visual Kunci:** mata-mata yang mengarah ke pasien sendiri, bukan ke luar — ini pembeda utama dari Fear (yang matanya melihat ke arah pintu/keluar).
- **Contoh Kasus:** NPC merasa bertanggung jawab atas insiden yang menimpa orang lain, meski secara objektif bukan sepenuhnya salahnya.
- **Perbedaan dengan emosi lain:** Guilt vs Shame — Guilt berpusat pada **tindakan** tertentu ("saya melakukan X"), Shame berpusat pada **identitas diri** ("saya orang yang buruk").

### 11.5 SHAME (Echo Lipat)

- **Filosofi Visual:** Keinginan menghilang, menyembunyikan diri dari penilaian.
- **Perilaku Echo:** melipat ke dalam seperti kain terlipat, mengecil secara keseluruhan, bergerak bersembunyi di balik tubuh/bahu pasien.
- **Bahasa Tubuh NPC:** tubuh membungkuk, tangan menutupi sebagian wajah/dada, posisi duduk menyusut.
- **Ekspresi:** wajah menunduk penuh, jarang mengangkat kepala, suara pelan hampir berbisik.
- **Pola Dialog:** menyalahkan diri sendiri secara umum ("saya memang selalu begini"), enggan menjelaskan detail, sering mengalihkan topik ke hal remeh.
- **Petunjuk Visual Kunci:** posisi echo bersembunyi di balik tubuh pasien adalah penanda unik Shame — tidak ada emosi lain yang membuat echo bersembunyi secara fisik di balik pasien.
- **Contoh Kasus:** NPC merasa gagal memenuhi ekspektasi keluarga/masyarakat dan menginternalisasi kegagalan itu sebagai bagian dari dirinya.
- **Perbedaan dengan emosi lain:** Shame vs Guilt (lihat 11.4). Shame vs Sadness (lihat 11.3).

### 11.6 ENVY (Echo Bayangan Kembar)

- **Filosofi Visual:** Perbandingan diri dengan orang lain yang tak henti, ingin menjadi/memiliki apa yang dimiliki pihak lain.
- **Perilaku Echo:** kabut membelah menjadi dua siluet — satu tetap di tempat, satu condong/meniru arah orang yang sedang dibicarakan dalam dialog.
- **Bahasa Tubuh NPC:** membandingkan diri secara verbal maupun non-verbal (melirik ke arah kosong seolah membayangkan orang lain), rahang sedikit tegang saat menyebut nama pihak ketiga.
- **Ekspresi:** senyum tipis yang tidak tulus saat memuji orang lain, tatapan sedikit sinis.
- **Pola Dialog:** sering membandingkan diri dengan orang lain ("dia selalu lebih beruntung", "harusnya itu jadi milik saya"), pujian yang terasa dipaksakan.
- **Petunjuk Visual Kunci:** pembelahan echo menjadi dua siluet adalah ciri unik Envy, tidak dimiliki emosi lain.
- **Contoh Kasus:** NPC merasa tersaingi oleh kesuksesan saudara/rekan kerja dan sulit menerima pencapaiannya sendiri.
- **Perbedaan dengan emosi lain:** Envy vs Anger (lihat 11.2). Envy adalah satu-satunya emosi yang arah reaksinya ke **pihak ketiga**, bukan ke player atau ke diri sendiri.

---

## 12. DECISION SYSTEM

Setelah 3 pertanyaan digunakan, player WAJIB mengisi 2 keputusan sebelum pasien dapat keluar ruangan:

**A. Emosi Dominan** — pilih satu dari: Fear / Anger / Sadness / Guilt / Shame / Envy.

**B. Jadwal Kontrol** — pilih satu dari: Besok (+1 hari) / 2 Hari Lagi (+2 hari) / 3 Hari Lagi (+3 hari).

Tidak ada opsi "boleh pulang" (tanpa kontrol lanjutan) di MVP — setiap pasien baru selalu mendapat jadwal kontrol.

**Aturan Keterkaitan:**
- Emosi Dominan yang benar TIDAK secara langsung dicek/divalidasi ke player (tidak ada notifikasi benar/salah).
- Jadwal Kontrol yang dipilih menentukan berapa lama sistem "menguji" stabilitas emosi pasien sebelum kontrol berikutnya (lihat Section 16).
- Kombinasi emosi salah + jadwal kontrol terlalu panjang = risiko Echo Burst tertinggi.
- Kombinasi emosi benar namun jadwal kontrol tidak sesuai tingkat keparahan asli juga dapat memicu Echo Burst (lihat tabel Section 38).

Detail pseudocode ada di **Section 36**.

---

## 13. DIALOGUE SYSTEM

**Struktur:** Setiap pasien memiliki tepat **6 topik pertanyaan tetap**:

1. Keluarga
2. Pekerjaan
3. Hubungan
4. Masa Lalu
5. Penyesalan
6. Masa Depan

Player memilih **maksimal 3 topik** per sesi; setelah topik ke-3 dipilih, investigasi otomatis ditutup (tombol topik lain dinonaktifkan).

**Struktur Data per Topik (per NPC instance):**
- Teks pertanyaan yang diajukan player (tetap secara UI, dapat sedikit reflow sesuai profesi NPC).
- Teks jawaban NPC (unik per NPC instance, ditulis writer).
- Tag emosi yang dipicu topik ini untuk NPC tersebut (relevan / netral / mengalihkan) — lihat Section 15 & 28.
- Reaksi Echo yang dipicu (elemen visual + intensitas).
- Reaksi bahasa tubuh/ekspresi yang dipicu.

**Prinsip Penulisan Dialog (untuk Game Writer):**
- Jawaban tidak pernah menyebut nama emosi secara eksplisit ("saya merasa takut").
- Jawaban relevan memberi 1 detail konkret yang mengarah ke emosi tanpa menyebutnya (mis. untuk Fear: "saya belum berani kembali ke sana sejak itu").
- Setiap NPC harus punya minimal 1 dari 6 topik yang **paling relevan** (memicu reaksi Echo terkuat) dan sisanya bervariasi antara netral/mengalihkan, sesuai ruleset Section 15.

---

## 14. INVESTIGATION SYSTEM

Alur teknis satu sesi investigasi:

1. **Init Session:** load data NPC instance (Base NPC + variasi + data tersembunyi).
2. **Render Echo State 0** (kabut hitam polos).
3. **Tampilkan 6 tombol topik** (semua aktif).
4. **Player pilih topik →** sistem cek relevansi topik terhadap emosi asli NPC → trigger reaksi Echo & NPC sesuai Section 15 → nonaktifkan tombol topik yang sudah dipakai → kurangi counter pertanyaan tersisa.
5. Ulangi langkah 4 hingga counter = 0 (3 topik terpakai).
6. **Tutup investigasi**, tampilkan panel Decision System (Section 12).
7. Player submit Emosi Dominan + Jadwal Kontrol.
8. **Commit hasil ke data internal pasien** (lihat Section 16), sesi berakhir, pasien berikutnya di-load.

Tidak ada mekanik "ulang topik" atau "batal pilih" — setiap pilihan bersifat final dalam sesi tersebut untuk menjaga tekanan keputusan seperti dalam kehidupan nyata.

---

## 15. ECHO REACTION RULES

Ruleset ini menghubungkan **Topik Dialog → Relevansi terhadap Emosi Asli → Reaksi Echo**.

**Klasifikasi Relevansi Topik (per sesi, ditentukan oleh data NPC):**

| Level Relevansi | Definisi | Efek Umum ke Echo |
|---|---|---|
| **Primary** (maks. 1 topik/NPC) | Topik yang paling menyentuh akar emosi asli pasien | Reaksi kuat: elemen visual utama emosi muncul jelas + intensitas tinggi |
| **Secondary** (1–2 topik/NPC) | Topik yang berkaitan namun tidak inti | Reaksi sedang: elemen visual muncul samar/kecil |
| **Neutral** (2–3 topik/NPC) | Topik tidak berkaitan dengan emosi asli | Echo hanya bergetar ringan, tanpa elemen baru |
| **Deflective** (0–1 topik/NPC, opsional) | Topik yang sengaja dijauhi pasien secara sadar | Echo justru mengecil/menjauh sesaat lalu diam — bisa menyesatkan jika disalahartikan sebagai Fear |

**Tabel Reaksi Visual per Emosi (Intensitas Primary vs Secondary):**

| Emosi | Reaksi Primary | Reaksi Secondary | Reaksi Neutral |
|---|---|---|---|
| Fear | Retak besar menjalar + echo mundur cepat | Retak tipis 1 titik + getar ringan | Getar sangat kecil, tanpa retak |
| Anger | Api membesar + echo mendekat | Percikan kecil di tepi | Getar, warna tetap netral |
| Sadness | Akar tebal menjuntai + echo turun signifikan | Akar tipis 1 helai | Echo diam, tanpa perubahan posisi |
| Guilt | 3+ mata muncul menghadap pasien | 1 mata muncul sekilas | Tidak ada mata, hanya kabut diam |
| Shame | Echo melipat penuh + bersembunyi di balik tubuh | Melipat sebagian, tetap terlihat | Tidak ada perubahan bentuk |
| Envy | Pembelahan siluet jelas + condong ke arah disebut | Pembelahan samar, cepat kembali menyatu | Tidak ada pembelahan |

**Aturan Akumulasi dalam Satu Sesi:**
- Setiap topik yang dipilih menambah/mengubah *hanya* elemen visual sesuai relevansinya — elemen tidak pernah hilang setelah muncul (akumulatif).
- Jika 2 dari 3 topik yang dipilih memiliki relevansi tinggi terhadap emosi yang **sama**, Echo menampilkan kombinasi elemen emosi tersebut secara jelas (mudah dideduksi).
- Jika topik yang dipilih menyentuh **relevansi tinggi untuk emosi berbeda-beda** (mis. 1 primary Fear + 1 primary Envy), Echo menampilkan **dua elemen visual berbeda sekaligus** — ini adalah kasus ambiguitas yang disengaja untuk menaikkan kesulitan (NPC dengan emosi campuran/kompleks), namun untuk MVP setiap NPC tetap memiliki **satu emosi dominan asli** yang lebih kuat secara bobot (lihat Section 16), sehingga elemen visual emosi dominan selalu tampak lebih besar/jelas dibanding elemen sekunder.

---

## 16. INTERNAL HIDDEN VARIABLES

Setiap NPC instance memiliki data tersembunyi berikut (tidak pernah ditampilkan ke player sebagai angka):

| Variabel | Tipe | Deskripsi |
|---|---|---|
| `trueEmotion` | Enum (6 emosi) | Emosi dominan asli pasien |
| `stability` | Integer 0–100 | Tingkat kestabilan Echo saat ini; 0 = Echo Burst |
| `decayRate` | Integer (per hari) | Seberapa cepat `stability` menurun per hari jika tidak dikontrol/salah didiagnosis |
| `topicRelevanceMap` | Map topik→level relevansi | Menentukan relevansi tiap 6 topik terhadap `trueEmotion` (lihat Section 15) |
| `secondaryEmotion` (opsional) | Enum atau null | Emosi sekunder untuk kasus kompleks (naratif tambahan, tidak wajib memengaruhi Echo Burst) |
| `misdiagnosisPenalty` | Integer | Penalti tambahan pada `stability` jika `Emosi Dominan` yang dipilih player salah |
| `scheduleToleranceMap` | Map jadwal→modifier | Seberapa besar buffer stabilitas yang diberikan tiap opsi jadwal kontrol |

**Aturan Perubahan Kondisi Setelah Diagnosis:**

```
onDiagnosisSubmit(npc, chosenEmotion, chosenSchedule):
    if chosenEmotion == npc.trueEmotion:
        stabilityChange = +RECOVERY_BONUS (mis. +15)
    else:
        stabilityChange = -npc.misdiagnosisPenalty (mis. -25)

    npc.stability += stabilityChange
    npc.nextCheckupDay = currentDay + scheduleDays(chosenSchedule)
    npc.pendingDecayPerDay = npc.decayRate - scheduleToleranceMap[chosenSchedule]
```

**Aturan Perubahan Kondisi Berdasarkan Jadwal Kontrol (setiap hari berjalan hingga hari kontrol berikutnya):**

```
onNewDay(npc):
    if npc has pending checkup and currentDay < npc.nextCheckupDay:
        npc.stability -= npc.pendingDecayPerDay
        if npc.stability <= 0:
            triggerEchoBurst(npc)   -> GAME OVER
```

Jadwal kontrol yang lebih panjang (3 hari) memberi buffer `scheduleToleranceMap` lebih kecil (risiko lebih tinggi jika emosi asli parah), sedangkan jadwal lebih pendek (besok) memberi buffer lebih besar namun mengurangi kapasitas slot pasien kontrol yang tersedia di hari-hari berikutnya (lihat Section 27 Randomization & Section 30 Balancing untuk batas slot).

---

## 17. PROGRESSION

Tidak ada sistem level/XP eksplisit pada MVP. Progresi diwakili oleh:

- Bertambahnya jumlah pasien kontrol yang harus dipantau seiring hari berjalan (tekanan manajemen waktu implisit, karena slot pasien per hari tetap 5).
- Akumulasi "beban" — pasien yang salah didiagnosis di hari-hari awal dapat kembali sebagai kontrol dengan kondisi lebih genting, meningkatkan tensi menjelang Day 7.
- Feedback tidak langsung: NPC yang kembali untuk kontrol dapat menunjukkan bahasa tubuh yang membaik (jika diagnosis awal tepat) atau memburuk (jika salah), memberi player sinyal evaluatif tanpa angka.

---

## 18. DAILY LOOP

```
START DAY N
  → Tampilkan ringkasan hari (Day N, jumlah pasien baru & kontrol)
  → Untuk setiap pasien (5 total, urutan tetap/acak ringan):
      → Jalankan Investigation System (Section 14)
      → Commit Decision (Section 12, 16)
  → Setelah 5 pasien selesai: End of Day
      → Jalankan onNewDay() untuk seluruh pasien yang punya jadwal kontrol pending (Section 16)
      → Jika ada npc.stability <= 0 → Echo Burst → GAME OVER
      → Jika tidak → lanjut ke Day N+1
END DAY N
```

**Komposisi Pasien per Hari (sesuai brief):**

| Hari | Pasien Baru | Pasien Kontrol | Total |
|---|---|---|---|
| 1 | 5 | 0 | 5 |
| 2 | 3 | 2 | 5 |
| 3 | 3 | 2 | 5 |
| 4 | 3 | 2 | 5 |
| 5 | 3 | 2 | 5 |
| 6 | 2 | 3 | 5 |
| 7 | 0 | 5 | 5 |

---

## 19. GAME FLOW

Lihat diagram lengkap di **Section 34**. Ringkasan tingkat tinggi:

`Main Menu → Intro/Briefing Singkat → Day Loop (1–7) → (Game Over jika Echo Burst) / (Ending jika Day 7 selesai tanpa Burst) → Hasil Akhir / Recap → Main Menu`

---

## 20. UI FLOW

| Screen | Elemen Utama | Transisi |
|---|---|---|
| Main Menu | Judul, tombol Mulai, Keluar, (opsional Credits) | → Briefing |
| Briefing | Teks singkat lore + tombol Mulai Hari 1 | → Ruang Pemeriksaan |
| Ruang Pemeriksaan (Investigasi) | Panel info pasien, viewport Echo/NPC first-person, 6 tombol topik | → Panel Decision setelah 3 topik dipakai |
| Panel Decision | 6 pilihan Emosi Dominan, 3 pilihan Jadwal Kontrol, tombol Submit | → sesi pasien berikutnya / End of Day |
| End of Day Summary | Ringkasan singkat (opsional log/flavour), tombol Lanjut | → Day berikutnya |
| Game Over Screen | Nama pasien yang Echo Burst, hari terjadi, tombol Restart | → Main Menu |
| Ending Screen (Day 7 selesai) | Rekap singkat 7 hari, tombol Restart | → Main Menu |

---

## 21. UX FLOW

Prinsip UX utama:

- **Zero angka eksplisit** di seluruh UI player-facing — semua indikator kondisi disampaikan lewat visual Echo & teks NPC.
- **Tombol topik yang sudah dipakai** langsung disable + visual redup, agar player tidak bingung soal sisa pertanyaan.
- **Counter pertanyaan tersisa** ditampilkan sederhana (mis. "2/3 pertanyaan tersisa") agar player sadar batasan tanpa perlu menghitung sendiri.
- **Tidak ada tombol "undo"** pada Decision System — untuk mempertahankan bobot konsekuensi.
- **Transisi antar pasien** dibuat singkat (fade 1 pasien keluar, pasien baru masuk) agar ritme 5 pasien/hari terasa cepat namun tidak terburu-buru dipaksakan.
- Aksesibilitas dasar: teks dialog dapat di-skip/percepat via klik, ukuran font dapat diperbesar (opsional stretch goal).

---

## 22. SCENE STRUCTURE

MVP hanya memakai **1 scene fisik**: Ruang Pemeriksaan.

**Elemen Scene:**
- Meja pemeriksaan di antara player (kamera first-person statis) dan kursi pasien.
- Area di atas/dekat kepala pasien sebagai tempat render Echo (kabut hitam + elemen visual).
- Latar ruangan minimalis (dinding, satu jendela/pintu, pencahayaan redup-netral) agar fokus visual tetap ke pasien & Echo.
- UI overlay (panel topik, panel decision) muncul sebagai layer di atas scene 3D/2.5D tanpa mengganti scene.

**Variasi Scene Antar-hari:** hanya perubahan pencahayaan/waktu (opsional, mis. lebih temaram menjelang Day 7 untuk membangun tensi), tanpa mengubah geometri ruangan.

---

## 23. ASSET LIST

**Environment:**
- 1 set model ruang pemeriksaan (meja, kursi x2, dinding, pintu/jendela, lampu).
- 1 set pencahayaan (2–3 variasi mood: netral, temaram, tegang).

**Character:**
- 6 Base NPC model/rig (lihat Section 10).
- Variasi kostum ringan (warna baju, aksesori kecil) — bisa material swap, bukan model baru.

**Echo:**
- 1 base mesh/partikel kabut hitam (State 0).
- 6 set elemen visual tambahan (retak, api, akar, mata, lipatan, bayangan kembar) sebagai modular attachment/partikel di atas base mesh.

**UI:**
- Panel info pasien.
- 6 tombol topik + versi disabled.
- Panel Decision (6 tombol emosi + 3 tombol jadwal).
- Panel Day Summary, Game Over, Ending.

**Total perkiraan asset unik:** ~6 NPC + 1 Echo base + 6 modul Echo + 1 ruangan + set UI — realistis untuk timeline 2 minggu bila memakai asset store/base template untuk model dasar dan fokus custom-effort pada Echo & UI (elemen paling unik dari game ini).

---

## 24. ANIMATION LIST

**NPC Animation States** (per-emosi, reusable lintas 6 Base NPC):

| State | Animasi |
|---|---|
| Idle Netral | Duduk tenang, gerakan napas halus |
| Fear Reaction | Bahu naik, tangan menggenggam, mata melirik pintu |
| Anger Reaction | Condong depan, tangan mengepal, rahang keras |
| Sadness Reaction | Kepala menunduk, bahu turun, gerakan lambat |
| Guilt Reaction | Menghindari kontak mata, tangan meremas |
| Shame Reaction | Membungkuk, menutup sebagian wajah/dada |
| Envy Reaction | Melirik ke samping/kosong, senyum tipis tak tulus |
| Masuk/Keluar Ruangan | Animasi duduk & berdiri sederhana |

**Echo Animation States:**

| State | Animasi |
|---|---|
| Idle Kabut (State 0) | Denyut lambat, mengambang halus |
| Fear Buildup | Retak menjalar bertahap + mundur |
| Anger Buildup | Api membesar bertahap + mendekat |
| Sadness Buildup | Akar memanjang bertahap + turun |
| Guilt Buildup | Mata muncul satu-satu |
| Shame Buildup | Melipat & mengecil bertahap + bersembunyi |
| Envy Buildup | Membelah bertahap + condong |

Total animasi inti: 8 NPC states + 7 Echo states — cukup ramping untuk timeline 2 minggu jika dibuat sebagai blend/partikel modular, bukan full keyframe unik per NPC.

---

## 25. AUDIO LIST

| Kategori | Item |
|---|---|
| Ambience | Dengung ruangan pemeriksaan (loop tipis, netral-tegang) |
| SFX Echo | Suara denyut kabut idle; suara retak (Fear); suara desis api (Anger); suara gemerisik akar (Sadness); suara berkedip pelan (Guilt mata); suara kain terlipat (Shame); suara echo/gema ganda (Envy) |
| SFX UI | Klik tombol topik; klik tombol decision; transisi pasien masuk/keluar |
| VO/Dialog (opsional MVP) | Bila waktu memungkinkan: light breathing/vocal stutter per emosi, tanpa VO penuh (teks tetap jadi delivery utama) |
| Music | 1 track ambient loop untuk gameplay (tenang-tegang), 1 track singkat untuk Game Over, 1 track singkat untuk Ending |

---

## 26. TECHNICAL REQUIREMENT

- **Engine yang disarankan:** Unity atau Godot (keduanya cukup ringan untuk scope 1-scene, cocok untuk tim kecil kompetisi 2 minggu).
- **Platform target MVP:** PC (Windows) build, opsional WebGL untuk kemudahan submission kompetisi/itch.io.
- **Rendering:** 2.5D/3D ringan; shader partikel sederhana untuk efek Echo (transparansi + emissive untuk api/mata).
- **Data-driven design:** seluruh data NPC & Echo (Section 28, 29) disimpan dalam file data terpisah (JSON/ScriptableObject) agar programmer dan writer dapat bekerja paralel tanpa menyentuh kode inti.
- **Save system:** tidak wajib untuk MVP (1 sesi bermain selesai dalam sekali duduk), namun disarankan menyimpan state minimal antar hari untuk keperluan testing/QA.
- **Minimum spec target:** setara laptop kantoran umum (integrated graphics), mengingat scene tunggal dan asset rendah-poli.

---

## 27. RANDOMIZATION SYSTEM

Karena hanya 6 Base NPC dan 6 Echo namun dipakai berulang 35 pasien (7 hari x 5), randomisasi diperlukan agar tidak terasa repetitif dan agar replay terasa berbeda.

**Yang Diacak per Playthrough:**
- Kombinasi Base NPC ↔ `trueEmotion` untuk tiap slot pasien baru (dengan constraint: tidak ada 2 pasien baru di hari yang sama memakai `trueEmotion` yang identik, untuk menjaga variasi harian).
- `topicRelevanceMap` di-generate dari template per emosi (Section 15) dengan sedikit variasi posisi Primary/Secondary/Neutral per instance, agar tidak selalu topik yang sama menjadi kunci.
- Pool nama, profesi, dan alasan rujukan per Base NPC (dipilih acak dari daftar per Base NPC yang disiapkan writer).
- `decayRate` dan `misdiagnosisPenalty` diacak dalam rentang tertentu per tingkat kesulitan implisit hari (hari-hari akhir cenderung punya rentang decay lebih tinggi, lihat Section 30).

**Yang TIDAK Diacak (tetap demi keseimbangan desain):**
- Jumlah pasien baru/kontrol per hari (tabel Section 18 tetap).
- Struktur 6 topik dialog tetap (nama topik selalu sama).
- Aturan dasar reaksi Echo per level relevansi (Section 15) tetap sebagai template.

---

## 28. DATA STRUCTURE NPC

```json
{
  "npcInstanceId": "string (unique)",
  "baseNpcId": "NPC-A | NPC-B | NPC-C | NPC-D | NPC-E | NPC-F",
  "displayName": "string",
  "age": "integer",
  "profession": "string",
  "referralReason": "string (flavour text, non-revealing)",
  "trueEmotion": "Fear | Anger | Sadness | Guilt | Shame | Envy",
  "secondaryEmotion": "Enum | null",
  "stability": "integer (0-100)",
  "decayRate": "integer",
  "misdiagnosisPenalty": "integer",
  "topicRelevanceMap": {
    "keluarga": "Primary | Secondary | Neutral | Deflective",
    "pekerjaan": "...",
    "hubungan": "...",
    "masaLalu": "...",
    "penyesalan": "...",
    "masaDepan": "..."
  },
  "dialogLines": {
    "keluarga": "string",
    "pekerjaan": "string",
    "hubungan": "string",
    "masaLalu": "string",
    "penyesalan": "string",
    "masaDepan": "string"
  },
  "scheduleToleranceMap": {
    "besok": "integer",
    "2hari": "integer",
    "3hari": "integer"
  },
  "isControlPatient": "boolean",
  "nextCheckupDay": "integer | null",
  "diagnosisHistory": [
    { "day": "integer", "chosenEmotion": "Enum", "chosenSchedule": "Enum", "wasCorrect": "boolean" }
  ]
}
```

---

## 29. DATA STRUCTURE ECHO

```json
{
  "echoTypeId": "EchoRetak | EchoApi | EchoAkar | EchoMata | EchoLipat | EchoBayanganKembar",
  "linkedEmotion": "Fear | Anger | Sadness | Guilt | Shame | Envy",
  "baseState": {
    "mesh": "fog_base",
    "idleAnimation": "idle_pulse"
  },
  "visualStages": {
    "neutralReaction": { "animation": "string", "intensity": 0.1 },
    "secondaryReaction": { "animation": "string", "intensity": 0.5 },
    "primaryReaction": { "animation": "string", "intensity": 1.0 }
  },
  "audioCues": {
    "neutral": "sfx_id",
    "secondary": "sfx_id",
    "primary": "sfx_id"
  },
  "movementRule": {
    "direction": "away | forward | down | static | split",
    "speed": "float"
  }
}
```

---

## 30. BALANCING

**Prinsip Balancing:**
- Rentang `stability` awal: 40–70 (tidak pernah start di bawah 40 agar player punya ruang bernapas di awal, tidak pernah di atas 70 agar kesalahan tetap punya konsekuensi nyata).
- `decayRate` per hari: 5–15, meningkat menjelang Day 5–7 untuk kasus kontrol yang berulang (menaikkan tensi akhir permainan).
- `misdiagnosisPenalty`: tetap di rentang 20–30 agar satu kesalahan besar tidak otomatis fatal, namun akumulasi 2 kesalahan pada NPC yang sama sangat berisiko.
- `scheduleToleranceMap`: "Besok" memberi buffer terbesar (mis. +20), "2 Hari Lagi" menengah (+10), "3 Hari Lagi" terkecil (+0 hingga +5) — mendorong player mempertimbangkan keparahan tersirat dari dialog/reaksi Echo saat memilih jadwal.
- Distribusi `trueEmotion` per playthrough diusahakan merata (masing-masing 5–6 kemunculan dari 35 total slot pasien) agar semua emosi terwakili dan dapat dipelajari player.

**Playtesting Checklist (untuk QA internal sebelum submission):**
- Apakah mungkin menyelesaikan 7 hari tanpa Echo Burst hanya dengan observasi cermat (tanpa trial-error)?
- Apakah kesalahan diagnosis di Day 1–2 selalu berakibat fatal sebelum Day 7 (terlalu keras) atau nyaris tidak berefek (terlalu longgar)?

---

## 31. REPLAYABILITY

- Randomisasi kombinasi NPC-emosi-topik (Section 27) membuat setiap playthrough punya pola deduksi berbeda meski asset visual sama.
- Variasi hasil akhir (mis. jumlah pasien yang berhasil didiagnosis benar) dapat memicu rasa ingin mengulang untuk "skor sempurna" meski tidak ada leaderboard eksplisit di MVP.
- Potensi tambahan ringan tanpa menambah scope besar: menampilkan rekap akurasi diagnosis di Ending Screen (persentase tebakan benar) sebagai dorongan replay, tanpa memerlukan sistem scoring baru yang kompleks.

---

## 32. MVP SCOPE

**Termasuk dalam MVP:**
- 1 scene ruang pemeriksaan.
- 6 Base NPC, 6 jenis Echo, 6 emosi.
- 35 slot pasien (7 hari x 5) dengan sistem kontrol berulang.
- Sistem dialog 6 topik / pilih 3.
- Sistem reaksi Echo (Primary/Secondary/Neutral/Deflective).
- Decision System (Emosi Dominan + Jadwal Kontrol).
- Internal hidden variables & Echo Burst logic.
- UI dasar (Main Menu, Briefing, Investigasi, Decision, Day Summary, Game Over, Ending).

**Eksplisit TIDAK Termasuk (sesuai batasan brief):**
- Eksplorasi map/multi-scene.
- Combat.
- Inventory/crafting.
- Sistem "boleh pulang" (tanpa kontrol lanjutan).
- Voice acting penuh.
- Leaderboard/skoring kompleks.

---

## 33. FUTURE EXPANSION

*(Bagian ini murni opsional pasca-kompetisi, tidak memengaruhi scope MVP 2 minggu.)*

- Penambahan emosi campuran yang lebih dalam (secondary emotion memengaruhi Echo Burst, bukan hanya naratif).
- Sistem "boleh pulang" bagi pasien yang dinilai stabil, menambah pilihan Decision System.
- Mode Endless/Daily Challenge dengan NPC ter-generate prosedural lebih variatif.
- Cerita arc personal Examiner (mengapa ia bisa melihat Echo).
- Multiple room/scene dengan alat bantu diagnosis tambahan (opsional, tetap mempertahankan filosofi "observasi bukan aksi").

---

## 34. FLOWCHART GAMEPLAY

```
[Main Menu]
     |
     v
[Briefing Singkat]
     |
     v
[Start Day N] <--------------------------------------------+
     |                                                      |
     v                                                      |
[Load Pasien ke-i (i=1..5)]                                 |
     |                                                      |
     v                                                      |
[Render Echo State 0 + Info Pasien]                         |
     |                                                      |
     v                                                      |
[Player pilih Topik] --(counter topik > 0? ya)--> loop ke atas
     |                                                      |
     (counter topik == 0)                                   |
     v                                                      |
[Panel Decision: pilih Emosi Dominan + Jadwal Kontrol]       |
     |                                                      |
     v                                                      |
[Commit Diagnosis -> update stability & nextCheckupDay]      |
     |                                                      |
     v                                                      |
[i == 5? ] --tidak--> [i = i+1] ----------------------------+
     |
    ya
     v
[End of Day: proses onNewDay() untuk semua pasien pending]
     |
     v
[Ada stability <= 0 ?] --ya--> [ECHO BURST] --> [Game Over Screen] --> [Main Menu]
     |
    tidak
     v
[N == 7 ?] --tidak--> [Start Day N+1] (kembali ke atas)
     |
    ya
     v
[Ending Screen: Rekap 7 Hari] --> [Main Menu]
```

---

## 35. STATE MACHINE GAMEPLAY

**A. Global Game State Machine**

```
MAIN_MENU --> BRIEFING --> DAY_LOOP --> (ECHO_BURST | ENDING) --> MAIN_MENU

States:
- MAIN_MENU
- BRIEFING
- DAY_LOOP        (berisi sub-state Section 35B)
- ECHO_BURST      (Game Over)
- ENDING          (Win)
```

**B. Day Loop Sub-State Machine**

```
DAY_START --> PATIENT_SESSION --> (loop 5x) --> DAY_END_PROCESSING --> (DAY_START N+1 | ECHO_BURST | ENDING)

States:
- DAY_START           : inisialisasi urutan 5 pasien hari ini
- PATIENT_SESSION      : berisi sub-state Section 35C
- DAY_END_PROCESSING   : jalankan onNewDay() untuk semua pasien pending
```

**C. Patient Session Sub-State Machine**

```
PATIENT_ENTER --> INVESTIGATION --> DECISION --> PATIENT_EXIT

States:
- PATIENT_ENTER   : load data NPC, render Echo State 0
- INVESTIGATION   : loop pilih topik hingga counter = 0
                    (Sub-state: TOPIC_SELECT -> ECHO_REACT -> cek counter)
- DECISION        : tunggu input Emosi Dominan + Jadwal Kontrol -> commit
- PATIENT_EXIT    : animasi keluar, lanjut ke pasien berikutnya / DAY_END_PROCESSING
```

**D. Echo Visual State Machine (per instance Echo)**

```
STATE_0_FOG --> [topik dipilih & relevan] --> ACCUMULATING --> FINAL_INVESTIGATION_STATE

STATE_0_FOG               : kabut polos, tanpa elemen
ACCUMULATING               : setiap topik relevan menambah 1 elemen visual (akumulatif, tidak hilang)
FINAL_INVESTIGATION_STATE  : state setelah 3 topik terpakai, dasar keputusan player
```

---

## 36. PSEUDOCODE DECISION SYSTEM

```
function onTopicSelected(session, topic):
    if session.topicsUsed >= 3:
        return  // guard: seharusnya UI sudah disable tombol

    relevance = session.npc.topicRelevanceMap[topic]
    reaction = getEchoReaction(session.npc.trueEmotion, relevance)
    playEchoAnimation(session.echoInstance, reaction)
    playNpcBodyLanguage(session.npc.baseNpcId, session.npc.trueEmotion, relevance)
    showDialogText(session.npc.dialogLines[topic])

    session.topicsUsed += 1
    disableTopicButton(topic)

    if session.topicsUsed == 3:
        openDecisionPanel(session)


function getEchoReaction(trueEmotion, relevance):
    switch relevance:
        case Primary:    return REACTION_TABLE[trueEmotion].primary
        case Secondary:  return REACTION_TABLE[trueEmotion].secondary
        case Neutral:    return REACTION_TABLE[trueEmotion].neutral
        case Deflective: return REACTION_TABLE[trueEmotion].deflective


function onDecisionSubmit(session, chosenEmotion, chosenSchedule):
    npc = session.npc

    if chosenEmotion == npc.trueEmotion:
        npc.stability = clamp(npc.stability + RECOVERY_BONUS, 0, 100)
        wasCorrect = true
    else:
        npc.stability = clamp(npc.stability - npc.misdiagnosisPenalty, 0, 100)
        wasCorrect = false

    scheduleDays = scheduleToDays(chosenSchedule)         // besok=1, 2hari=2, 3hari=3
    tolerance    = npc.scheduleToleranceMap[chosenSchedule]

    npc.nextCheckupDay      = currentDay + scheduleDays
    npc.pendingDecayPerDay  = max(npc.decayRate - tolerance, MIN_DECAY)
    npc.isControlPatient    = true

    logDiagnosisHistory(npc, currentDay, chosenEmotion, chosenSchedule, wasCorrect)
    closeDecisionPanel(session)
    proceedToNextPatientOrEndOfDay()


function onNewDay():
    for npc in allPatientsWithPendingCheckup():
        if currentDay < npc.nextCheckupDay:
            npc.stability -= npc.pendingDecayPerDay
            if npc.stability <= 0:
                triggerEchoBurst(npc)
                return GAME_STATE.ECHO_BURST

    if currentDay > 7:
        return GAME_STATE.ENDING

    return GAME_STATE.DAY_START
```

---

## 37. DIAGRAM HUBUNGAN ANTAR SISTEM

```
                +---------------------+
                |   Dialogue System   |
                | (6 topik, pilih 3)  |
                +----------+----------+
                           |
                           v
   +----------------+   memicu   +----------------------+
   |  NPC Data       |---------->|  Echo Reaction Rules  |
   |  (Section 28)   |           |  (Section 15)         |
   +--------+--------+           +-----------+-----------+
            |                                 |
            | menyediakan trueEmotion,        | menentukan
            | topicRelevanceMap                | reaksi visual
            v                                 v
   +----------------+              +----------------------+
   | Decision System |<-------------|   Echo Data           |
   | (Section 12)    | player amati|   (Section 29)         |
   +--------+--------+              +----------------------+
            |
            | commit hasil (benar/salah, jadwal)
            v
   +--------------------------+
   |  Internal Hidden Vars     |
   |  stability, decayRate,    |
   |  nextCheckupDay           |
   |  (Section 16)             |
   +-------------+-------------+
                 |
                 | dievaluasi tiap
                 v
   +--------------------------+       stability<=0        +----------------+
   |     Daily Loop            |-------------------------->|  Echo Burst /  |
   |     (Section 18)          |                            |  Game Over     |
   +-------------+-------------+                            +----------------+
                 |
                 | tidak burst, lanjut
                 v
   +--------------------------+
   |   Randomization System    |
   |   (generate pasien baru    |
   |    hari berikutnya)        |
   |   (Section 27)             |
   +--------------------------+
```

---

## 38. TABEL RULESET MASTER

### 38.1 Tabel Topik → Emosi → Reaksi Echo (Ringkasan Implementasi)

| Emosi | Topik Ideal sebagai Primary (contoh default, dapat diacak sesuai Section 27) | Elemen Visual Primary | Elemen Visual Secondary |
|---|---|---|---|
| Fear | Masa Lalu / Pekerjaan | Retak besar + mundur cepat | Retak tipis + getar |
| Anger | Pekerjaan / Hubungan | Api besar + mendekat | Percikan kecil |
| Sadness | Masa Lalu / Keluarga | Akar tebal + turun signifikan | Akar tipis |
| Guilt | Penyesalan / Masa Lalu | 3+ mata muncul | 1 mata sekilas |
| Shame | Penyesalan / Masa Depan | Melipat penuh + bersembunyi | Melipat sebagian |
| Envy | Hubungan / Masa Depan | Pembelahan jelas + condong | Pembelahan samar |

> Catatan: pemetaan topik-ke-emosi di atas adalah **template default**; instance NPC aktual memakai `topicRelevanceMap` yang di-generate dengan variasi (Section 27) agar tidak selalu topik yang sama menjadi kunci di setiap playthrough.

### 38.2 Tabel Jadwal Kontrol → Efek Numerik

| Jadwal | Hari Ditambahkan | Tolerance/Buffer Stability | Risiko Implisit |
|---|---|---|---|
| Besok | +1 | Tinggi (+20) | Rendah, tapi menyita slot kontrol lebih cepat |
| 2 Hari Lagi | +2 | Sedang (+10) | Sedang |
| 3 Hari Lagi | +3 | Rendah (+0–5) | Tinggi jika emosi asli parah/decay tinggi |

### 38.3 Tabel Hasil Diagnosis → Efek Stability

| Kondisi | Efek Stability |
|---|---|
| Emosi Dominan benar | `+RECOVERY_BONUS` (rekomendasi: +15) |
| Emosi Dominan salah | `-misdiagnosisPenalty` (rekomendasi: -20 s/d -30) |
| Jadwal kontrol lebih longgar dari keparahan asli | Tolerance kecil → decay harian tetap tinggi |
| Jadwal kontrol sesuai/lebih ketat dari keparahan asli | Tolerance besar → decay harian rendah/nol |

### 38.4 Tabel Fail/Win Condition

| Kondisi | Hasil |
|---|---|
| `stability` NPC manapun mencapai ≤0 sebelum `nextCheckupDay` | Echo Burst → Game Over (Section 35A: ECHO_BURST) |
| Day 7 selesai tanpa ada NPC mencapai `stability` ≤0 | Win → Ending Screen (Section 35A: ENDING) |

### 38.5 Tabel Komposisi Pasien per Hari (rujukan silang Section 18)

| Hari | Baru | Kontrol |
|---|---|---|
| 1 | 5 | 0 |
| 2 | 3 | 2 |
| 3 | 3 | 2 |
| 4 | 3 | 2 |
| 5 | 3 | 2 |
| 6 | 2 | 3 |
| 7 | 0 | 5 |

---

*Akhir dokumen. GDD ini disusun sebagai blueprint implementasi untuk tim programmer, artist, UI/UX designer, dan game writer. Seluruh angka pada Section 16, 30, dan 38 (stability, decayRate, penalty, tolerance) adalah rekomendasi awal untuk balancing dan disarankan diuji ulang melalui playtesting internal sebelum submission final kompetisi.*
