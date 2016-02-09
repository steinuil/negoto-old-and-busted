document.addEventListener('DOMContentLoaded', function() {
	var hour = (new Date).getHours(),
		greeting;

	if (hour < 6 || hour > 21) {
		greeting = "Night";
	} else if (hour >= 6 && hour < 12) {
		greeting = "Morning";
	} else if (hour >= 12 && hour < 18) {
		greeting = "Afternoon";
	} else { greeting = "Evening"; };

	console.log(greeting);
	document.getElementById("greeting").innerText = "Good " + greeting + ", Brother."
});
