const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors'); 
const app = express();

app.use(cors()); 
app.use(express.json());

mongoose.connect('mongodb+srv://root:Agista0605.@bencana.kljwf.mongodb.net/Bencana')

const dataSchema = new mongoose.Schema({
    kategori: {
        type: String,
        required: true,
        enum: ['Gempa', 'Tsunami', 'Megaton Asteroid Impact', 'Volcanic Eruption', 'Nuclear Disaster']
    },
    nama: {
        type: String,
        required: true
    },
    lokasi: {
        type: String,
        required: true
    },
    deskripsi: {
        type: String,
        required: true
    },
    timestamp: { type: Date, default: Date.now }
}, { versionKey: false });
const dataModel = mongoose.model('data', dataSchema);

app.get('/api/bencana', async (req, res) => {
    try {
        const data = await dataModel.find().sort({ timestamp: -1 });
        const formattedData = data.map(item => ({
            kategori: item.kategori,
            nama: item.nama,
            lokasi: item.lokasi,
            deskripsi: item.deskripsi,
            timestamp: new Date(item.timestamp).toLocaleString("id-ID", { 
                timeZone: "Asia/Jakarta" 
            }).replace(/\//g, '-').replace(/\./g, ':')
        }));
        res.json(formattedData);
    } catch (error) {
        res.status(500).json({ error: 'Gagal mengambil data' });
    }
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});

