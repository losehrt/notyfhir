import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { count: Number }
  
  connect() {
    this.updateBadge()
  }
  
  countValueChanged() {
    this.updateBadge()
  }
  
  updateBadge() {
    if ('setAppBadge' in navigator) {
      if (this.countValue > 0) {
        navigator.setAppBadge(this.countValue)
      } else {
        navigator.clearAppBadge()
      }
    }
  }
  
  markAsRead(event) {
    // 當通知被標記為已讀時，更新 badge
    const newCount = Math.max(0, this.countValue - 1)
    this.countValue = newCount
  }
}