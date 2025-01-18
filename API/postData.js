const axios = require("axios");

const disasters = [
  {
    kategori: "Gempa Bumi",
    nama: "Gempa bumi 1.5 Magnitudo",
    lokasi: "Idyllwild, California",
    tanggal: "17-01-2025",
  },
  
  {
    kategori: "Gempa Bumi 6.0",
    nama: "Gempa bumi 6.8 Magnitudo",
    lokasi: "18 km SE of Miyazaki, Jepang",
    tanggal: "13-01-2025",
  },
  
  {
    kategori: "Gempa Bumi 7.0",
    nama: "Gempa bumi 7.1 Magnitudo",
    lokasi: "Southern Tibetan Plateau",
    tanggal: "07-01-2025",
  },
  
  {
    kategori: "Gempa Bumi 8.0",
    nama: "Gempa bumi 8.1 Magnitudo",
    lokasi: " Kepulauan Sandwich Selatan",
    tanggal: "13-08-2021",
  },
  
  {
    kategori: "Gempa Bumi 9.0",
    nama: "Gempa bumi 9.1 Magnitudo",
    Lokasi: "Jepang",
    tanggal: "11-03-2011",
  },
  
  {
    kategori: "Gempa Bumi 9.5",
    nama: "Gempa bumi Estimated 9.5 magnitudo",
    Lokasi: "Lumaco, Chile",
    tanggal: "23-05-1960",
  },
  
  
  
  {
    kategori: "Tsunami",
    nama: "Tsunami setinggi 0.2m",
    lokasi: "Laut Hyuganada",
    tanggal: "13-01-2025",
  },
  
  {
    kategori: "10m High Tsunami",
    nama: "Tsunami setinggi 17m",
    lokasi: "Pedersen Lagoon, Alaska",
    tanggal: "07-08-2024",
  },
  
  {
    kategori: "50m High Tsunami",
    nama: "Tsunami setinggi 200m",
    lokasi: "Dickson Fjord, Greenland",
    tanggal: "16-09-2023",
  },
  
  {
    kategori: "100m High Megatsunami",
    nama: "Tsunami setinggi 200m",
    lokasi: "Dickson Fjord, Greenland",
    tanggal: "16-09-2023",
  },
  
  {
    kategori: "250m High Megatsunami",
    nama: "Tsunami setinggi 250m",
    lokasi: "Washington",
    tanggal: "18-05-1980",
  },
  
  {
    kategori: "500m High Megatsunami",
    nama: "Tsunami setinggi 524.6m",
    lokasi: "Lituya Bay, Alaska",
    tanggal: "10-07-1958",
  },
  
  
  
  {
    kategori: "Solar Flare",
    nama: "Class M1.5 solar flare",
    tanggal: "17-01-2025",
  },
  
  {
    kategori: "Class X1 Solar Flare",
    nama: "Class X1.8 solar flare",
    tanggal: "04-01-2025",
  },
  
  {
    kategori: "Class X5 Solar Flare",
    nama: "Class X5.8 solar flare",
    tanggal: "11-05-2024",
  },
  
  {
    kategori: "Interplanetary Shock",
    nama: "Interplanetary Shock terdeteksi",
    tanggal: "13-01-2025",
  },
  
  {
    kategori: "Geomagnetic Storm",
    nama: "Geomagnetic storm terdeteksi",
    tanggal: "01-01-2025",
  },
  
  {
    kategori: "Strong Geomagnetic Storm",
    nama: "Strong geomagnetic storm terdeteksi",
    tanggal: "01-01-2025",
  },
  
  {
    kategori: "Severe Geomagnetic Storm",
    nama: "Severe geomagnetic storm terdeteksi",
    tanggal: "01-01-2025",
  },
  
  {
    kategori: "Extreme Geomagnetic Storm",
    nama: "Extreme geomagnetic storm",
    tanggal: "28-10-2003",
  },
  
  {
    kategori: "Gravitational Wave",
    nama: "Gravitational wave terdeteksi",
    tanggal: "30-05-2023",
  },
  
  
  
  {
    kategori: "Letusan Vulkanik",
    nama: "Kilauea eruption",
    lokasi: "the Amerika Serikat",
    tanggal: "23-12-2024",
  },
  
  {
    kategori: "Letusan Vulkanik Cataclysmic  (VEI 4)",
    nama: "Fukutoku-Oka-no-Ba eruption",
    lokasi: "Jepang",
    tanggal: "13-08-2021",
  },
  
  {
    kategori: "Letusan Vulkanik Paroxysmal  (VEI 5)",
    nama: "Hunga Tonga-Hunga Ha'apai eruption",
    lokasi: "Tonga",
    tanggal: "20-12-2021",
  },
  
  {
    kategori: "Letusan Vulkanik Colossal  (VEI 6)",
    nama: "Pinatubo eruption",
    lokasi: "the Philippines",
    tanggal: "02-04-1991",
  },
  
  {
    kategori: "Letusan Vulkanik Mega-colossal  (VEI 7)",
    nama: "Mount Tambora eruption",
    lokasi: "Indonesia",
    tanggal: "10-04-1815",
  },
  
  {
    kategori: "Letusan Vulkanik Apocalyptic  (VEI 8)",
    nama: "Oruanui supereruption",
    lokasi: "North Island, New Zealand",
    tanggal: "26,500 tahun lalu",
  },
  
  
  
  {
    kategori: "1 Kiloton Asteroid Impact",
    nama: "3.4 Kt asteroid impact",
    lokasi: "Samudera Pasifik",
    tanggal: "21-12-2024",
  },
  
  {
    kategori: "5 Kiloton Asteroid Impact",
    nama: "5.1 Kt asteroid impact",
    tanggal: "20-07-2024",
  },
  
  {
    kategori: "25 Kiloton Asteroid Impact",
    nama: "49 Kt asteroid impact",
    lokasi: "Laut Bering",
    tanggal: "19-12-2018",
  },
  
  {
    kategori: "100 Kiloton Asteroid Impact",
    nama: "440 Kt asteroid impact",
    lokasi: "Chelyabinsk Obnama, Russia",
    tanggal: "15-02-2013",
  },
  
  {
    kategori: "Megaton Asteroid Impact",
    nama: "12 Mt asteroid impact",
    lokasi: "Russia",
    tanggal: "30-06-1908",
  },
  
  {
    kategori: "Gigaton Asteroid Impact",
    nama: "2.3 Gt asteroid impact",
    lokasi: "Kazakhstan",
    tanggal: "900,000 tahun lalu",
  },
  
  {
    kategori: "Teraton Asteroid Impact",
    nama: "1.75 Tt asteroid impact",
    lokasi: "Chesapeake Bay, Virginia",
    tanggal: "35 juta tahun lalu",
  },
  
  
  
  {
    kategori: "Typhoon",
    nama: "Typhoon Usagi",
    lokasi: "Laut Filipina Timur",
    tanggal: "09-11-2024",
  },
  
  {
    kategori: "Super Typhoon",
    nama: "Super Typhoon Man-yi",
    lokasi: "timur Atol Kwajalein, Filipina",
    tanggal: "09-11-2024",
  },
  
  {
    kategori: "Badai Kategori 1",
    nama: "Badai Kategori 1 Oscar",
    lokasi: "Samudera Atlantik",
    tanggal: "19-10-2024",
  },
  
  {
    kategori: "Badai Kategori 2",
    nama: "Badai Kategori 2 Leslie",
    lokasi: "Samudera Atlantik",
    tanggal: "02-10-2024",
  },
  
  {
    kategori: "Badai Kategori 3",
    nama: "Badai Kategori 3 Calvin",
    lokasi: "Samudera Atlantik",
    tanggal: "11-07-2023",
  },
  
  {
    kategori: "Badai Kategori 4",
    nama: "Badai Kategori 4 Kirk",
    lokasi: "Samudera Atlantik",
    tanggal: "29-09-2024",
  },
  
  {
    kategori: "Badai Kategori 5",
    nama: "Badai Kategori 5 Milton",
    lokasi: "Laut Karibia Barat",
    tanggal: "05-10-2024",
  },
  
  {
    kategori: "Tornado EF4",
    nama: "Tornado EF4",
    lokasi: "Iowa, Amerika Serikat",
    tanggal: "31-03-2023",
  },
  
  {
    kategori: "Tornado EF5",
    nama: "Tornado EF5",
    lokasi: "Oklahoma, Amerika Serikat",
    tanggal: "20-05-2013",
  },
  
  
  {
    kategori: "Kecelakaan Nuklir Besar",
    nama: "Bencana Nuklir Fukushima",
    lokasi: "Jepang",
    tanggal: "11-03-2011",
  },
  
  {
    kategori: "Senjata Nuklir Diluncurkan",
    nama: "Fat Man",
    lokasi: "Nagashaki, Jepang",
    tanggal: "09-08-1945"
  },
];

async function postDisaster(disaster) {
  try {
    const response = await axios.post(
      "http://localhost:3000/api/bencana",
      disaster
    );
    console.log(`Successfully posted: ${disaster.nama}`);
    return response.data;
  } catch (error) {
    console.error(`Error posting ${disaster.nama}:`, error.message);
  }
}

async function postAllDisasters() {
  for (const disaster of disasters) {
    await postDisaster(disaster);
  }
}

postAllDisasters()
  .then(() => console.log("All disasters posted"))
  .catch((err) => console.error("Error in main execution:", err));
