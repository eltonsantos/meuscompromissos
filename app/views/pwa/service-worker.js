const CACHE = "meus-compromissos-v1";
const ASSET_PREFIXES = ["/assets/", "/icon.png", "/icon.svg", "/icon-192.png"];

const OFFLINE_HTML = `<!DOCTYPE html>
<html lang="pt-BR">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
    <title>Sem conexão · Meus Compromissos</title>
    <style>
      :root { color-scheme: light; }
      body { margin: 0; min-height: 100dvh; display: flex; align-items: center; justify-content: center;
             background: #e2e8f0; color: #292524; font-family: Inter, system-ui, sans-serif; padding: 1.5rem; }
      main { max-width: 24rem; text-align: center; background: #fff; padding: 2rem 1.5rem; border-radius: .75rem;
             box-shadow: 0 4px 6px -1px rgba(0, 0, 0, .1); }
      h1 { font-size: 1.25rem; margin: 0 0 .5rem; }
      p { margin: 0 0 1.5rem; color: #57534e; line-height: 1.5; }
      button { width: 100%; min-height: 44px; border: 0; border-radius: .375rem; background: #292524;
               color: #fff; font-size: 1rem; font-weight: 600; cursor: pointer; }
    </style>
  </head>
  <body>
    <main>
      <h1>Você está sem conexão</h1>
      <p>Não foi possível carregar esta página. Verifique sua internet e tente novamente.</p>
      <button type="button" onclick="location.reload()">Tentar novamente</button>
    </main>
  </body>
</html>`;

const offlineResponse = () =>
  new Response(OFFLINE_HTML, { status: 200, headers: { "Content-Type": "text/html; charset=utf-8" } });

const isAsset = (url) => ASSET_PREFIXES.some((prefix) => url.pathname.startsWith(prefix));

const isHtmlRequest = (request) =>
  !request.headers.get("turbo-frame") &&
  (request.mode === "navigate" || (request.headers.get("accept") || "").includes("text/html"));

self.addEventListener("install", () => {
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key)));
      await self.clients.claim();
    })()
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (isAsset(url)) {
    event.respondWith(
      (async () => {
        const cached = await caches.match(request);
        if (cached) return cached;
        try {
          const response = await fetch(request);
          if (response.ok) {
            const cache = await caches.open(CACHE);
            cache.put(request, response.clone());
          }
          return response;
        } catch (error) {
          return Response.error();
        }
      })()
    );
    return;
  }

  if (isHtmlRequest(request)) {
    event.respondWith(fetch(request).catch(() => offlineResponse()));
  }
});

self.addEventListener("push", (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (_) {
    data = { title: "Meus Compromissos", body: event.data ? event.data.text() : "" };
  }

  const title = data.title || "Meus Compromissos";
  const options = {
    body: data.body || "",
    icon: "/icon.png",
    badge: "/icon.png",
    data: { path: data.path || "/" }
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const targetPath = (event.notification.data && event.notification.data.path) || "/";

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        const clientPath = new URL(client.url).pathname;
        if (clientPath === targetPath && "focus" in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetPath);
      }
    })
  );
});
