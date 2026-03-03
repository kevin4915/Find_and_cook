// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

document.addEventListener('turbo:load', () => {
  const swipeContainer = document.querySelector('.card-stack');
  if (!swipeContainer) return;

  const handleSwipe = (isLike) => {
    const cards = document.querySelectorAll('.recipe-card');
    const topCard = cards[0];

    if (topCard) {
      topCard.style.transition = "transform 0.5s ease, opacity 0.5s ease";
      topCard.style.transform = isLike ? "translateX(200%) rotate(30deg)" : "translateX(-200%) rotate(-30deg)";
      topCard.style.opacity = "0";

      setTimeout(() => {
        topCard.remove();

        if (isLike) { console.log("Recette likée !"); }
      }, 500);
    }
  };

  document.querySelector('.js-dislike').addEventListener('click', () => handleSwipe(false));

  document.querySelector('.js-like').addEventListener('click', () => handleSwipe(true));
});
