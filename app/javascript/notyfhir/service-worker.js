// Notyfhir Service Worker for Web Push notifications

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