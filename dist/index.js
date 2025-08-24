import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { Container } from 'inversify';
import { FileUploadService } from './services/file.service.js';
export const TYPES = {
    FileUploadService: Symbol.for('FileUploadService'),
};
const app = new Hono();
const container = new Container();
container.bind(TYPES.FileUploadService).to(FileUploadService).inSingletonScope();
const fileUploadService = container.get(TYPES.FileUploadService);
app.post('/api/upload', async (c) => {
    return await fileUploadService.handleUpload(c);
});
app.get('/', (c) => {
    return c.text('Hello Hono!');
});
serve({
    fetch: app.fetch,
    port: 3000,
}, (info) => {
    console.log(`Server is running on http://localhost:${info.port}`);
});
