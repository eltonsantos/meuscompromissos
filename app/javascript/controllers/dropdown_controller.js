import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener("click", this.closeOnOutsideClick)
    document.addEventListener("keydown", this.closeOnEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    document.removeEventListener("keydown", this.closeOnEscape)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.setExpanded(this.menuTarget.classList.contains("hidden"))
  }

  close() {
    if (!this.menuTarget.classList.contains("hidden")) this.setExpanded(false)
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }

  setExpanded(expanded) {
    this.menuTarget.classList.toggle("hidden", !expanded)
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", expanded)
  }
}
