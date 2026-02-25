import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()
    
    // Create an observer to scroll when new messages are added to the DOM
    this.observer = new MutationObserver(() => this.scrollToBottom())
    this.observer.observe(this.element, { childList: true })
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight
  }

  disconnect() {
    this.observer.disconnect()
  }
}