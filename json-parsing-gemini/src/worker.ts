/**
 * Cloudflare Worker for Gemini AI service
 * This replaces the Express.js server with a Cloudflare Worker
 */

import { parseBuyerRequest, parseSellerProfile } from './services/gemini.service';

export interface Env {
  GEMINI_API_KEY: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    // Set CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    // Handle CORS preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    const url = new URL(request.url);

    try {
      // Parse buyer request endpoint
      if (url.pathname === '/api/parse-request' && request.method === 'POST') {
        const body = await request.json() as { text?: string };
        
        if (!body.text) {
          return new Response(
            JSON.stringify({ error: "Missing 'text' in request body." }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          );
        }

        const parsedJson = await parseBuyerRequest(body.text);
        
        return new Response(JSON.stringify(parsedJson), {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // Parse seller profile endpoint
      if (url.pathname === '/api/parse-profile' && request.method === 'POST') {
        const body = await request.json() as { text?: string; userId?: string };
        
        if (!body.text || !body.userId) {
          return new Response(
            JSON.stringify({ error: "Missing 'text' or 'userId'." }),
            { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
          );
        }

        const parsedJson = await parseSellerProfile(body.text, body.userId);
        
        return new Response(JSON.stringify(parsedJson), {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        });
      }

      // 404 for unknown routes
      return new Response('Not Found', { 
        status: 404, 
        headers: corsHeaders 
      });

    } catch (error) {
      console.error('Worker error:', error);
      const message = error instanceof Error ? error.message : 'Internal server error';
      
      return new Response(
        JSON.stringify({ error: message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }
  },
};
