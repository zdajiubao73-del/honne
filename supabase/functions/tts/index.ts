import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const ELEVENLABS_API_KEY = Deno.env.get('ELEVENLABS_API_KEY')!
const OPENAI_API_KEY     = Deno.env.get('OPENAI_API_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const VOICE_IDS: Record<string, string> = {
  female: 'fUjY9K2nAIwlALOwSiwc',
  male:   'l5KWIFmhhsVdaYchBLIn',
}

/** GPT-4o で漢字を正確なひらがなに変換する。失敗時は元テキストを返す */
async function convertToHiragana(text: string): Promise<string> {
  try {
    const res = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o',
        messages: [
          {
            role: 'system',
            content: 'あなたは日本語テキストをTTS用にひらがな変換するアシスタントです。',
          },
          {
            role: 'user',
            content: `以下の日本語テキストを音声読み上げ用に変換してください。

ルール：
- すべての漢字・カタカナを文脈に合わせた正確なひらがなに変換する
- 句読点（。、！？）はそのまま残す
- 改行・余計な説明は入れない
- 変換後のテキストのみ返す

テキスト：${text}`,
          },
        ],
        temperature: 0,
        max_tokens: 1000,
      }),
    })
    if (!res.ok) return text
    const json = await res.json()
    return json.choices?.[0]?.message?.content?.trim() ?? text
  } catch {
    return text
  }
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const { text, voice } = await req.json()
  const voiceId = VOICE_IDS[voice] ?? VOICE_IDS.female

  // サーバーサイドでひらがな変換（タイムアウトなし・GPT-4o使用）
  const hiragana = await convertToHiragana(text)

  const response = await fetch(
    `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`,
    {
      method: 'POST',
      headers: {
        'xi-api-key': ELEVENLABS_API_KEY,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        text: hiragana,
        model_id: 'eleven_multilingual_v2',
        voice_settings: {
          stability: 0.5,
          similarity_boost: 0.85,
          style: 0,
          use_speaker_boost: true,
        },
      }),
    }
  )

  if (!response.ok) {
    const err = await response.text()
    return new Response(JSON.stringify({ error: 'TTS failed', detail: err }), {
      status: response.status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const audioData = await response.arrayBuffer()
  return new Response(audioData, {
    headers: { ...corsHeaders, 'Content-Type': 'audio/mpeg' },
  })
})
