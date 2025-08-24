import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { injectable } from 'inversify';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

@injectable()
export class FileUploadService {
    uploadDir = path.resolve(__dirname, '../../uploads');
    constructor() {
        fs.mkdir(this.uploadDir, { recursive: true }).catch(console.error);
    }
    async handleUpload(c) {
        try {
            const formData = await c.req.formData();
            const file = formData.get('file');
            if (!file || !(file instanceof File)) {
                return c.json({ success: false, error: '未找到上传文件' }, 400);
            }
            const arrayBuffer = await file.arrayBuffer();
            const buffer = Buffer.from(arrayBuffer);
            // === 根据当天日期生成目录 ===
            const today = new Date();
            const dateStr = today.toISOString().split('T')[0];
            const dateDir = path.join(this.uploadDir, dateStr);
            // 确保日期目录存在
            await fs.mkdir(dateDir, { recursive: true });
            // 文件名加时间戳，避免冲突
            const filename = `${Date.now()}_${file.name}`;
            const filepath = path.join(dateDir, filename);
            await fs.writeFile(filepath, buffer);
            return c.json({
                success: true,
                filename,
                filepath, // 完整路径
                relativePath: `${dateStr}/${filename}`, // 相对 uploads 的路径
                originalFilename: file.name,
                size: file.size,
            });
        }
        catch (err) {
            console.error(err);
            return c.json({ success: false, error: err.message }, 500);
        }
    }
}
