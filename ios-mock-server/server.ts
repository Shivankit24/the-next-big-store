import express, { type Request, type Response } from 'express';
import axios from 'axios';

// Load optional local configuration from .env (see .env.example). Real
// environment variables win, and defaults below keep it running without a file.
try {
    process.loadEnvFile();
} catch {
    // No .env file: fall back to defaults.
}

const port = Number(process.env.PORT ?? 3000);
const fakeStoreBaseUrl = process.env.FAKE_STORE_API_BASE_URL ?? 'https://fakestoreapi.com';

const app = express();

// Endpoint 1: Get all products
app.get('/products', async (_req: Request, res: Response) => {
    try {
        const externalApiResponse = await axios.get(`${fakeStoreBaseUrl}/products`);
        
        console.log("--- SUCCESS: Data received from Products API ---");
        console.log(externalApiResponse.data); 
        console.log("-------------------------------------------------");

        res.json(externalApiResponse.data);
    } catch (error: any) {
        console.error("--- ERROR: Failed to fetch products ---", error.message);
        res.status(500).json({ error: "Failed to fetch data from the external service" });
    }
});

// Endpoint 2: Get a specific product by its ID
app.get('/products/:id', async (req: Request, res: Response) => {
    try {
        const productId = req.params.id;
        const externalApiResponse = await axios.get(`${fakeStoreBaseUrl}/products/${productId}`);
        
        console.log(`--- SUCCESS: Fetched Product ${productId} ---`);
        console.log(externalApiResponse.data);
        console.log("-------------------------------------------------");

        res.json(externalApiResponse.data);
    } catch (error: any) {
        console.error(`Error fetching product ${req.params.id}:`, error.message);
        
        if (error.response && error.response.status === 404) {
            res.status(404).json({ error: "Product not found" });
        } else {
            res.status(500).json({ error: "Failed to fetch data from the external service" });
        }
    }
});

app.listen(port, () => {
    console.log(`Proxy server running smoothly at http://localhost:${port}`);
});