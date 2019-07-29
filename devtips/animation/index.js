document.addEventListener('DOMContentLoaded', function() {
  document.querySelector('html').addEventListener("click", function(event) {
    document.querySelector("body").insertAdjacentHTML('beforeend', '<div class="box"> Hello BB </div>');
  });
});
