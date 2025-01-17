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
    tanggal: { 
        type: String, 
        required: false,
        default: () => new Date().toLocaleString("id-ID", { 
            timeZone: "Asia/Jakarta" 
        }).replace(/\//g, '-').replace(/\./g, ':')
    },
    kategori: {
        type: String,
        required: true,
        enum: [
            // Earthquakes
            'Earthquake',
            'Magnitude 6.0 Earthquake',
            'Magnitude 7.0 Earthquake',
            'Magnitude 8.0 Earthquake',
            'Magnitude 9.0 Earthquake',
            'Magnitude 9.5 Earthquake',
            
            // Tsunamis
            'Tsunami',
            '10m High Tsunami',
            '50m High Tsunami',
            '100m High Megatsunami',
            '250 High Megatsunami',
            '500m High Megatsunami',
            
            // Solar and Space Events
            'Solar Flare',
            'Class X1 Solar Flare',
            'Class X5 Solar Flare',
            'Interplanetary Shock',
            'Geomagnetic Storm',
            'Strong Geomagnetic Storm',
            'Severe Geomagnetic Storm',
            'Extreme Geomagnetic Storm',
            'Gravitational Wave Detected',
            
            // Volcanic Events
            'Volcanic Eruption',
            'Cataclysmic Volcanic Eruption (VEI 4)',
            'Paroxysmal Volcanic Eruption (VEI 5)',
            'Colossal Volcanic Eruption (VEI 6)',
            'Mega-colossal Volcanic Eruption (VEI 7)',
            'Apocalyptic Volcanic Eruption (VEI 8)',
            
            // Asteroid Impacts
            '1 Kiloton Asteroid Impact',
            '5 Kiloton Asteroid Impact',
            '25 Kiloton Asteroid Impact',
            '100 Kiloton Asteroid Impact',
            'Megaton Asteroid Impact',
            'Gigaton Asteroid Impact',
            'Teraton Asteroid Impact',
            
            // Weather Events
            'Typhoon',
            'Super Typhoon',
            'Category 1 Hurricane',
            'Category 2 Hurricane',
            'Category 3 Hurricane',
            'Category 4 Hurricane',
            'Category 5 Hurricane',
            'EF4 Tornado',
            'EF5 Tornado',
            
            // Nuclear Events
            'Major Nuclear Accident',
            'Nuclear Weapon Lost'
        ]
    }
}, { 
    versionKey: false 
});
const dataModel = mongoose.model('data', dataSchema);

app.get('/api/bencana', async (req, res) => {
    try {
        const data = await dataModel.find().sort({ tanggal: -1 });
        const formattedData = data.map(item => ({
            kategori: item.kategori,
            nama: item.nama,
            lokasi: item.lokasi,
            deskripsi: item.deskripsi,
            tanggal: new Date(item.tanggal).toLocaleString("id-ID", { 
                timeZone: "Asia/Jakarta" 
            }).replace(/\//g, '-').replace(/\./g, ':')
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
        if (!kategori || !nama) {
            return res.status(400).json({ error: 'Kategori dan nama harus diisi' });
        }

        // Create new record with optional fields
        const newData = new dataModel({
            kategori,
            nama,
            ...(tanggal && { tanggal }), // Include tanggal if provided
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