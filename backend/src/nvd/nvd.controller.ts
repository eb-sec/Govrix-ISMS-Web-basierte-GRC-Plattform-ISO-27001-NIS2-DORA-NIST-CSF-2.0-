import { Controller, Get, Query, HttpException } from '@nestjs/common';

@Controller('nvd')
export class NvdController {

  // GET /api/v1/nvd/cve?id=CVE-2017-1000376
  @Get('cve')
  async getCve(@Query('id') id: string) {
    if (!id || !/^CVE-\d{4}-\d+$/i.test(id)) {
      throw new HttpException('Ungültige CVE-ID', 400);
    }
    try {
      const res = await fetch(
        `https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=${id}`,
        { headers: { 'Accept': 'application/json' } }
      );
      if (!res.ok) throw new Error('NVD Status ' + res.status);
      return await res.json();
    } catch (e) {
      throw new HttpException('NVD nicht erreichbar: ' + e.message, 502);
    }
  }

  // GET /api/v1/nvd/search?q=apache&severity=HIGH
  @Get('search')
  async search(@Query('q') q: string, @Query('severity') severity?: string) {
    if (!q) throw new HttpException('Kein Suchbegriff', 400);
    try {
      let url = `https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${encodeURIComponent(q)}&resultsPerPage=10`;
      if (severity) url += `&cvssV3Severity=${severity.toUpperCase()}`;
      const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
      if (!res.ok) throw new Error('NVD Status ' + res.status);
      return await res.json();
    } catch (e) {
      throw new HttpException('NVD nicht erreichbar: ' + e.message, 502);
    }
  }
}
