import {serve} from '@hono/node-server';
import {Hono} from 'hono';
import {cors} from 'hono/cors';
import {Container} from 'inversify';
import {FileUploadService, type IFileUploadService} from './services/file.service.js';

export const TYPES = {
  FileUploadService: Symbol.for('FileUploadService'),
} as const;
export type TYPES = typeof TYPES;

const app = new Hono();
app.use('/api/*', cors());

const container = new Container();
container.bind<IFileUploadService>(TYPES.FileUploadService).to(FileUploadService).inSingletonScope();

const fileUploadService = container.get<FileUploadService>(TYPES.FileUploadService);
app.post('/api/upload', async (c) => {
  return await fileUploadService.handleUpload(c);
});

app.get('/', (c) => {
  return c.text('Hello Hono1!');
});

serve(
  {
    fetch: app.fetch,
    port: 3000,
  },
  (info) => {
    console.log(`Server is running on http://localhost:${info.port}`);
  },
);
