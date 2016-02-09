document.onkeypress = keyboard_controls;
document.onmousedown = mouse_down;
document.onmouseup = mouse_up;

// Keyboard controls
function keyboard_controls(e) {
	if (e.target.tagName != "TEXTAREA" && e.target.tagName != "INPUT") {
		// Spawn QR box if "q" is pressed
		if (document.getElementById("floating-form") === null && e.keyCode === 113) {
			var orig = document.getElementById("post-form");
			var box = orig.cloneNode(true);
			box.id = "floating-form";
			box.className = "draggable";
			document.body.appendChild(box);
		}
	}
}

function destroy(id) {
	document.body.removeChild(document.getElementById(id));
}

// Dragging stuff around
var start_x = 0, start_y = 0, offset_x = 0, offset_y = 0, element;

function mouse_down(e) {
	var target = e.target;

	if (e.button === 0 && target.className === "draggable") {
		start_x = window.outerWidth - e.clientX;
		start_y = window.outerHeight - e.clientY;

		offset_x = to_int(target.style.right);
		offset_y = to_int(target.style.bottom);

		element = target;
		
		document.onmousemove = function(e) {
			element.style.right = (window.outerWidth - e.clientX + offset_x - start_x) + "px";
			element.style.bottom = (window.outerHeight - e.clientY + offset_y - start_y) + "px";
			document.body.focus();
		};

		return false;
	}
}

function mouse_up(e) {
	if (element != null) {
		document.onmousemove = null;
		element = null;
	}
}

function to_int(v) {
	var n = parseInt(v);
	return n == null || isNaN(n) ? 0 : n;
}
