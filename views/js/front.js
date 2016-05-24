document.addEventListener('DOMContentLoaded', function() {
  var hour = (new Date).getHours(),
      greeting;
  if (hour >= 6 && hour < 12)
    greeting = 'Morning';
  else if (hour >= 12 && hour < 18)
    greeting = 'Afternoon';
  else if (hour >= 18 && hour < 22)
    greeting = 'Evening';
  else
    greeting = 'Night';

  document.getElementById('greeting').textContent = 'Good ' + greeting + ', Brother.';
});
