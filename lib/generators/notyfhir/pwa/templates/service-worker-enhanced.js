// Notyfhir Enhanced Service Worker with PWA offline support
const CACHE_NAME = 'notyfhir-v1';
const OFFLINE_URL = '/offline';

// 需要離線快取的資源
const urlsToCache = [
  OFFLINE_URL,
  '/icon-192.png',
  '/icon-512.png'
];

// 安裝 Service Worker
self.addEventListener('install', (event) => {
  console.log('[Notyfhir Service Worker] Installing...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Notyfhir Service Worker] Caching offline resources');
        return cache.addAll(urlsToCache);
      })
      .then(() => self.skipWaiting())
  );
});

// 啟動 Service Worker
self.addEventListener('activate', (event) => {
  console.log('[Notyfhir Service Worker] Activating...');
  
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('[Notyfhir Service Worker] Removing old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

// 處理 fetch 請求
self.addEventListener('fetch', (event) => {
  // 只處理 GET 請求
  if (event.request.method !== 'GET') {
    return;
  }
  
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // 快取命中 - 返回快取的回應
        if (response) {
          return response;
        }
        
        // 嘗試從網路獲取
        return fetch(event.request).then((response) => {
          // 檢查是否為有效回應
          if (!response || response.status !== 200 || response.type !== 'basic') {
            return response;
          }
          
          // 複製回應
          const responseToCache = response.clone();
          
          // 將回應加入快取（僅快取成功的 HTML、CSS、JS 和圖片）
          if (shouldCache(event.request)) {
            caches.open(CACHE_NAME)
              .then((cache) => {
                cache.put(event.request, responseToCache);
              });
          }
          
          return response;
        });
      })
      .catch(() => {
        // 網路請求失敗，返回離線頁面
        if (event.request.destination === 'document') {
          return caches.match(OFFLINE_URL);
        }
      })
  );
});

// 判斷是否應該快取
function shouldCache(request) {
  const url = new URL(request.url);
  
  // 不快取的情況
  if (url.pathname.includes('/api/') || 
      url.pathname.includes('/cable') ||
      url.pathname.includes('.json') ||
      url.pathname.includes('manifest') ||
      url.pathname.includes('service-worker')) {
    return false;
  }
  
  // 快取靜態資源
  return request.destination === 'document' ||
         request.destination === 'style' ||
         request.destination === 'script' ||
         request.destination === 'image' ||
         request.destination === 'font';
}

// 處理 SKIP_WAITING 訊息
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

// 處理推播通知
self.addEventListener("push", async (event) => {
  console.log('[Notyfhir Service Worker] Push received:', event);
  
  try {
    const { title, options } = await event.data.json();
    console.log('[Notyfhir Service Worker] Showing notification:', title, options);
    
    // 確保 options.data 包含通知路徑
    if (!options.data) {
      options.data = {};
    }
    if (!options.data.path) {
      options.data.path = '/notyfhir/notifications';
    }
    
    // 顯示通知
    event.waitUntil(
      self.registration.showNotification(title, options).then(() => {
        // 嘗試設定應用程式徽章（如果支援）
        if ('setAppBadge' in self.navigator) {
          // 從 options.data 取得未讀數量，或取得目前的通知數量
          const badgeCount = options.data.badge_count || null;
          if (badgeCount !== null && badgeCount > 0) {
            return self.navigator.setAppBadge(badgeCount);
          } else {
            return self.registration.getNotifications().then(notifications => {
              const count = notifications.length;
              if (count > 0) {
                return self.navigator.setAppBadge(count);
              }
            });
          }
        }
      })
    );
  } catch (error) {
    console.error('[Notyfhir Service Worker] Error handling push:', error);
  }
});

// 處理通知點擊
self.addEventListener("notificationclick", function(event) {
  console.log('[Notyfhir Service Worker] Notification click received:', event);
  event.notification.close();
  
  event.waitUntil(
    Promise.all([
      // 清除或更新徽章
      self.registration.getNotifications().then(notifications => {
        const remainingCount = notifications.length - 1;
        if ('setAppBadge' in self.navigator) {
          if (remainingCount > 0) {
            return self.navigator.setAppBadge(remainingCount);
          } else {
            return self.navigator.clearAppBadge();
          }
        }
      }),
      
      // 處理視窗聚焦或開啟
      clients.matchAll({ type: "window" }).then((clientList) => {
        // 檢查是否已有開啟的視窗
        for (let i = 0; i < clientList.length; i++) {
          let client = clientList[i];
          let clientPath = (new URL(client.url)).pathname;

          if (clientPath == event.notification.data.path && "focus" in client) {
            return client.focus();
          }
        }

        // 如果沒有開啟的視窗，開啟新視窗
        if (clients.openWindow) {
          return clients.openWindow(event.notification.data.path);
        }
      })
    ])
  );
});

// 定期同步（背景同步）
self.addEventListener('sync', (event) => {
  if (event.tag === 'notyfhir-sync') {
    event.waitUntil(syncNotifications());
  }
});

async function syncNotifications() {
  try {
    const response = await fetch('/notyfhir/notifications.json');
    if (response.ok) {
      const data = await response.json();
      console.log('[Notyfhir Service Worker] Synced notifications:', data);
    }
  } catch (error) {
    console.error('[Notyfhir Service Worker] Sync failed:', error);
  }
}