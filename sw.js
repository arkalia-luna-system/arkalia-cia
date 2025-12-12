// Service Worker pour Arkalia CIA PWA
// Version: 1.3.1
// Date: 10 décembre 2025

const CACHE_NAME = 'arkalia-cia-v1.3.1';
const urlsToCache = [
    './',
    './index.html',
    './manifest.json',
    './icons/Icon-192.png',
    './icons/Icon-512.png',
    './icons/Icon-maskable-192.png',
    './icons/Icon-maskable-512.png',
    './favicon.png',
];

// Installation du Service Worker
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => {
                console.log('Service Worker: Cache ouvert');
                return cache.addAll(urlsToCache);
            })
            .catch((error) => {
                console.error('Service Worker: Erreur lors de la mise en cache', error);
            })
    );
    self.skipWaiting();
});

// Activation du Service Worker
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cacheName) => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('Service Worker: Suppression de l\'ancien cache', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
    return self.clients.claim();
});

// Stratégie: Network First, puis Cache
// Fix pour Comet: Ignorer les requêtes de service worker et les requêtes de cache
self.addEventListener('fetch', (event) => {
    // Ignorer les requêtes de service worker lui-même
    if (event.request.url.includes('/sw.js') || event.request.url.includes('service-worker')) {
        return;
    }

    // Pour les requêtes de navigation (page principale), toujours essayer le réseau d'abord
    if (event.request.mode === 'navigate' || event.request.destination === 'document') {
        event.respondWith(
            fetch(event.request)
                .then((response) => {
                    // Si le réseau réussit, mettre en cache et retourner
                    if (response && response.status === 200) {
                        const responseToCache = response.clone();
                        caches.open(CACHE_NAME)
                            .then((cache) => {
                                cache.put(event.request, responseToCache);
                            });
                    }
                    return response;
                })
                .catch(() => {
                    // Si le réseau échoue, utiliser le cache
                    return caches.match('./index.html')
                        .then((cachedResponse) => {
                            if (cachedResponse) {
                                return cachedResponse;
                            }
                            // Fallback: retourner une réponse basique
                            return new Response('Page non disponible hors-ligne', {
                                status: 503,
                                headers: { 'Content-Type': 'text/plain' }
                            });
                        });
                })
        );
        return;
    }

    // Pour les autres requêtes (assets, API, etc.)
    event.respondWith(
        fetch(event.request)
            .then((response) => {
                // Vérifier si la réponse est valide
                if (!response || response.status !== 200 || response.type !== 'basic') {
                    return response;
                }

                // Cloner la réponse
                const responseToCache = response.clone();

                // Mettre en cache
                caches.open(CACHE_NAME)
                    .then((cache) => {
                        cache.put(event.request, responseToCache);
                    });

                return response;
            })
            .catch(() => {
                // Si le réseau échoue, utiliser le cache
                return caches.match(event.request)
                    .then((cachedResponse) => {
                        if (cachedResponse) {
                            return cachedResponse;
                        }
                        // Si pas de cache, retourner une page offline basique
                        if (event.request.destination === 'document' || event.request.mode === 'navigate') {
                            return caches.match('./index.html');
                        }
                    });
            })
    );
});

