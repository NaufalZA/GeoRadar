const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); 
const app = express();

app.use(cors()); 
app.use(express.json());

mongoose.connect('mongodb+srv://root:Agista0605.@bencana.kljwf.mongodb.net/Bencana')

const dataSchema = new mongoose.Schema({
    nama: { type: String, required: true },
    lokasi: { type: String, required: false }, // Make lokasi optional
    deskripsi: { type: String, required: false }, // Make deskripsi optional
    tanggal: { type: String, required: true },
    kategori: {
        type: String,
        required: true,
        enum: [
            'Earthquake', 'Tsunami', 'Interplanetary Shock', 'Solar Flare',
            'Geomagnetic Storm', 'Strong Geomagnetic Storm', 'Severe Geomagnetic Storm',
            'Volcanic Eruption', 'Kiloton Asteroid Impact', 'Typhoon', 'Super Typhoon',
            'Category 1 Hurricane', 'Category 2 Hurricane', 'Category 3 Hurricane',
            'Category 4 Hurricane', 'Category 5 Hurricane', 'Gravitational Wave Detected',
            'EF4 Tornado', 'EF5 Tornado', 'Major Nuclear Accident', 'Nuclear Weapon Lost',
            'Paroxysmal Volcanic Eruption (VEI 5)', 'Cataclysmic Volcanic Eruption (VEI 4)',
            'Colossal Volcanic Eruption (VEI 6)', 'Mega-colossal Volcanic Eruption (VEI 7)',
            'Apocalyptic Volcanic Eruption (VEI 8)', 'Megaton Asteroid Impact',
            'Gigaton Asteroid Impact', 'Teraton Asteroid Impact'
        ]
    }
}, { 
    versionKey: false 
});
const dataModel = mongoose.model('data', dataSchema);

app.get('/api/bencana', async (req, res) => {
    try {
        const data = await dataModel.find().sort({ _id: -1 });
        const formattedData = data.map(item => ({
            kategori: item.kategori,
            nama: item.nama,
            lokasi: item.lokasi,
            deskripsi: item.deskripsi,
            tanggal: item.tanggal
        }));
        res.json(formattedData);
    } catch (error) {
        res.status(500).json({ error: 'Gagal mengambil data' });
    }
});

app.post('/api/bencana', async (req, res) => {
    try {
        const { kategori, nama, lokasi, deskripsi, tanggal } = req.body;
        
        // Validate required fields only
        if (!kategori || !nama || !tanggal) {
            return res.status(400).json({ error: 'Kategori, nama, dan tanggal harus diisi' });
        }

        // Create new record with optional fields
        const newData = new dataModel({
            kategori,
            nama,
            tanggal,
            ...(lokasi && { lokasi }), // Include lokasi if provided
            ...(deskripsi && { deskripsi }) // Include deskripsi if provided
        });

        await newData.save();
        res.status(201).json({ message: 'Data berhasil disimpan', data: newData });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Gagal menyimpan data', details: error.message });
    }
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});