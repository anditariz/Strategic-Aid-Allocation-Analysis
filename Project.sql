/* BAB 1 
*/

/* Seluruh Tabel*/
select*
from `my-project-ppkd.Project_Pelatihan.country_data`;


/* Tugas 1.1 (Profil Kesenjangan Ekonomi): 
*/
/* Total negara dan rentang kekayaan (GDP Minimal dan Maksimal).*/
SELECT 
    COUNT(country) AS total_negara,
    MIN(gdpp) AS gdp_minimal,
    MAX(gdpp) AS gdp_maksimal
FROM `my-project-ppkd.Project_Pelatihan.country_data`;

/* Negara dengan GDP terkecil */
SELECT country, gdpp 
FROM `my-project-ppkd.Project_Pelatihan.country_data`
ORDER BY gdpp ASC 
LIMIT 1;

/* Negara dengan GDP terbesar */
SELECT country, gdpp 
FROM `my-project-ppkd.Project_Pelatihan.country_data`
ORDER BY gdpp DESC 
LIMIT 1;


/* Tugas 1.2 (Analisis Tingkat Fertilitas):
*/
/* Identifikasi 5 negara dengan tingkat kesuburan tertinggi.*/
SELECT country, total_fer
FROM `my-project-ppkd.Project_Pelatihan.country_data`
ORDER BY total_fer DESC
LIMIT 5;


/* Tugas 1.3 (Analisis Harapan Hidup): 
*/
/* Daftar 5 negara dengan angka harapan hidup terendah.*/
SELECT country, life_expec
FROM `my-project-ppkd.Project_Pelatihan.country_data`
ORDER BY life_expec ASC
LIMIT 5;



/* Tugas 1.4 (Identifikasi Inflasi Tinggi): 
*/
/* Cari 5 negara dengan tingkat inflasi tertinggi untukmengukur stabilitas ekonomi.*/
SELECT country, inflation
FROM `my-project-ppkd.Project_Pelatihan.country_data`
ORDER BY inflation DESC
LIMIT 5;


/* Tugas 1.5 (Hubungan Pendapatan dan Kesehatan): 

*/
/* Bandingkan 5 negara dengan pendapatan tertinggi terhadap 5 negara dengan angka kematian anak terendah.*/

/* Tabel Gabungan*/
(SELECT 'Top Income' AS kategori, country, income, child_mort
 FROM `my-project-ppkd.Project_Pelatihan.country_data`
 ORDER BY income DESC
 LIMIT 5)
 UNION ALL
(SELECT 'Lowest Child Mortality' AS kategori, country, income, child_mort
 FROM `my-project-ppkd.Project_Pelatihan.country_data`
 ORDER BY child_mort ASC
 LIMIT 5);

/* Perbandingan Berdampingan*/
WITH income AS (
    SELECT 
        country, 
        income
    FROM `my-project-ppkd.Project_Pelatihan.country_data`
    ORDER BY income DESC
    LIMIT 5
),
child_mortality AS (
    SELECT 
        country, 
        child_mort
    FROM `my-project-ppkd.Project_Pelatihan.country_data`
    ORDER BY child_mort ASC
    LIMIT 5
)
SELECT 
    i.country AS Top_Income,
    i.income,
    c.country AS Lowest_Child_Mortality,
    c.child_mort
FROM income i
FULL JOIN child_mortality c
ON i.country = c.country;



/* BAB 2 
*/
/* Tugas 2.1 (Konversi Anggaran Kesehatan ke USD): 
*/
/* Hitung pengeluaran kesehatan aktual per orang dalam mata uang USD. Rumus: (health / 100) * gdpp.*/
SELECT 
    country, 
    gdpp, 
    health AS health_percentage,
    round((health / 100) * gdpp, 2) AS health_usd
FROM `my-project-ppkd.Project_Pelatihan.country_data`
ORDER BY health_usd DESC;


/* Tugas 2.2 (Analisis Neraca Perdagangan):
*/
/* Hitung selisih ekspor dan impor dalam USD Rumus: (exports - imports) * (gdpp / 100).
Jika hasilnya positif, berarti negara tersebut mengalami Surplus perdagangan. Jika negatif, berarti Defisit.*/

/*Menampilan Seluruh Negara*/
SELECT 
    country,
    exports AS ekspor_persen,
    imports AS impor_persen,
    gdpp,
    ROUND(((exports - imports) * (gdpp / 100)), 2) AS selisih_ekspor_usd,
    CASE
        WHEN (exports - imports) * (gdpp / 100) > 0 THEN 'Surplus'
        WHEN (exports - imports) * (gdpp / 100) < 0 THEN 'Defisit'
        ELSE 'Seimbang'
    END AS status_perdagangan
FROM `my-project-ppkd.Project_Pelatihan.country_data`
WHERE (exports - imports) * (gdpp / 100) <> 0
ORDER BY selisih_ekspor_usd DESC;

/*Negara dengan hasil selisih negatif/defisit*/
SELECT 
    country,
    exports AS ekspor_persen,
    imports AS impor_persen,
    gdpp,
    ROUND(((exports - imports) * (gdpp / 100)), 2) AS selisih_ekspor_usd,
    'Defisit' AS status_perdagangan
FROM `my-project-ppkd.Project_Pelatihan.country_data`
WHERE (exports - imports) * (gdpp / 100) < 0
ORDER BY selisih_ekspor_usd ASC;


/* Tugas 2.3 (Perbandingan Produksi vs Pendapatan): 
/*
/* Hitung selisih antara nilai produksi negara (GDP) dan pendapatan aktual warga negaranya (Income).
GDP > Income (Hasil Positif): Sering terjadi di negara dengan banyak investasi asing atau perusahaan multinasional besar (seperti Luxembourg atau Irlandia). Produksi di sana sangat tinggi, tapi sebagian keuntungannya dikirim kembali ke negara asal perusahaan tersebut.

Income > GDP (Hasil Negatif): Sering terjadi di negara yang warganya banyak bekerja di luar negeri dan mengirimkan uang kembali ke rumah (remittance), atau negara yang memiliki banyak investasi di luar negeri (seperti Kuwait atau Qatar pada beberapa periode).*/

SELECT 
    country,
    gdpp,
    income,
    (gdpp - income) AS selisih_gdp_income,
    ROUND(((gdpp - income) / gdpp) * 100, 2) AS persentase_selisih
FROM `my-project-ppkd.Project_Pelatihan.country_data`
ORDER BY selisih_gdp_income DESC;



/* BAB 3
*/
/* Tugas 3.1 (Segmentasi Tingkat Ekonomi): 
Kategorikan negara menjadi Rendah (<$2000), Menengah ($2000-$10000), dan Tinggi (>$10000) berdasarkan GDP. Hitung rata-rata angka kematian anak untuk setiap kategori.*/
SELECT 
    CASE 
        WHEN gdpp < 2000 THEN 'Rendah (<$2000)'
        WHEN gdpp BETWEEN 2000 AND 10000 THEN 'Menengah ($2000-$10000)'
        ELSE 'Tinggi (>$10000)'
    END AS kategori_gdp,
    COUNT(*) AS jumlah_negara,
    ROUND(AVG(child_mort), 2) AS rata_rata_kematian_anak
FROM `my-project-ppkd.Project_Pelatihan.country_data`
GROUP BY kategori_gdp
ORDER BY AVG(gdpp) ASC;


/* Tugas 3.2 (Segmentasi Tingkat Fertilitas): 
Kategorikan berdasarkan angka kesuburan: Rendah (<2), Menengah (2-4), dan Tinggi (>4). Hitung rata-rata pendapatan warga untuk kelompok Tinggi.*/

/*Ketegori & Jumlah Negara*/
SELECT 
    CASE 
        WHEN total_fer < 2 THEN 'Rendah (<2)'
        WHEN total_fer BETWEEN 2 AND 4 THEN 'Menengah (2-4)'
        ELSE 'Tinggi (>4)'
    END AS kategori_kesuburan,
    COUNT(*) AS jumlah_negara,
FROM `my-project-ppkd.Project_Pelatihan.country_data`
GROUP BY kategori_kesuburan
ORDER BY AVG(total_fer) ASC;

/* Kategori, Jumlah Negara & Rata-Rata*/
SELECT 
    CASE 
        WHEN total_fer < 2 THEN 'Rendah (<2)'
        WHEN total_fer BETWEEN 2 AND 4 THEN 'Menengah (2-4)'
        ELSE 'Tinggi (>4)'
    END AS kategori_kesuburan,
    COUNT(*) AS jumlah_negara,
    ROUND(AVG(income), 2) AS rata_rata_pendapatan
FROM `my-project-ppkd.Project_Pelatihan.country_data`
GROUP BY kategori_kesuburan
ORDER BY rata_rata_pendapatan DESC;

/* Rata-rata GDP Kel Tinggi*/
SELECT 
    CASE 
        WHEN total_fer < 2 THEN 'Rendah (<2)'
        WHEN total_fer BETWEEN 2 AND 4 THEN 'Menengah (2-4)'
        ELSE 'Tinggi (>4)'
    END AS kategori_kesuburan,
    COUNT(*) AS jumlah_negara,
    ROUND(AVG(income), 2) AS rata_rata_pendapatan
FROM `my-project-ppkd.Project_Pelatihan.country_data`
GROUP BY kategori_kesuburan
HAVING kategori_kesuburan = 'Tinggi (>4)';


/*Tugas 3.3 (Dampak Inflasi terhadap Harapan Hidup): 
Kategorikan inflasi menjadi Stabil (<5%), Moderat (5-15%), dan Tinggi (>15%). Hitung rata-rata harapan hidup untuk masing-masing kelompok tersebut.*/

SELECT
  CASE
    WHEN inflation < 5 THEN 'Stabil (<5%)'
    WHEN inflation BETWEEN 5 AND 15 THEN 'Moderat (5–15%)'
    ELSE 'Tinggi (>15%)'
    END AS kategori_inflasi,
    COUNT(*) AS jumlah_negara,
    ROUND (AVG(life_expec),2) AS rata_rata_harapan_hidup
FROM `my-project-ppkd.Project_Pelatihan.country_data`
GROUP BY kategori_inflasi
ORDER BY rata_rata_harapan_hidup;


/* BAB 4
*/
/*Tugas 4.1 (Menentukan Ambang Batas Statistik):
Nilai Persentil ke-25 dari gdpp (ambang batas kemiskinan).*/
SELECT
  APPROX_QUANTILES(gdpp, 100)[OFFSET(25)] AS gdpp_p25
FROM `my-project-ppkd.Project_Pelatihan.country_data`;


/*Nilai Persentil ke-75 dari child_mort (ambang batas krisis kesehatan/kematian anak).*/
SELECT
  APPROX_QUANTILES(child_mort, 100)[OFFSET(75)] AS child_mort_p75
FROM `my-project-ppkd.Project_Pelatihan.country_data`;


/*Tugas 4.2 (Filtrasi Negara Prioritas): 
Tulis query untuk menemukan negara yang berada di bawah ambang batas GDP (Tugas 4.1) DAN di atas ambang batas kematian anak (Tugas 4.1). Ini adalah daftar negara yang berada di "Zona Merah".*/

WITH ambang_batas AS (
  SELECT
    APPROX_QUANTILES(gdpp, 100)[OFFSET(25)] AS gdpp_p25,
    APPROX_QUANTILES(child_mort, 100)[OFFSET(75)] AS child_mort_p75
  FROM `my-project-ppkd.Project_Pelatihan.country_data`
)

SELECT
  country,
  gdpp,
  child_mort
FROM `my-project-ppkd.Project_Pelatihan.country_data`,
     ambang_batas
WHERE gdpp < ambang_batas.gdpp_p25
  AND child_mort > ambang_batas.child_mort_p75
ORDER BY child_mort DESC;


/*BAB 5
10 negara dengan angka harapan hidup terendah secara absolut.*/
WITH ambang_batas AS (
  SELECT
    APPROX_QUANTILES(gdpp, 100)[OFFSET(25)] AS gdpp_p25,
    APPROX_QUANTILES(child_mort, 100)[OFFSET(75)] AS child_mort_p75
  FROM `my-project-ppkd.Project_Pelatihan.country_data`
),
zona_merah AS (
  SELECT
    country,
    gdpp,
    child_mort,
    life_expec
  FROM `my-project-ppkd.Project_Pelatihan.country_data`,
       ambang_batas
  WHERE gdpp < ambang_batas.gdpp_p25
    AND child_mort > ambang_batas.child_mort_p75
)

SELECT
  country,
  gdpp,
  child_mort,
  life_expec
FROM zona_merah
ORDER BY life_expec ASC
LIMIT 10;

