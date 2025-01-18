const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); 
const axios = require('axios'); // Add this line
const app = express();

app.use(cors()); 
app.use(express.json());

mongoose.connect('mongodb+srv://root:Agista0605.@bencana.kljwf.mongodb.net/Bencana')

const dataSchema = new mongoose.Schema({
    kategori: {type: String, required: true},
    nama: { type: String, required: true },
    lokasi: { type: String, required: false }, // Make lokasi optional
    tanggal: { 
        type: String, 
        required: false,
        default: () => {
            const today = new Date();
            return `${today.getDate()}-${today.getMonth() + 1}-${today.getFullYear()}`;
        }
    }
}, { 
    versionKey: false 
});
const dataModel = mongoose.model('data', dataSchema);

app.get('/api/gempa', async (req, res) => {
    try {
        const response = await axios.get('https://data.bmkg.go.id/DataMKG/TEWS/gempadirasakan.json');
        const earthquakes = response.data.Infogempa.gempa;
        
        const magnitudes = earthquakes.map(quake => parseFloat(quake.Magnitude));
        const avgMagnitude = magnitudes.reduce((a, b) => a + b, 0) / magnitudes.length;
        
        const depths = earthquakes.map(quake => parseInt(quake.Kedalaman.replace(' km', '')));
        const avgDepth = depths.reduce((a, b) => a + b, 0) / depths.length;
        
        const processedData = {
            averageMagnitude: avgMagnitude.toFixed(2),
            averageDepth: avgDepth.toFixed(2) + ' km',
        };
        
        res.json(processedData);
    } catch (error) {
        console.error('Error fetching BMKG data:', error);
        res.status(500).json({ error: 'Gagal mengambil data BMKG' });
    }
});

app.get('/api/bencana', async (req, res) => {
    try {
        const data = await dataModel.find();
        res.json(data);
    } catch (error) {
        res.status(500).json({ error: 'Gagal mengambil data' });
    }
});

app.post('/api/bencana', async (req, res) => {
    try {
        const { kategori, nama, lokasi, tanggal } = req.body;
        
        if (!kategori || !nama) {
            return res.status(400).json({ error: 'Kategori dan nama harus diisi' });
        }

        const newData = new dataModel({
            kategori,
            nama,
            ...(lokasi && { lokasi }), 
            ...(tanggal && { tanggal })
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