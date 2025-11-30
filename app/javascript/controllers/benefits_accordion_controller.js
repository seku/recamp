import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    // All items start collapsed by default (no expanded class)
    console.log("Benefits accordion connected")
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    const clickedItem = event.currentTarget.closest('.content-item')
    if (!clickedItem) return

    const isExpanded = clickedItem.classList.contains('expanded')

    // Close all other items (accordion behavior - only one open at a time)
    this.itemTargets.forEach((item) => {
      if (item !== clickedItem) {
        item.classList.remove('expanded')
      }
    })

    // Toggle the clicked item
    if (isExpanded) {
      clickedItem.classList.remove('expanded')
    } else {
      clickedItem.classList.add('expanded')
    }
  }
}