import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    installed: { type: Boolean, default: false }
  }
  
  connect() {
    // Check if app is already installed
    if (window.matchMedia('(display-mode: standalone)').matches || 
        window.navigator.standalone === true) {
      this.installedValue = true
      return
    }
    
    // Listen for the beforeinstallprompt event
    window.addEventListener('beforeinstallprompt', (e) => {
      // Prevent the mini-infobar from appearing on mobile
      e.preventDefault()
      
      // Stash the event so it can be triggered later
      this.deferredPrompt = e
      
      // Show the install button
      this.element.classList.remove('hidden')
      
      console.log('[Notyfhir] Install prompt ready')
    })
    
    // Listen for app installed event
    window.addEventListener('appinstalled', () => {
      console.log('[Notyfhir] PWA was installed')
      this.element.classList.add('hidden')
      this.installedValue = true
    })
  }
  
  async install() {
    if (!this.deferredPrompt) {
      console.log('[Notyfhir] Install prompt not available')
      return
    }
    
    // Show the install prompt
    this.deferredPrompt.prompt()
    
    // Wait for the user to respond to the prompt
    const { outcome } = await this.deferredPrompt.userChoice
    
    console.log(`[Notyfhir] User response to install prompt: ${outcome}`)
    
    // Clear the deferredPrompt
    this.deferredPrompt = null
    
    // Hide the button regardless of outcome
    this.element.classList.add('hidden')
  }
  
  disconnect() {
    this.deferredPrompt = null
  }
}