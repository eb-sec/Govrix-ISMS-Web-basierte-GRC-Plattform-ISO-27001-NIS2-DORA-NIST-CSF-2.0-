import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class AiService {
  private readonly ollamaUrl: string;
  private readonly model: string;

  constructor(private config: ConfigService) {
    this.ollamaUrl = this.config.get<string>('OLLAMA_URL') || 'http://localhost:11434';
    this.model     = this.config.get<string>('OLLAMA_MODEL') || 'llama3.2';
    console.log(`🦙 Ollama KI-Service — Modell: ${this.model}`);
  }

  async analyse(prompt: string, maxTokens = 2000): Promise<any> {
    try {
      const response = await axios.post(
        `${this.ollamaUrl}/api/chat`,
        {
          model: this.model,
          stream: false,
          options: {
            num_predict: maxTokens,
            temperature: 0.2,
          },
          messages: [
            {
              role: 'system',
              content:
                'Du bist ein ISO 27001:2022 Sicherheitsauditor. ' +
                'Erstelle immer direkt den Report ohne Einleitung, Begrüßung oder Rückfragen. ' +
                'Schreibe sachlich und strukturiert auf Deutsch.',
            },
            {
              role: 'user',
              content: prompt,
            },
          ],
        },
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: 180000,
        }
      );

      const text: string = response.data?.message?.content || '';
      if (!text) {
        throw new InternalServerErrorException('Ollama hat keine Antwort zurückgegeben');
      }
      return { text };

    } catch (err: any) {
      if (err.code === 'ECONNREFUSED') {
        throw new InternalServerErrorException(
          'Ollama ist nicht erreichbar. Bitte "ollama serve" im Terminal ausführen.'
        );
      }
      if (err.response?.status === 404) {
        throw new InternalServerErrorException(
          `Ollama-Modell "${this.model}" nicht gefunden. Bitte "ollama pull ${this.model}" ausführen.`
        );
      }
      const msg = err.response?.data?.error || err.message || 'Unbekannter Fehler';
      console.error('Ollama Fehler:', msg);
      throw new InternalServerErrorException(`Ollama Fehler: ${msg}`);
    }
  }
}
