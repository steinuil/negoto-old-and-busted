document.onkeypress = keyboard_controls;
document.onmousedown = mouse_down;
document.onmouseup = mouse_up;

// Quoting
function quote(id) {
	var body = document.getElementById("body");
	if (body === null) { spawn_qr(); };
	document.getElementById("body").value += (">>" + id + "\n");
}

// Attachment name
function att_name() {
	var name = document.getElementById("filei").value;
	if (name != "") {
		name = name.split("\\");
		document.getElementById("file").innerText = name[name.length - 1];
	}
}

// Spawn/despawn quick reply box
function spawn_qr() {
  document.getElementById("qr-spawner").style.display = "none";
	var tmp = document.createElement('div');
	tmp.innerHTML = document.getElementsByTagName("noscript")[0].innerText;
	tmp = tmp.children[0];
	tmp.id = "floating-form";
	tmp.className = "draggable";
	document.body.appendChild(tmp);
    document.getElementById("body").select();
}

function destroy_qr() {
	document.body.removeChild(document.getElementById("floating-form"));
    document.getElementById("qr-spawner").style.display = "block";
}

// Keyboard controls
function keyboard_controls(e) {
	if (e.target.tagName != "TEXTAREA" && e.target.tagName != "INPUT") {
		// Spawn QR box if "q" is pressed
		if (document.getElementById("floating-form") === null && (e.keyCode === 113 || e.charCode == 113) &&
			document.getElementById("thread") !== null) {
			spawn_qr();
            return false;
		}
	}
}

// Dragging stuff around (works on every .draggable element)
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
			var r = window.outerWidth - e.clientX + offset_x - start_x;
			var b = window.outerHeight - e.clientY + offset_y - start_y;
			element.style.right = (r >= 0 ? r : 0) + "px";
			element.style.bottom = (b >= 0 ? b : 0) + "px";
			document.body.focus();
		};

		return false; // avoid selecting text while moving the box around
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
