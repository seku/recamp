import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.initializeItems()
  }

  initializeItems() {
    this.itemTargets.forEach((item) => {
      const content = item.querySelector('.collapse')
      const plus = item.querySelector('.plus-icon')
      const line = item.querySelector('.red-line')

      if (content && plus && line) {
        content.style.display = 'none'
        plus.style.display = 'inline-block'
        line.style.display = 'none'
      }
    })
  }

  toggle(event) {
    console.log("Toggle clicked")
    event.preventDefault()
    event.stopPropagation()

    const clickedToggle = event.currentTarget
    const item = clickedToggle.closest('.content-item')

    if (!item) {
      console.error("Could not find parent content-item")
      return
    }

    const content = item.querySelector('.collapse')
    const plus = item.querySelector('.plus-icon')
    const line = item.querySelector('.red-line')

    if (!content || !plus || !line) {
      console.error("Missing required elements in item")
      return
    }

    const isExpanded = clickedToggle.hasAttribute('data-expanded')

    if (isExpanded) {
      // Collapsing
      content.style.display = 'none'
      plus.style.display = 'inline-block'
      line.style.display = 'none'
      clickedToggle.removeAttribute('data-expanded')
      console.log("Collapsed")
    } else {
      // Expanding
      content.style.display = 'block'
      plus.style.display = 'none'
      line.style.display = 'block'
      clickedToggle.setAttribute('data-expanded', 'true')
      console.log("Expanded")
    }
  }
}
