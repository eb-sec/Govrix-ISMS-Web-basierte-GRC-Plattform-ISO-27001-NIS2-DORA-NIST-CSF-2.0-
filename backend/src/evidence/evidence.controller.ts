import {
  Controller, Get, Post, Delete, Param, Query, Request,
  UseGuards, UseInterceptors, UploadedFile, UploadedFiles,
  Body, Res, StreamableFile, BadRequestException,
} from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { Response } from 'express';
import { createReadStream, existsSync } from 'fs';
import * as path from 'path';
import { EvidenceService } from './evidence.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

// Upload-Verzeichnis relativ zum Projektroot
const UPLOAD_DIR = process.env.EVIDENCE_UPLOAD_DIR || './uploads/evidence';

const storage = diskStorage({
  destination: (req, file, cb) => {
    const fs = require('fs');
    fs.mkdirSync(UPLOAD_DIR, { recursive: true });
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => {
    // Sicherer Dateiname: Timestamp + Original (bereinigt)
    const safe = file.originalname.replace(/[^a-zA-Z0-9.\-_]/g, '_');
    cb(null, `${Date.now()}_${safe}`);
  },
});

const fileFilter = (req: any, file: any, cb: any) => {
  const allowed = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'image/png', 'image/jpeg', 'image/gif',
    'text/plain', 'text/csv',
    'application/zip',
  ];
  if (allowed.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new BadRequestException(`Dateityp nicht erlaubt: ${file.mimetype}`), false);
  }
};

function getIp(req: any): string {
  return req.headers['x-forwarded-for']?.split(',')[0]?.trim()
    || req.connection?.remoteAddress || '';
}

@Controller('evidence')
@UseGuards(JwtAuthGuard)
export class EvidenceController {
  constructor(private readonly service: EvidenceService) {}

  /** Alle Nachweise eines Controls */
  @Get('control/:ref')
  getForControl(
    @Param('ref') ref: string,
    @Query('type') type = 'iso',
  ) {
    return this.service.getEvidenceForControl(ref, type);
  }

  /** Zusammenfassung: { 'A.5.1': 2, 'A.5.2': 1 } */
  @Get('summary')
  getSummary(@Query('type') type?: string) {
    return this.service.getEvidenceSummary();
  }

  /** Alle Nachweise (optional nach Typ gefiltert) */
  @Get()
  getAll(@Query('type') type?: string) {
    return this.service.getAllEvidence(type);
  }

  /** Datei herunterladen */
  @Get(':id/download')
  async download(
    @Param('id') id: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    const info = await this.service.getFileInfo(id);
    const absPath = path.resolve(info.filePath);
    if (!existsSync(absPath)) {
      throw new BadRequestException('Datei nicht mehr vorhanden');
    }
    res.set({
      'Content-Type': info.mimeType || 'application/octet-stream',
      'Content-Disposition': `attachment; filename="${encodeURIComponent(info.fileName)}"`,
    });
    return new StreamableFile(createReadStream(absPath));
  }

  /** Einzelne Datei hochladen */
  @Post('upload')
  @UseInterceptors(FileInterceptor('file', { storage, fileFilter, limits: { fileSize: 25 * 1024 * 1024 } }))
  async upload(
    @UploadedFile() file: any,
    @Body('controlRef') controlRef: string,
    @Body('controlType') controlType = 'iso',
    @Body('description') description: string,
    @Body('validUntil') validUntil: string,
    @Request() req: any,
  ) {
    if (!file) throw new BadRequestException('Keine Datei empfangen');
    if (!controlRef) throw new BadRequestException('controlRef fehlt');

    return this.service.createEvidence({
      controlRef,
      controlType,
      fileName: file.originalname,
      filePath: file.path,
      fileSize: file.size,
      mimeType: file.mimetype,
      description,
      validUntil: validUntil || undefined,
      userEmail: req.user?.email || 'unknown',
      userId: req.user?.sub,
      ipAddress: getIp(req),
    });
  }

  /** Mehrere Dateien auf einmal */
  @Post('upload-multi')
  @UseInterceptors(FilesInterceptor('files', 10, { storage, fileFilter, limits: { fileSize: 25 * 1024 * 1024 } }))
  async uploadMulti(
    @UploadedFiles() files: any[],
    @Body('controlRef') controlRef: string,
    @Body('controlType') controlType = 'iso',
    @Body('description') description: string,
    @Request() req: any,
  ) {
    if (!files?.length) throw new BadRequestException('Keine Dateien empfangen');
    if (!controlRef) throw new BadRequestException('controlRef fehlt');

    const results = await Promise.all(files.map(file =>
      this.service.createEvidence({
        controlRef, controlType,
        fileName: file.originalname,
        filePath: file.path,
        fileSize: file.size,
        mimeType: file.mimetype,
        description,
        userEmail: req.user?.email || 'unknown',
        userId: req.user?.sub,
        ipAddress: getIp(req),
      })
    ));
    return results;
  }

  /** Nachweis löschen (Soft-Delete) */
  @Delete(':id')
  delete(@Param('id') id: string, @Request() req: any) {
    return this.service.deleteEvidence(
      id,
      req.user?.email || 'unknown',
      getIp(req),
    );
  }
}
