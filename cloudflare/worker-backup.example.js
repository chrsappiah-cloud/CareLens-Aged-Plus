/**
 * Cloudflare Worker — CareLens Aged+ backup endpoint (example)
 * Deploy to Workers + bind R2 bucket `carelens-aged-backups`
 *
 * Routes:
 *   POST /v1/backup/batch  — body: { records: SyncRecord[] }
 *   GET  /v1/backup/:type  — returns records for record type
 */

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const auth = request.headers.get("Authorization");
    if (!auth || auth !== `Bearer ${env.BACKUP_TOKEN}`) {
      return new Response("Unauthorized", { status: 401 });
    }

    if (url.pathname === "/v1/backup/batch" && request.method === "POST") {
      const body = await request.json();
      const key = `batch/${Date.now()}.json`;
      await env.BACKUPS.put(key, JSON.stringify(body));
      return Response.json({ ok: true, key, count: body.records?.length ?? 0 });
    }

    const match = url.pathname.match(/^\/v1\/backup\/(\w+)$/);
    if (match && request.method === "GET") {
      const listed = await env.BACKUPS.list({ prefix: "batch/", limit: 1 });
      if (!listed.objects.length) return Response.json([]);
      const obj = await env.BACKUPS.get(listed.objects[0].key);
      const data = JSON.parse(await obj.text());
      const type = match[1];
      const filtered = (data.records || []).filter((r) => r.record_type === type || r.recordType === type);
      return Response.json(filtered);
    }

    return new Response("Not found", { status: 404 });
  },
};
