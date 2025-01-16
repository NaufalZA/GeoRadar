const axios = require("axios");

const disasters = [
  {
    kategori: "Earthquake",
    nama: "Magnitude 1.0 Earthquake",
    lokasi: "58 km W of Anchor Point, Alaska",
    tanggal: "16 Januari 2025",
  },
  {
    kategori: "Earthquake",
    nama: "Magnitude 6.8 Earthquake",
    lokasi: "18 km SE of Miyazaki, Japan",
    tanggal: "13 Januari 2025",
  },
  {
    kategori: "Tsunami",
    nama: "0.2m High Tsunami",
    lokasi: "Hyuganada Sea",
    tanggal: "13 Januari 2025",
  },
  {
    kategori: "Interplanetary Shock",
    nama: "Interplanetary Shock",
    tanggal: "13 Januari 2025",
  },
  {
    kategori: "Solar Flare",
    nama: "Class C2.8 Solar Flare",
    tanggal: "11 Januari 2025",
  },
  {
    kategori: "Earthquake",
    nama: "Magnitude 7.1 Earthquake (Southern Tibetan Plateau)",
    tanggal: "7 Januari 2025",
  },
  {
    kategori: "Solar Flare",
    nama: "Class X1.8 Solar Flare",
    tanggal: "4 Januari 2025",
  },
  {
    kategori: "Geomagnetic Storm",
    nama: "Geomagnetic Storm",
    tanggal: "1 Januari 2025",
  },
  {
    kategori: "Strong Geomagnetic Storm",
    nama: "Strong Geomagnetic Storm",
    tanggal: "1 Januari 2025",
  },
  {
    kategori: "Severe Geomagnetic Storm",
    nama: "Severe Geomagnetic Storm",
    tanggal: "1 Januari 2025",
  },
  {
    kategori: "Volcanic Eruption",
    nama: "Kilauea Eruption",
    lokasi: "United States",
    tanggal: "23 Desember 2024",
  },
  {
    kategori: "Kiloton Asteroid Impact",
    nama: "3.4kt Asteroid Impact",
    lokasi: "Pacific Ocean",
    tanggal: "21 Desember 2024",
  },
  {
    kategori: "Typhoon",
    nama: "Typhoon Usagi",
    tanggal: "9 November 2024",
  },
  {
    kategori: "Super Typhoon",
    nama: "Super Typhoon Man-yi",
    tanggal: "9 November 2024",
  },
  {
    kategori: "Category 1 Hurricane",
    nama: "Category 1 Hurricane Oscar",
    tanggal: "19 Oktober 2024",
  },
  {
    kategori: "Category 5 Hurricane",
    nama: "Category 5 Hurricane Milton",
    tanggal: "5 Oktober 2024",
  },
  {
    kategori: "Category 2 Hurricane",
    nama: "Category 2 Hurricane Leslie",
    tanggal: "2 Oktober 2024",
  },
  {
    kategori: "Category 4 Hurricane",
    nama: "Category 4 Hurricane Kirk",
    tanggal: "29 September 2024",
  },
  {
    kategori: "Tsunami",
    nama: "17m High Tsunami",
    lokasi: "Pedersen Lagoon, Alaska",
    tanggal: "7 Agustus 2024",
  },
  {
    kategori: "Kiloton Asteroid Impact",
    nama: "5.1kt Asteroid Impact",
    tanggal: "20 Juli 2024",
  },
  {
    kategori: "Solar Flare",
    nama: "Class X5.8 Solar Flare",
    tanggal: "11 Mei 2024",
  },
  {
    kategori: "Extreme Geomagnetic Storm",
    nama: "Extreme Geomagnetic Storm",
    tanggal: "28 Oktober 2003",
  },
  {
    kategori: "Tsunami",
    nama: "200m High Tsunami",
    lokasi: "Dickson Fjord, Greenland",
    tanggal: "16 September 2023",
  },
  {
    kategori: "Tsunami",
    nama: "200m High Megatsunami",
    lokasi: "Dickson Fjord, Greenland",
    tanggal: "16 September 2023",
  },
  {
    kategori: "Category 3 Hurricane",
    nama: "Category 3 Hurricane Calvin",
    tanggal: "11 Juli 2023",
  },
  {
    kategori: "Gravitational Wave Detected",
    nama: "Gravitational Wave",
    tanggal: "30 Mei 2023",
  },
  {
    kategori: "EF4 Tornado",
    nama: "EF4 Tornado",
    lokasi: "Iowa, United States",
    tanggal: "31 Maret 2023",
  },
  {
    kategori: "Paroxysmal Volcanic Eruption (VEI 5)",
    nama: "Hunga Tonga-Hunga Ha'apai Eruption",
    lokasi: "Tonga",
    tanggal: "20 Desember 2021",
  },
  {
    kategori: "Cataclysmic Volcanic Eruption (VEI 4)",
    nama: "Fukutoku-Oka-no-Ba Eruption",
    lokasi: "Japan",
    tanggal: "13 Agustus 2021",
  },
  {
    kategori: "Earthquake",
    nama: "Magnitude 8.1 Earthquake",
    lokasi: "South Sandwich Islands Region",
    tanggal: "13 Agustus 2021",
  },
  {
    kategori: "Kiloton Asteroid Impact",
    nama: "49kt Asteroid Impact",
    lokasi: "Bering Sea",
    tanggal: "19 Desember 2018",
  },
  {
    kategori: "EF5 Tornado",
    nama: "EF5 Tornado",
    lokasi: "Oklahoma, United States",
    tanggal: "20 Mei 2013",
  },
  {
    kategori: "Kiloton Asteroid Impact",
    nama: "440kt Asteroid Impact",
    lokasi: "Chelyabinsk Oblast, Russia",
    tanggal: "15 Februari 2013",
  },
  {
    kategori: "Major Nuclear Accident",
    nama: "Fukushima Nuclear Disaster",
    lokasi: "Japan",
    tanggal: "11 Maret 2011",
  },
  {
    kategori: "Earthquake",
    nama: "Magnitude 9.1 Earthquake",
    lokasi: "East Coast of Japan",
    tanggal: "11 Maret 2011",
  },
  {
    kategori: "Colossal Volcanic Eruption (VEI 6)",
    nama: "Pinatubo Eruption",
    lokasi: "Philippines",
    tanggal: "2 April 1991",
  },
  {
    kategori: "Nuclear Weapon Lost",
    nama: "Lost Nuclear Warheads",
    lokasi: "Bear Island",
    tanggal: "7 April 1989",
  },
  {
    kategori: "Tsunami",
    nama: "250m High Megatsunami",
    lokasi: "Washington",
    tanggal: "18 Mei 1980",
  },
  {
    kategori: "Earthquake",
    nama: "Estimated Magnitude 9.5 Earthquake",
    lokasi: "Near Lumaco, Chile",
    tanggal: "23 Mei 1960",
  },
  {
    kategori: "Tsunami",
    nama: "524.6m High Megatsunami",
    lokasi: "Lituya Bay, Alaska",
    tanggal: "10 Juli 1958",
  },
  {
    kategori: "Megaton Asteroid Impact",
    nama: "12Mt Asteroid Impact (Tunguska Event)",
    lokasi: "Russia",
    tanggal: "30 Juni 1908",
  },
  {
    kategori: "Mega-colossal Volcanic Eruption (VEI 7)",
    nama: "Mount Tambora Eruption",
    lokasi: "Indonesia",
    tanggal: "10 April 1815",
  },
  {
    kategori: "Apocalyptic Volcanic Eruption (VEI 8)",
    nama: "Oruanui Supereruption",
    lokasi: "North Island, New Zealand",
    tanggal: "26,500 years ago",
  },
  {
    kategori: "Gigaton Asteroid Impact",
    nama: "2.3Gt Asteroid Impact",
    lokasi: "Kazakhstan",
    tanggal: "900,000 years ago",
  },
  {
    kategori: "Teraton Asteroid Impact",
    nama: "1.75Tt Asteroid Impact",
    lokasi: "Chesapeake Bay, Virginia",
    tanggal: "35 million years ago",
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
