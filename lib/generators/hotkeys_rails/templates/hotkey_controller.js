import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click(event) {
    if (this.#shouldHandle(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  focus(event) {
    if (this.#shouldHandle(event)) {
      event.preventDefault()
      this.element.focus()
    }
  }

  #shouldHandle(event) {
    return !event.defaultPrevented &&
           !event.target.closest("input, textarea, [contenteditable]")
  }
}
