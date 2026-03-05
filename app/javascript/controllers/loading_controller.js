import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "loader"]

  connect() {
    const carousel = document.querySelector("#carouselExampleInterval")
    if (carousel) {
      bootstrap.Carousel.getOrCreateInstance(carousel)
    }
  }

  submit(event) {
    // Empêche double clic
    this.buttonTarget.disabled = true
    // Affiche le loader
    this.loaderTarget.classList.add("show")
  }
}
