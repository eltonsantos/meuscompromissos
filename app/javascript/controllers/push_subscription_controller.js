import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]
  static values = { vapidKey: String }

  connect() {
    if (!this.isSupported()) {
      this.setStatus("unsupported", "Notificacoes nao sao suportadas neste navegador")
      return
    }
    this.refreshState()
  }

  async toggle(event) {
    event.preventDefault()

    if (!this.isSupported()) return

    if (Notification.permission === "denied") {
      this.setStatus("denied", "Permissao bloqueada. Habilite nas configuracoes do navegador.")
      return
    }

    const registration = await this.ensureServiceWorker()
    if (!registration) return

    const existing = await registration.pushManager.getSubscription()
    if (existing) {
      await this.unsubscribe(existing)
    } else {
      await this.subscribe(registration)
    }
  }

  async refreshState() {
    if (!("serviceWorker" in navigator)) return
    const registration = await navigator.serviceWorker.getRegistration()
    if (!registration) {
      this.setStatus("inactive", "Notificacoes desativadas")
      return
    }
    const subscription = await registration.pushManager.getSubscription()
    if (subscription && Notification.permission === "granted") {
      this.setStatus("active", "Notificacoes ativadas")
    } else {
      this.setStatus("inactive", "Notificacoes desativadas")
    }
  }

  async ensureServiceWorker() {
    try {
      const permission = await Notification.requestPermission()
      if (permission !== "granted") {
        this.setStatus("denied", "Permissao negada")
        return null
      }
      return await navigator.serviceWorker.register("/service-worker.js")
    } catch (error) {
      console.error("[push] Falha registrando service worker", error)
      this.setStatus("error", "Erro ao registrar service worker")
      return null
    }
  }

  async subscribe(registration) {
    if (!this.vapidKeyValue) {
      this.setStatus("error", "VAPID public key nao configurada")
      return
    }

    try {
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: this.urlBase64ToUint8Array(this.vapidKeyValue)
      })

      const json = subscription.toJSON()
      const csrf = document.querySelector('meta[name="csrf-token"]')?.content

      const response = await fetch("/push_subscription", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": csrf || ""
        },
        body: JSON.stringify({
          endpoint: subscription.endpoint,
          p256dh_key: json.keys.p256dh,
          auth_key: json.keys.auth
        })
      })

      if (response.ok) {
        this.setStatus("active", "Notificacoes ativadas")
      } else {
        this.setStatus("error", "Falha ao registrar no servidor")
      }
    } catch (error) {
      console.error("[push] Erro ao inscrever", error)
      this.setStatus("error", "Erro ao inscrever")
    }
  }

  async unsubscribe(subscription) {
    const endpoint = subscription.endpoint
    try {
      await subscription.unsubscribe()
      const csrf = document.querySelector('meta[name="csrf-token"]')?.content

      await fetch(`/push_subscription?endpoint=${encodeURIComponent(endpoint)}`, {
        method: "DELETE",
        headers: { "X-CSRF-Token": csrf || "" }
      })
      this.setStatus("inactive", "Notificacoes desativadas")
    } catch (error) {
      console.error("[push] Erro ao desinscrever", error)
      this.setStatus("error", "Erro ao desativar")
    }
  }

  setStatus(state, message) {
    if (this.hasStatusTarget) this.statusTarget.textContent = message
    if (this.hasButtonTarget) {
      this.buttonTarget.dataset.state = state
      if (state === "active") {
        this.buttonTarget.textContent = "Desativar notificacoes"
      } else if (state === "unsupported" || state === "denied") {
        this.buttonTarget.textContent = "Notificacoes indisponiveis"
        this.buttonTarget.disabled = true
      } else {
        this.buttonTarget.textContent = "Ativar notificacoes"
      }
    }
  }

  isSupported() {
    return "serviceWorker" in navigator && "PushManager" in window && "Notification" in window
  }

  urlBase64ToUint8Array(base64String) {
    const padding = "=".repeat((4 - (base64String.length % 4)) % 4)
    const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
    const rawData = atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}
