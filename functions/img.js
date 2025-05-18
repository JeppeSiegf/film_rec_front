export async function onRequest({ request }) {
    const url = new URL(request.url);
    const target = url.searchParams.get("url");
    if (!target) return new Response("Missing url", { status: 400 });
  
    const response = await fetch(target);
    if (!response.ok) return new Response("Failed to fetch", { status: response.status });
  
    return new Response(response.body, {
      status: response.status,
      headers: {
        "Content-Type": response.headers.get("Content-Type") || "application/octet-stream",
        "Cache-Control": "public, max-age=86400"
      }
    });
  }
  